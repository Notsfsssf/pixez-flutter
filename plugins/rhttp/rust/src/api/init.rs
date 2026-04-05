#[cfg(target_os = "android")]
use jni::objects::{JClass, JObject};
#[cfg(target_os = "android")]
use jni::sys::jboolean;
#[cfg(target_os = "android")]
use jni::JNIEnv;
#[cfg(target_os = "android")]
use std::sync::atomic::{AtomicBool, Ordering};

#[cfg(target_os = "android")]
static ANDROID_PLATFORM_VERIFIER_INITIALIZED: AtomicBool = AtomicBool::new(false);

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[cfg(target_os = "android")]
#[export_name = "Java_com_flutter_1rust_1bridge_rhttp_RhttpPlugin_nativeInitPlatformVerifier"]
pub extern "system" fn native_init_platform_verifier(
    mut env: JNIEnv,
    _class: JClass,
    context: JObject,
) -> jboolean {
    if ANDROID_PLATFORM_VERIFIER_INITIALIZED.load(Ordering::Acquire) {
        return 1;
    }

    match rustls_platform_verifier::android::init_with_env(&mut env, context) {
        Ok(()) => {
            ANDROID_PLATFORM_VERIFIER_INITIALIZED.store(true, Ordering::Release);
            1
        }
        Err(_) => 0,
    }
}
