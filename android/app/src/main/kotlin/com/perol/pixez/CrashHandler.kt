package com.perol.pixez

import android.content.Context
import android.content.res.Resources
import android.os.Looper
import android.os.Process
import android.util.Log
import android.view.Gravity
import android.view.InflateException
import android.widget.Toast
import java.io.PrintWriter
import java.io.StringWriter
import java.util.*
import kotlin.concurrent.thread
import kotlin.system.exitProcess

class CrashHandler : Thread.UncaughtExceptionHandler {

    private var mDefaultHandler: Thread.UncaughtExceptionHandler? = null
    private var mContext: Context? = null

    fun init(ctx: Context?) {
        mContext = ctx
        mDefaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler(this)
    }

    override fun uncaughtException(thread: Thread, ex: Throwable) {
        if (!handleException(ex) && mDefaultHandler != null) {
            mDefaultHandler!!.uncaughtException(thread, ex)
        } else {
            try {
                Thread.sleep(5000)
            } catch (e: InterruptedException) {
                Log.e(TAG, "Error : ", e)
            }
            Process.killProcess(Process.myPid())
            exitProcess(10)
        }
    }

    private fun handleException(ex: Throwable?): Boolean {
        if (ex == null) {
            Log.w(TAG, "handleException --- ex==null")
            return true
        }
        //使用Toast来显示异常信息
        thread {
            Looper.prepare()
            if (ex is Resources.NotFoundException || ex is InflateException || ex.message != null && ex.message!!.contains(
                    "XML"
                )
            ) {
                val toast = Toast.makeText(
                    mContext, """
     你使用的是二次打包(如QQ传应用，APKPURE，应用备份等等)的应用,请清除数据,前往google play或者设置中的github项目地址进行安装:
     ${ex.message}
     """.trimIndent(),
                    Toast.LENGTH_LONG
                )
                toast.setGravity(Gravity.CENTER, 0, 0)
                toast.show()
            } else if (ex.message!!.lowercase().contains("document")) {
                val toast = Toast.makeText(
                    mContext, """
     SAF进行文件读写操作时出现异常，这似乎是由于未正确配置授权目录引起的，请前往应用内设置页，更改保存目录为Picture目录下的任意文件夹,不要选择Donwload下载目录，或清除数据后重新选择目录
     ${ex.message}
     """.trimIndent(), Toast.LENGTH_LONG
                )
                toast.setGravity(Gravity.CENTER, 0, 0)
                toast.show()
            } else {
                var s = ""
                val sw = StringWriter()
                val pw = PrintWriter(sw)
                ex.printStackTrace(pw)
                val toast = Toast.makeText(mContext, sw.buffer.toString().trimIndent(), Toast.LENGTH_LONG)
                toast.setGravity(Gravity.CENTER, 0, 0)
                toast.show()
            }
            Looper.loop()
        }
        return true
    }

    companion object {
        const val TAG = "CrashHandler"
        val instance by lazy(mode = LazyThreadSafetyMode.SYNCHRONIZED) {
            CrashHandler()
        }//就一个线程要啥双锁双非空检查
    }
}