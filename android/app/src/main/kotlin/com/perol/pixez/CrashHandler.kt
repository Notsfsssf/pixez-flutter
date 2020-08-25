package com.perol.pixez

import android.content.Context
import android.content.res.Resources
import android.os.Looper
import android.os.Process
import android.text.format.Time
import android.util.Log
import android.view.Gravity
import android.view.InflateException
import android.widget.Toast
import java.io.*
import java.util.*

class CrashHandler
/**
 * 保证只有一个CrashHandler实例
 */
private constructor() : Thread.UncaughtExceptionHandler {
    /**
     * 系统默认的UncaughtException处理类
     */
    private var mDefaultHandler: Thread.UncaughtExceptionHandler? = null

    /**
     * 程序的Context对象
     */
    private var mContext: Context? = null
    private val mDeviceCrashInfo = Properties()

    /**
     * 初始化,注册Context对象,
     * 获取系统默认的UncaughtException处理器,
     * 设置该CrashHandler为程序的默认处理器
     *
     * @param ctx
     */
    fun init(ctx: Context?) {
        mContext = ctx
        mDefaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler(this)
    }

    /**
     * 当UncaughtException发生时会转入该函数来处理
     */
    override fun uncaughtException(thread: Thread, ex: Throwable) {
        if (!handleException(ex) && mDefaultHandler != null) {
            //如果用户没有处理则让系统默认的异常处理器来处理
            mDefaultHandler!!.uncaughtException(thread, ex)
        } else {
            //Sleep一会后结束程序
            try {
                Thread.sleep(5000)
            } catch (e: InterruptedException) {
                Log.e(TAG, "Error : ", e)
            }
            Process.killProcess(Process.myPid())
            System.exit(10)
        }
    }

    /**
     * 自定义错误处理,收集错误信息
     * 发送错误报告等操作均在此完成.
     * 开发者可以根据自己的情况来自定义异常处理逻辑
     *
     * @param ex
     * @return true:如果处理了该异常信息;否则返回false
     */
    private fun handleException(ex: Throwable?): Boolean {
        if (ex == null) {
            Log.w(TAG, "handleException --- ex==null")
            return true
        }
        val msg = ex.localizedMessage ?: return false
        //使用Toast来显示异常信息
        object : Thread() {
            override fun run() {
                Looper.prepare()
                if (ex is Resources.NotFoundException || ex is InflateException || ex.message != null && ex.message!!.contains("XML")) {
                    val toast = Toast.makeText(mContext, """
     你使用的是二次打包(如QQ传应用，APKPURE，应用备份等等)的应用,请清除数据,前往google play或者设置中的github项目地址进行安装:
     ${ex.message}
     """.trimIndent(),
                            Toast.LENGTH_LONG)
                    toast.setGravity(Gravity.CENTER, 0, 0)
                    toast.show()
                } else if (DEBUG) {
                    val toast = Toast.makeText(mContext, """
     程序出错，即将退出:
     ${ex.message}
     """.trimIndent(),
                            Toast.LENGTH_LONG)
                    toast.setGravity(Gravity.CENTER, 0, 0)
                    toast.show()
                }
                Looper.loop()
            }
        }.start()
        //        //收集设备信息
//        collectCrashDeviceInfo(mContext);
//        //保存错误报告文件
//        saveCrashInfoToFile(ex);
        //发送错误报告到服务器
        //sendCrashReportsToServer(mContext);
        return true
    }

    /**
     * 在程序启动时候, 可以调用该函数来发送以前没有发送的报告
     */
    fun sendPreviousReportsToServer() {
        sendCrashReportsToServer(mContext)
    }

    /**
     * 把错误报告发送给服务器,包含新产生的和以前没发送的.
     *
     * @param ctx
     */
    private fun sendCrashReportsToServer(ctx: Context?) {
        val crFiles = getCrashReportFiles(ctx)
        if (crFiles.isNotEmpty()) {
            val sortedFiles = TreeSet<String>()
            sortedFiles.addAll(Arrays.asList(*crFiles))
            for (fileName in sortedFiles) {
                val cr = File(ctx!!.filesDir, fileName)
                postReport(cr)
                cr.delete() // 删除已发送的报告
            }
        }
    }

    private fun postReport(file: File) {}

    /**
     * 获取错误报告文件名
     *
     * @param ctx
     * @return
     */
    private fun getCrashReportFiles(ctx: Context?): Array<String> {
        val filesDir = ctx!!.filesDir
        val filter = FilenameFilter { dir, name -> name.endsWith(CRASH_REPORTER_EXTENSION) }
        return filesDir.list(filter)!!
    }

    /**
     * 保存错误信息到文件中
     *
     * @param ex
     * @return
     */
    private fun saveCrashInfoToFile(ex: Throwable): String? {
        val info: Writer = StringWriter()
        val printWriter = PrintWriter(info)
        ex.printStackTrace(printWriter)
        var cause = ex.cause
        while (cause != null) {
            cause.printStackTrace(printWriter)
            cause = cause.cause
        }
        val result = info.toString()
        printWriter.close()
        mDeviceCrashInfo["EXEPTION"] = ex.localizedMessage
        mDeviceCrashInfo[STACK_TRACE] = result
        try {
            //long timestamp = System.currentTimeMillis();
            val t = Time("GMT+8")
            t.setToNow() // 取得系统时间
            val date = t.year * 10000 + t.month * 100 + t.monthDay
            val time = t.hour * 10000 + t.minute * 100 + t.second
            val fileName = "crash-$date-$time$CRASH_REPORTER_EXTENSION"
            val trace = mContext!!.openFileOutput(fileName,
                    Context.MODE_PRIVATE)
            mDeviceCrashInfo.store(trace, "")
            trace.flush()
            trace.close()
            return fileName
        } catch (e: Exception) {
            Log.e(TAG, "an error occured while writing report file...", e)
        }
        return null
    }

    /**
     * 收集程序崩溃的设备信息
     *
     * @param ctx
     */
    fun collectCrashDeviceInfo(ctx: Context?) {
//        try {
//            PackageManager pm = ctx.getPackageManager();
//            PackageInfo pi = pm.getPackageInfo(ctx.getPackageName(),
//                    PackageManager.GET_ACTIVITIES);
//            if (pi != null) {
//                mDeviceCrashInfo.put(VERSION_NAME,
//                        pi.versionName == null ? "not set" : pi.versionName);
//                mDeviceCrashInfo.put(VERSION_CODE, ""+pi.versionCode);
//            }
//        } catch (PackageManager.NameNotFoundException e) {
//            Log.e(TAG, "Error while collect package info", e);
//        }
        //使用反射来收集设备信息.在Build类中包含各种设备信息,
        //例如: 系统版本号,设备生产商 等帮助调试程序的有用信息
    }

    companion object {
        /**
         * Debug Log tag
         */
        const val TAG = "CrashHandler"

        /**
         * 是否开启日志输出,在Debug状态下开启,
         * 在Release状态下关闭以提示程序性能
         */
        const val DEBUG = true

        /**
         * CrashHandler实例
         */
        private var INSTANCE: CrashHandler? = null
        private const val VERSION_NAME = "versionName"
        private const val VERSION_CODE = "versionCode"
        private const val STACK_TRACE = "STACK_TRACE"

        /**
         * 错误报告文件的扩展名
         */
        private const val CRASH_REPORTER_EXTENSION = ".cr"
        private val syncRoot = Any()/* if (INSTANCE == null) {
            INSTANCE = new CrashHandler();
        }
        return INSTANCE;*/
        // 防止多线程访问安全，这里使用了双重锁
        /**
         * 获取CrashHandler实例 ,单例模式
         */
        val instance: CrashHandler?
            get() {
                /* if (INSTANCE == null) {
                        INSTANCE = new CrashHandler();
                    }
                    return INSTANCE;*/
                // 防止多线程访问安全，这里使用了双重锁
                if (INSTANCE == null) {
                    synchronized(syncRoot) {
                        if (INSTANCE == null) {
                            INSTANCE = CrashHandler()
                        }
                    }
                }
                return INSTANCE
            }
    }
}