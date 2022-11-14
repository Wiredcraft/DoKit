package com.didichuxing.doraemonkit.kit.blockmonitor

import android.content.Context
import android.os.*
import android.util.Log
import com.didichuxing.doraemonkit.DoKitEnv.requireApp
import com.didichuxing.doraemonkit.kit.blockmonitor.bean.BlockInfo
import java.io.*
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*

object FileManager {
    private const val TAG = "BlockFile"
    private const val DIR_BLOCK = "BlockLogs"
    val mHandlerThread = HandlerThread(DIR_BLOCK)
    private fun createBlockDir(mContext: Context) {
        if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
            val dir = mContext.getExternalFilesDir(DIR_BLOCK)
            if (dir?.exists() == false) {
                dir.mkdirs()
            }
        }
    }

    fun startSave() {
        mHandlerThread.start()
    }

    fun save(info: BlockInfo) {
        val mContext: Context = requireApp().applicationContext

        createBlockDir(mContext)
        val mDateFormat: DateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())

        val saveHandler = Handler(mHandlerThread.looper) {
            val currentTime = System.currentTimeMillis()
            val time = mDateFormat.format(Date())
            val fileName = "block-$time-$currentTime.txt"

            val file = File(mContext.getExternalFilesDir(DIR_BLOCK), fileName)
            if (!file.exists()) file.createNewFile()

            var fos = FileOutputStream(file)
            try {
                fos.write(info.toString().toByteArray())
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
            obj = "block"
        }
        saveHandler.sendMessage(msg)
    }

    fun stopSave() {
        mHandlerThread.quit()
    }
}


