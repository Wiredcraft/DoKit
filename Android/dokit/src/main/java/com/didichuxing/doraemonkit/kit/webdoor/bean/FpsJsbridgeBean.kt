package com.didichuxing.doraemonkit.kit.webdoor.bean

import android.os.Build
import androidx.annotation.RequiresApi
import com.didichuxing.doraemonkit.database.FpsEntity
import com.didichuxing.doraemonkit.database.MemoryEntity

data class FpsJsbridgeBean(
    val appName: String,
    val version: String,
    val fps: List<FpsJsbridgeBean.Fps>,
    val network: NetWorkBean,
    val launchTimeData: MutableList<CounterBean>,
    val memoryLeakData: MutableList<MemoryLeak>,
    val locationData: LocationBean
) {

    data class Fps(
        val value: String,
        val time: String,
        val topView: String
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

fun convertToFpsFromList(fpsEntities: MutableList<FpsEntity>): List<FpsJsbridgeBean.Fps> {
    val data = arrayListOf<FpsJsbridgeBean.Fps>()
    fpsEntities.forEach {
        data.add(FpsJsbridgeBean.Fps(it.value, it.time, it.topView))
    }
    return data
}
