#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_log_to_console(if cfg!(debug_assertions) {
        log::LevelFilter::Trace
    } else {
        log::LevelFilter::Warn
    });
    flutter_rust_bridge::setup_backtrace();
}

// Initializes and deinitializes the rustls-platform-verifier
// on Android.
#[cfg(target_os = "android")]
mod init_android_context {
    use std::{
        os::raw::c_void,
        sync::{Arc, OnceLock},
    };

    use jni::{
        jni_mangle,
        objects::{JClass, JObject},
        refs::Global,
        EnvUnowned,
    };

    static CTX: OnceLock<Arc<Global<JObject>>> = OnceLock::new();

    #[jni_mangle("com.flutter_rust_bridge.rhttp.RhttpPlugin")]
    pub extern "system" fn init_android<'caller>(
        mut unowned_env: EnvUnowned<'caller>,
        _class: JClass<'caller>,
        context: JObject<'caller>,
    ) {
        unowned_env
            .with_env(|env| {
                let jvm = env.get_java_vm().expect("Failed to get Java VM.");
                let jvm_pointer = jvm.get_raw() as *mut c_void;

                let global_ref = if let Some(reference) = CTX.get() {
                    reference.clone()
                } else {
                    Arc::new(env.new_global_ref(&context)?)
                };

                let _ = CTX.get_or_init(|| global_ref.clone());

                unsafe {
                    ndk_context::initialize_android_context(
                        jvm_pointer,
                        global_ref.as_obj().as_raw() as _,
                    );
                }

                rustls_platform_verifier::android::init_with_env(env, context)?;

                Ok::<(), jni::errors::Error>(())
            })
            .resolve::<jni::errors::ThrowRuntimeExAndDefault>();
    }

    #[jni_mangle("com.flutter_rust_bridge.rhttp.RhttpPlugin")]
    pub unsafe extern "system" fn deinit_android<'caller>(
        mut _unowned_env: EnvUnowned<'caller>,
        _class: JClass<'caller>,
    ) {
        ndk_context::release_android_context();
    }
}
