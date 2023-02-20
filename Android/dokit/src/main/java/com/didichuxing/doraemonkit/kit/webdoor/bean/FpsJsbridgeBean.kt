package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.FpsEntity
import com.didichuxing.doraemonkit.util.TimeUtils

data class FpsJsbridgeBean(
    val appName: String,
    val version: String,
    val fps: Fps,
    val network: NetWorkBean,
    val launchTimeData: MutableList<CounterBean>
) {

    data class Fps(
        val xValues: ArrayList<String>,
        val data: ArrayList<Int>,
    )
}

fun convertToFpsFromList(fpsEntities: MutableList<FpsEntity>): FpsJsbridgeBean.Fps{
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
