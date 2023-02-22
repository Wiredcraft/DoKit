package com.didichuxing.doraemonkit.kit.webdoor.bean

import android.os.Build
import androidx.annotation.RequiresApi
import com.didichuxing.doraemonkit.database.FpsEntity
import com.didichuxing.doraemonkit.database.MemoryEntity
import com.didichuxing.doraemonkit.util.TimeUtils

data class FpsJsbridgeBean(
    val appName: String,
    val version: String,
    val fps: Fps,
    val network: NetWorkBean,
    val launchTimeData: MutableList<CounterBean>,
    val memoryLeakData: MutableList<MemoryLeak>
) {

    data class Fps(
        val xValues: ArrayList<String>,
        val data: ArrayList<Int>
    )

    data class MemoryLeak(
        var count: Int,
        val info: String
    )
}

@RequiresApi(Build.VERSION_CODES.N)
fun convertToMemoryFromList(memoryLeaks: MutableList<MemoryEntity>): ArrayList<FpsJsbridgeBean.MemoryLeak> {
    val memoryMap = mutableMapOf<Int, FpsJsbridgeBean.MemoryLeak>()
    val memoryList = arrayListOf<FpsJsbridgeBean.MemoryLeak>()

    memoryLeaks.forEach { m ->
        val contains = memoryMap.contains(m.type)
        if (contains) {
            val memoryLeak = memoryMap[m.type]
            memoryLeak?.count = memoryLeak?.count?.plus(1) ?: 1
        } else {
            memoryMap.put(m.type, FpsJsbridgeBean.MemoryLeak(1, m.info))
        }
    }
    memoryMap.forEach { (_, memoryLeak) ->
        memoryList.add(memoryLeak)
    }
    return memoryList
}

fun convertToFpsFromList(fpsEntities: MutableList<FpsEntity>): FpsJsbridgeBean.Fps {
    val timeList = arrayListOf<String>()
    val valueList = arrayListOf<Int>()
    fpsEntities.forEach {
        timeList.add(TimeUtils.millis2String(it.time.toLong()))
        valueList.add(it.value.toInt())
    }
    return FpsJsbridgeBean.Fps(
        timeList,
        valueList
    )
}
