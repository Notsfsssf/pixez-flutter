// llama_shim.cpp — llama.cpp C API 的极薄封装（端侧翻译推理，GPL-3.0 项目）。
//
// 设计动机：Dart FFI 直接绑定 llama.h 需要精确复刻 llama_context_params
// 等巨型 struct 的字段布局（随上游版本变动，错位即崩溃）。本文件在 C++
// 侧 include 原生 llama.h 使用真实类型，只向 Dart 导出少量布局稳定的
// 简单函数；单序列生成循环由 Dart worker isolate 逐 token 驱动（天然
// 支持流式输出与取消），多序列批量生成是一次性同步调用（批内并行
// decode，见 llama_shim_generate_multi）。
//
// 并发约束：宿主（translator 包 LlmEngineHost）保证请求串行进入，
// 这里用单个全局状态即可，无锁。

#include <cstdint>
#include <cstring>
#include <vector>

#include "llama.h"

#if defined(__ANDROID__)
#include <android/log.h>
#define SHIM_LOG(...) __android_log_print(ANDROID_LOG_INFO, "llama_shim", __VA_ARGS__)
#else
#define SHIM_LOG(...) ((void) 0)
#endif

namespace {

// 多序列批量生成的上限：序列 id 1..kMaxMultiSequences，seq 0 只放共享前缀。
constexpr int kMaxMultiSequences = 8;
// 每次调用最多 8 个序列 + 1 个共享前缀序列。
constexpr uint32_t kSeqMaxNeeded = kMaxMultiSequences + 1;

// 对话/翻译模板的结束标记。llama_vocab_is_eog 只认 GGUF 里标成 eos/eot
// 的 token；部分翻译模型把轮次结束符仅当普通特殊 token，判不出结束就会
// 一路生成到 max_tokens——真机表现为一批 4 段各跑满上限（单批 68 秒），
// 译文尾部还带大段重复。这里按字面量兜底截断。
//
// 混元 Hy-MT2 的标记是全角的（U+FF5C ｜ / U+2581 ▁），UTF-8 字节：
//   ｜ = EF BD 9C   ▁ = E2 96 81
// 相邻字符串分段写，避免 \x 转义贪婪吸收后面的十六进制字符（如 "2"）。
const char *const kStopMarkers[] = {
    // <｜hy_place▁holder▁no▁2｜>：assistant 轮次结束（最常在生成末尾出现）
    "<\xEF\xBD\x9C" "hy_place" "\xE2\x96\x81" "holder" "\xE2\x96\x81" "no"
    "\xE2\x96\x81" "2" "\xEF\xBD\x9C>",
    // <｜hy_place▁holder▁no▁8｜>：模板里 add_generation_prompt=false 的收尾
    "<\xEF\xBD\x9C" "hy_place" "\xE2\x96\x81" "holder" "\xE2\x96\x81" "no"
    "\xE2\x96\x81" "8" "\xEF\xBD\x9C>",
    "<\xEF\xBD\x9C" "hy_Assistant" "\xEF\xBD\x9C>",
    "<\xEF\xBD\x9C" "hy_User" "\xEF\xBD\x9C>",
    // 常见 ASCII 模板标记（Qwen / Llama / ChatML 等）
    "<|im_end|>", "<|endoftext|>", "<|eot_id|>", "<|end_of_text|>",
    "<|end|>", "</s>", "<|im_start|>",
};

// 若 out 末尾是结束标记，截掉标记并返回 true。
bool trim_stop_marker(std::string &out) {
    for (const char *marker : kStopMarkers) {
        const size_t mlen = strlen(marker);
        if (out.size() >= mlen &&
            out.compare(out.size() - mlen, mlen, marker) == 0) {
            out.resize(out.size() - mlen);
            return true;
        }
    }
    return false;
}


struct ShimState {
    llama_model *model = nullptr;
    llama_context *ctx = nullptr;
    const llama_vocab *vocab = nullptr;
    llama_sampler *smpl = nullptr;
    // 采样链参数（多序列时按需为每序列重建同参数链）。
    float temp = 0.0f;
    float top_p = 0.9f;
};
ShimState g;

// 手动向 batch 追加一个 token（llama.cpp 0.7.0 无 common_batch_add，
// 这里按字段布局逐项填写；n_seq_max 恒为 1：每 token 只属于一个序列）。
void batch_add(llama_batch &b, llama_token tok, llama_pos pos, llama_seq_id seq,
               bool want_logits) {
    b.token[b.n_tokens] = tok;
    b.pos[b.n_tokens] = pos;
    b.n_seq_id[b.n_tokens] = 1;
    b.seq_id[b.n_tokens][0] = seq;
    b.logits[b.n_tokens] = want_logits ? 1 : 0;
    b.n_tokens++;
}

// 按加载参数建一条独立采样链（贪心链无状态，链构建成本可忽略）。
llama_sampler *new_sampler_chain() {
    llama_sampler_chain_params chain = llama_sampler_chain_default_params();
    llama_sampler *smpl = llama_sampler_chain_init(chain);
    if (smpl == nullptr) return nullptr;
    if (g.temp <= 0.0f) {
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    } else {
        llama_sampler_chain_add(smpl, llama_sampler_init_top_p(
                                          g.top_p > 0.0f && g.top_p < 1.0f ? g.top_p : 0.9f, 1));
        llama_sampler_chain_add(smpl, llama_sampler_init_temp(g.temp));
    }
    return smpl;
}

} // namespace

