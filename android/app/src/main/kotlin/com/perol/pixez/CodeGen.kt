package com.perol.pixez

import android.util.Base64
import java.security.MessageDigest
import java.security.SecureRandom

object CodeGen {
    fun getCodeVer(): String {
        val byteArray = ByteArray(32)
        SecureRandom().nextBytes(byteArray)
        return Base64.encodeToString(byteArray, Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
    }

    fun getCodeChallenge(code: String): String {
        val toByteArray = code.toByteArray(charset("US-ASCII"))
        val digest = MessageDigest.getInstance("SHA-256").apply { update(toByteArray) }.digest()
        return Base64.encodeToString(digest, Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING)
    }
}
