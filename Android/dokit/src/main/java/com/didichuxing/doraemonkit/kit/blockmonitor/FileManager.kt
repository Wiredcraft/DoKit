package com.didichuxing.doraemonkit.kit.blockmonitor

import android.content.Context
import android.os.*
import android.util.Log
import com.didichuxing.doraemonkit.DoKitEnv.requireApp
import com.didichuxing.doraemonkit.kit.blockmonitor.bean.BlockInfo
import com.didichuxing.doraemonkit.kit.health.model.FileConstants
import com.didichuxing.doraemonkit.kit.health.model.LocalFile
import java.io.*
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*

object FileManager {
    private const val TAG = "FileManager"

    val mHandlerThread = HandlerThread(FileConstants.THREAD_NAME)

    private fun createDir(dirName: String, mContext: Context) {
        if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
            val dir = mContext.getExternalFilesDir(dirName)
            if (dir?.exists() == false) {
                dir.mkdirs()
            }
        }
    }

    fun startSave() {
        mHandlerThread.start()
    }

    fun save(dirName: String, fileNamePrefix: String, info: LocalFile) {
        val mContext: Context = requireApp().applicationContext

        createDir(dirName, mContext)

        val mDateFormat: DateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

        val saveHandler = Handler(mHandlerThread.looper) {
            val currentTime = System.currentTimeMillis()
            val time = mDateFormat.format(Date())
            val fileName = "$fileNamePrefix-$time-$currentTime.txt"

            val file = File(mContext.getExternalFilesDir(dirName), fileName)
            if (!file.exists()) file.createNewFile()

            var fos = FileOutputStream(file)
            var fileStr = "PageName:${info.pageName}\nCostTime:${info.time}\nDetail:\n${info.detail}"
            try {
                fos.write(fileStr.toByteArray())
            } catch (e1: FileNotFoundException) {
                Log.e(TAG, "error : file not found", e1)
            } catch (e2: IOException) {
                Log.e(TAG, "error : writing file", e2)
            } finally {
                fos.close()
            }
            return@Handler true
        }

        val msg = Message.obtain().apply {
            what = 1
            obj = "appHealth"
        }
        saveHandler.sendMessage(msg)
    }

    fun stopSave() {
        mHandlerThread.quit()
    }
}