extern "C" {

// 前置声明：定义在下方，load 需要先调 free 清场。
int32_t llama_shim_load(const char *path, int32_t n_ctx, float temp, float top_p,
                        int32_t n_threads, int32_t flash_attn);
void llama_shim_free(void);
int32_t llama_shim_start(const char *prompt);
int32_t llama_shim_next(char *buf, int32_t buf_len);

// 加载 GGUF 权重并创建推理上下文 + 采样链。
// temp <= 0 → 贪心解码（翻译要稳定输出）；否则 top_p → temp 采样链。
// n_threads <= 0 → 用 llama.cpp 默认（GGML_DEFAULT_N_THREADS = 4，不感知
// 大小核拓扑）；> 0 → 显式指定（decode 与 prefill 同值），设置页的自动
// 调优在本机实测后选定。
// flash_attn != 0 → 启用 flash-attn（GPU 无关的 CPU 实现，仅当 ggml 在该
// 量化/KV 类型下支持时可用）；0 → 关闭（默认，端侧短文本 decode 更快）。
// 返回 1 成功；0 失败（文件损坏 / 量化不支持 / 内存不足）。
int32_t llama_shim_load(const char *path, int32_t n_ctx, float temp, float top_p,
                        int32_t n_threads, int32_t flash_attn) {
    llama_shim_free();
    llama_backend_init();

    llama_model_params mp = llama_model_default_params();
    // 纯 CPU 推理：与 llama.cpp 服务端实测一致（-ngl 0 收益最大）。端侧
    // 虽有 GPU 后端，但集显与 CPU 共用内存总线，offload 反而互相抢带宽。
    mp.n_gpu_layers = 0;
    g.model = llama_model_load_from_file(path, mp);
    if (g.model == nullptr) {
        return 0;
    }

    llama_context_params cp = llama_context_default_params();
    cp.n_ctx = static_cast<uint32_t>(n_ctx > 0 ? n_ctx : 2048);
    // 多序列批量生成需要：n_seq_max 覆盖「8 序列 + 1 共享前缀序列」，
    // 统一 KV 池让各序列共享同一段前缀缓存（seq_cp 复用，见
    // llama_shim_generate_multi）。单序列路径不受影响。
    cp.n_seq_max = kSeqMaxNeeded;
    cp.kv_unified = true;
    // 关闭 flash-attn：短文本翻译以 decode 为主，FA 的额外开销大于收益
    // （服务端同机型实测 -fa off 生成更快，仅超长 prompt 预处理略慢）。
    // 设置页「性能实验台」可在本机实测对比两种取值，此处按传入开关决定。
    cp.flash_attn_type = flash_attn != 0 ? LLAMA_FLASH_ATTN_TYPE_ENABLED
                                         : LLAMA_FLASH_ATTN_TYPE_DISABLED;
    if (n_threads > 0) {
        cp.n_threads = n_threads;
        cp.n_threads_batch = n_threads;
    }
    g.ctx = llama_init_from_model(g.model, cp);
    if (g.ctx == nullptr) {
        llama_model_free(g.model);
        g.model = nullptr;
        return 0;
    }
    g.vocab = llama_model_get_vocab(g.model);
    g.temp = temp;
    g.top_p = top_p;

    // 实际生效的配置打到 logcat：实验台测出异常点位时可对照确认参数是否
    // 真被 llama.cpp 采纳（例如 FA 在部分量化上被静默降级）。
    SHIM_LOG("load ctx=%u threads=%d batch=%u ubatch=%u fa=%d seq_max=%u",
             llama_n_ctx(g.ctx), (int) cp.n_threads,
             llama_n_batch(g.ctx), llama_n_ubatch(g.ctx),
             (int) cp.flash_attn_type, llama_n_seq_max(g.ctx));

    g.smpl = new_sampler_chain();
    if (g.smpl == nullptr) {
        llama_shim_free();
        return 0;
    }
    return 1;
}

// 释放全部资源（采样器 + 上下文 + 权重）。幂等。
void llama_shim_free(void) {
    if (g.smpl != nullptr) {
        llama_sampler_free(g.smpl);
        g.smpl = nullptr;
    }
    if (g.ctx != nullptr) {
        llama_free(g.ctx);
        g.ctx = nullptr;
    }
    if (g.model != nullptr) {
        llama_model_free(g.model);
        g.model = nullptr;
    }
    g.vocab = nullptr;
}

// 设置生成提示词：tokenize + 预填充（逐批 decode），同时重置采样器。
// 返回 0 成功；-1 未加载模型；-2 提示词超出上下文容量；-3 解码失败。
int32_t llama_shim_start(const char *prompt) {
    if (g.ctx == nullptr || g.vocab == nullptr || g.smpl == nullptr) {
        return -1;
    }
    const int32_t len = static_cast<int32_t>(strlen(prompt));
    // 预查询所需 token 数。llama_tokenize 的约定：缓冲不足时返回
    // 「负的所需数量」——传空缓冲必然得到负值（例如需要 500 个 token
    // 返回 -500）。曾把 n_tok <= 0 一律当失败，导致所有非空 prompt
    // 恒报 -2「超出上下文容量」，与 n_ctx 大小无关。
    int32_t n_tok = llama_tokenize(g.vocab, prompt, len, nullptr, 0, true, true);
    if (n_tok == 0) {
        return -2;
    }
    if (n_tok < 0) {
        if (n_tok == INT32_MIN) {
            return -2;
        }
        n_tok = -n_tok;
    }
    std::vector<llama_token> tokens(static_cast<size_t>(n_tok));
    if (llama_tokenize(g.vocab, prompt, len, tokens.data(), n_tok, true, true) != n_tok) {
        return -3;
    }
    // 预留生成空间：超限直接拒绝（host 默认 ctx 2048，翻译提示词远小于此）。
    const uint32_t n_ctx = llama_n_ctx(g.ctx);
    if (static_cast<uint32_t>(n_tok + 128) > n_ctx) {
        return -2;
    }
    // 清空 KV：这是「每一次 start 都是一次独立翻译」的前提。
    //
    // llama_batch_get_one 不传位置，llama_decode 会按
    // `seq_pos_max(seq) + 1` 自动接续（llama-batch.cpp: pos_next = ...），
    // 所以不清 KV 的话，第二段 prompt 的位置会接在第一段生成结束的位置
    // 之后，而不是从 0 重新开始。翻几段之后位置就超过 n_ctx：
    //   · 先表现为每段都判失败（小说页面「这一段没有译出内容」），
    //   · 最后 KV 无处可写，ggml 越界写内存直接 SIGSEGV。
    // 真机 tombstone（11:43）就停在 ggml_compute_forward_mul_mat 的 memcpy
    // 写未映射页，栈上正好是 llama_shim_next → llama_decode。
    llama_memory_t mem = llama_get_memory(g.ctx);
    for (llama_seq_id s = 0; s < static_cast<llama_seq_id>(kSeqMaxNeeded); s++) {
        llama_memory_seq_rm(mem, s, -1, -1);
    }
    for (int32_t i = 0; i < n_tok;) {
        const int32_t n_batch = (n_tok - i) < 256 ? (n_tok - i) : 256;
        llama_batch batch = llama_batch_get_one(tokens.data() + i, n_batch);
        if (llama_decode(g.ctx, batch) != 0) {
            return -3;
        }
        i += n_batch;
    }
    llama_sampler_reset(g.smpl);
    return 0;
}

// 采样下一个 token，把它的 UTF-8 字节 piece 写入 buf（不写终止符），
// 并把该 token 喂回 KV cache 供下一轮采样。
// 返回 piece 字节数；0 = 生成结束（EOG）；-1 未加载；-3 解码失败；
// -4 缓冲区不足（调用方缓冲 >= 32 字节即不会发生）。
int32_t llama_shim_next(char *buf, int32_t buf_len) {
    if (g.ctx == nullptr || g.smpl == nullptr || g.vocab == nullptr) {
        return -1;
    }
    // 上下文写满就停：n_ctx 之外没有 KV 单元，继续 decode 会把位置推到
    // 区间外（历史崩溃点）。按「生成结束」返回 0，让上层当成正常收尾。
    const llama_pos pos_next =
        llama_memory_seq_pos_max(llama_get_memory(g.ctx), 0) + 1;
    if (pos_next + 1 >= static_cast<llama_pos>(llama_n_ctx(g.ctx))) {
        return 0;
    }
    llama_token tok = llama_sampler_sample(g.smpl, g.ctx, -1);
    if (llama_vocab_is_eog(g.vocab, tok)) {
        return 0;
    }
    char piece[64];
    // special=true：与多序列路径同款，混元的轮次结束符是特殊 token，
    // 只有渲染成字面量才能被 kStopMarkers 识别。
    const int32_t n = llama_token_to_piece(g.vocab, tok, piece, sizeof(piece), 0, true);
    if (n < 0) {
        return -4;
    }
    std::string text(piece, static_cast<size_t>(n));
    if (trim_stop_marker(text)) {
        return 0; // 命中轮次结束符：等同于 EOG
    }
    if (static_cast<int32_t>(text.size()) > buf_len) {
        return -4;
    }
    memcpy(buf, text.data(), text.size());
    llama_batch batch = llama_batch_get_one(&tok, 1);
    if (llama_decode(g.ctx, batch) != 0) {
        return -3;
    }
    return static_cast<int32_t>(text.size());
}

// ---- 多序列批量生成（图注分段并行翻译）----
//
// 移植自参考实现 overlay-translator 的 llama_multi_sequence.inc：一次
// llama_decode 同时推进多个独立 prompt 的生成（batch decode）。CPU 上
// 同批序列共享同一次权重矩阵运算，吞吐量接近随批大小线性提升（真机
// 24 段图注从串行数分钟缩到约三分之一）；所有 prompt 的公共指令前缀
// 只 prefill 一次，再经 llama_memory_seq_cp 把 KV 复制到各序列。
//
// 各序列输出按输入顺序以 \x1E（ASCII Record Separator，正常译文不会
// 出现）拼接写入 out_buf。
// 返回 >=0 为写入字节数；负数错误码：
// -1 未加载 / -2 序列数超范围（1..8）/ -3 tokenize 或解码失败 /
// -4 KV 或逻辑批容量不足（调用方可减批或回退逐段）/ -5 输出缓冲不足 /
// -6 n_seq_max 不足（load 未启用多序列）。
int32_t llama_shim_generate_multi(const char *const *prompts, int32_t n_prompts,
                                 int32_t max_tokens, char *out_buf, int32_t out_buf_len) {
    if (g.ctx == nullptr || g.vocab == nullptr) {
        return -1;
    }
    if (n_prompts < 1 || n_prompts > kMaxMultiSequences) {
        return -2;
    }
    if (llama_n_seq_max(g.ctx) < kSeqMaxNeeded) {
        return -6;
    }

    // tokenize 全部 prompt；顺带按最坏生成量预估统一 KV 占用。
    std::vector<std::vector<llama_token>> seq_tokens(n_prompts);
    int64_t decoded_prompt_tokens = 0;
    for (int32_t i = 0; i < n_prompts; i++) {
        const int32_t len = static_cast<int32_t>(strlen(prompts[i]));
        // 预查询所需 token 数：缓冲不足时 llama_tokenize 返回「负的所需
        // 数量」（见 llama_shim_start 同款注释，负值是正常契约）。
        int32_t n_tok = llama_tokenize(g.vocab, prompts[i], len, nullptr, 0, true, true);
        if (n_tok == 0 || n_tok == INT32_MIN) {
            return -30; // tokenize 预查询失败
        }
        if (n_tok < 0) {
            n_tok = -n_tok;
        }
        seq_tokens[i].resize(static_cast<size_t>(n_tok));
        if (llama_tokenize(g.vocab, prompts[i], len, seq_tokens[i].data(), n_tok,
                           true, true) != n_tok) {
            return -30;
        }
        decoded_prompt_tokens += n_tok;
    }

    // 最长公共 token 前缀（全部 prompt 的指令模板部分）。每序列至少保留
    // 1 个私有 token，保证各自的末位 logits 不依赖共享 batch 位。
    size_t shared = seq_tokens[0].size();
    for (int32_t i = 1; i < n_prompts && shared > 0; i++) {
        const size_t lim = shared < seq_tokens[i].size() ? shared : seq_tokens[i].size();
        size_t k = 0;
        while (k < lim && seq_tokens[0][k] == seq_tokens[i][k]) {
            k++;
        }
        shared = k;
    }
    if (shared > 0) {
        shared -= 1;
    }
    // 共享段在 KV 池里只占一份。
    decoded_prompt_tokens -= static_cast<int64_t>(shared) * (n_prompts - 1);
    const int64_t kv_need = decoded_prompt_tokens +
                            static_cast<int64_t>(n_prompts) * max_tokens;
    if (kv_need + 32 > static_cast<int64_t>(llama_n_ctx(g.ctx)) ||
        decoded_prompt_tokens > static_cast<int64_t>(llama_n_batch(g.ctx))) {
        return -4;
    }

    llama_memory_t mem = llama_get_memory(g.ctx);
    // 清场：上次单 / 多序列调用可能在任何序列残留 KV。
    for (llama_seq_id s = 0; s < static_cast<llama_seq_id>(kSeqMaxNeeded); s++) {
        llama_memory_seq_rm(mem, s, -1, -1);
    }

    struct SeqState {
        std::string out;
        llama_pos next_pos = 0;
        int32_t logits_idx = -1;
        int32_t generated = 0;
        bool finished = false;
    };
    std::vector<SeqState> st(n_prompts);
    std::vector<llama_sampler *> chains(n_prompts, nullptr);
    llama_batch batch = llama_batch_init(
        decoded_prompt_tokens > n_prompts ? static_cast<int32_t>(decoded_prompt_tokens)
                                          : n_prompts,
        0, 1);
    int32_t result = -3;

    do {
        // 每序列独立采样链（temp 链有状态，共享会互相污染）。
        bool chains_ok = true;
        for (int32_t i = 0; i < n_prompts; i++) {
            chains[i] = new_sampler_chain();
            if (chains[i] == nullptr) {
                chains_ok = false;
                break;
            }
        }
        if (!chains_ok) {
            break; // result 保持 -3
        }

        // 共享前缀以 seq 0 预填充一次，KV 复制给各序列。
        if (shared > 0) {
            batch.n_tokens = 0;
            for (size_t k = 0; k < shared; k++) {
                batch_add(batch, seq_tokens[0][k], static_cast<llama_pos>(k), 0, false);
            }
            if (llama_decode(g.ctx, batch) != 0) {
                result = -31; // 共享前缀 decode 失败
                break;
            }
            for (int32_t i = 0; i < n_prompts; i++) {
                llama_memory_seq_cp(mem, 0, static_cast<llama_seq_id>(i + 1), 0,
                                    static_cast<llama_pos>(shared));
            }
        }

        // 各序列的差异 token 打进同一个 batch 一次预填充；末位 token 带 logits。
        // 注意 llama_sampler_sample 的下标是「该 token 在 batch 中的下标」，
        // 不是「第几个 logits=true 的输出序号」：llama-context.cpp 的
        // output_resolve_row() 直接用 output_ids[i] 翻译，i >= n_tokens 或
        // 该 token 的 logits=false（output_ids[i] == -1）都会 GGML_ABORT
        // （真机表现为 SIGABRT + ggml_abort，栈在 llama_sampler_sample）。
        batch.n_tokens = 0;
        for (int32_t i = 0; i < n_prompts; i++) {
            const auto &toks = seq_tokens[i];
            const llama_seq_id seq = static_cast<llama_seq_id>(i + 1);
            st[i].next_pos = static_cast<llama_pos>(toks.size());
            for (size_t k = shared; k < toks.size(); k++) {
                const bool last = (k + 1 == toks.size());
                if (last) {
                    // batch_add 之后才 ++n_tokens，此时的值就是该 token 下标。
                    st[i].logits_idx = batch.n_tokens;
                }
                batch_add(batch, toks[k], static_cast<llama_pos>(k), seq, last);
            }
        }
        if (llama_decode(g.ctx, batch) != 0) {
            result = -32; // 差异段 prefill decode 失败
            break;
        }

        // 生成循环：把每个未完成序列的下一个 token 放进同一 batch，
        // 一次 decode 推进全部序列，再逐序列采样（logits 下标 = 该 token
        // 在本 batch 中的位置，见上方 output_resolve_row 说明）。
        auto sample_and_feed = [&](int32_t i) {
            const llama_token tok =
                llama_sampler_sample(chains[i], g.ctx, st[i].logits_idx);
            st[i].generated++;
            if (llama_vocab_is_eog(g.vocab, tok)) {
                st[i].finished = true;
                return;
            }
            char piece[64];
            // special=true：让 <|im_end|> 这类特殊 token 渲染成字面量，
            // 才能用 kStopMarkers 兜底识别结束（否则被渲染成空串）。
            const int32_t n = llama_token_to_piece(g.vocab, tok, piece, sizeof(piece), 0, true);
            if (n > 0) {
                st[i].out.append(piece, static_cast<size_t>(n));
                if (trim_stop_marker(st[i].out)) {
                    st[i].finished = true;
                    return;
                }
            }
            if (st[i].generated >= max_tokens) {
                st[i].finished = true;
                return;
            }
            st[i].logits_idx = batch.n_tokens;
            batch_add(batch, tok, st[i].next_pos++, static_cast<llama_seq_id>(i + 1), true);
        };

        result = 0;
        batch.n_tokens = 0;
        for (int32_t i = 0; i < n_prompts; i++) {
            sample_and_feed(i);
        }
        while (batch.n_tokens > 0) {
            if (llama_decode(g.ctx, batch) != 0) {
                result = -33; // 生成循环 decode 失败
                break;
            }
            batch.n_tokens = 0;
            for (int32_t i = 0; i < n_prompts; i++) {
                if (!st[i].finished) {
                    sample_and_feed(i);
                }
            }
        }
        if (result != 0) {
            break;
        }

        // 诊断：generated == max_tokens 说明没触发结束符（会显著拖慢批量）。
        SHIM_LOG("multi done n=%d shared=%zu maxTok=%d", n_prompts, shared, max_tokens);
        for (int32_t i = 0; i < n_prompts; i++) {
            SHIM_LOG("multi seq[%d] gen=%d chars=%zu", i, st[i].generated,
                     st[i].out.size());
        }

        // 拼接输出：out[i1E]out[1E]...（字节数不含末尾终止符）。
        int64_t total = 0;
        for (int32_t i = 0; i < n_prompts; i++) {
            total += static_cast<int64_t>(st[i].out.size()) + (i > 0 ? 1 : 0);
        }
        if (total > out_buf_len) {
            result = -5;
            break;
        }
        int32_t written = 0;
        for (int32_t i = 0; i < n_prompts; i++) {
            if (i > 0) {
                out_buf[written++] = '\x1E';
            }
            memcpy(out_buf + written, st[i].out.data(), st[i].out.size());
            written += static_cast<int32_t>(st[i].out.size());
        }
        result = written;
    } while (false);

    // 统一清理：采样链、batch、全部序列 KV（含 seq 0，防泄漏到下次调用）。
    for (auto *c : chains) {
        if (c != nullptr) {
            llama_sampler_free(c);
        }
    }
    llama_batch_free(batch);
    for (llama_seq_id s = 0; s < static_cast<llama_seq_id>(kSeqMaxNeeded); s++) {
        llama_memory_seq_rm(mem, s, -1, -1);
    }
    return result;
}

} // extern "C"
