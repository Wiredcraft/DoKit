package com.didichuxing.doraemonkit.kit.performance

import android.os.Build
import android.os.HandlerThread
import android.os.Looper
import android.os.Process
import android.text.TextUtils
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader

object CpuUtil {

    const val RECORD_STACK_THRESHOLD = 30

    fun getStackTraceOfThreadWithHighestCpuUsage(): Array<StackTraceElement>? {
        return getTID()?.let { (tid, threadName) ->
            getStackTraceByThread(tid = tid, threadName = threadName)
        }
    }

    private fun getTID(): Pair<Long, String>? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getTIDForO()
        } else {
            getTIDAboveO()
        }
    }

    private fun getTIDForO(): Pair<Long, String>? {
        var process: java.lang.Process? = null
        try {
            val pid = Process.myPid().toString()
            process = Runtime.getRuntime().exec("top -b -n 1 -m 1 -o TID,CMD,%CPU -s 3 -H -p $pid")
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            var line: String
            var tidIndex = -1
            var threadIndex = -1
            while (reader.readLine().also { line = it } != null) {
                line = line.trim { it <= ' ' }
                if (TextUtils.isEmpty(line)) {
                    continue
                }
                val tempIndex: Int = getTIDIndex(line)
                getThreadIndex(line).let {
                    if (it != -1) {
                        threadIndex = it
                    }
                }
                if (tempIndex != -1) {
                    tidIndex = tempIndex
                    continue
                }
                if (tidIndex == -1) {
                    continue
                }
                val param = line.split("\\s+".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
                if (param.size <= tidIndex) {
                    continue
                }
                return Pair(param[tidIndex].toLong(), param[threadIndex])
            }
        } catch (e: IOException) {
            e.printStackTrace()
        } catch (e: NumberFormatException) {
            e.printStackTrace()
        } finally {
            process?.destroy()
        }
        return null
    }

    private fun getTIDAboveO(): Pair<Long, String>? {
        return null // TODO
    }

    private fun getTIDIndex(line: String): Int {
        if (line.contains("TID")) {
            val titles = line.split("\\s+".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
            for (i in titles.indices) {
                if (titles[i].contains("TID")) {
                    return i
                }
            }
        }
        return -1
    }

    private fun getThreadIndex(line: String): Int {
        if (line.contains("CMD")) {
            val titles = line.split("\\s+".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
            for (i in titles.indices) {
                if (titles[i].contains("CMD")) {
                    return i
                }
            }
        }
        return -1
    }

    private fun getStackTraceByThread(tid: Long, threadName: String): Array<StackTraceElement>? {
        Thread.getAllStackTraces().keys.forEach { thread ->
            val ttid = if (thread is HandlerThread) {
                thread.threadId
            } else {
                thread.id
            }
            if (tid == ttid
                || (tid == Process.myPid().toLong() && ttid == Looper.getMainLooper().thread.id)
                || thread.name.contains(threadName)
            ) {
                return thread.stackTrace
            }
        }
        return null
    }
}
