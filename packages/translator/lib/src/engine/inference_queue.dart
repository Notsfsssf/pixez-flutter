/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

/// 推理串行队列（对齐参考 LlamaEngineLifecycleGate.kt）。
///
/// 端侧引擎一次只能处理一段：并发触发 N 个 translate 时必须排队而非
/// 并发执行，否则第 2 段起会被 native 层丢弃并让引擎进入 Error。
/// 卸载与模型切换也在同一队列内执行，保护进程级 native 状态。
/// 锁序约定（参考实现）：总是 lifecycle gate 在外、initLock 在内。
library;

/// 单线程消息队列风格的串行执行器：同一时刻至多一个 session 在跑。
class InferenceQueue {
  Future<void> _tail = Future<void>.value();

  /// 排队执行一个 session；action 抛出的异常原样透传给调用方，
  /// 且不影响后续 session 的执行（单次失败不吞链）。
  Future<T> withSession<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    // 队列尾只关心「session 结束」，吞掉错误防止断链；
    // 错误已经通过 [result] 透传给真正的调用方。
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }
}
