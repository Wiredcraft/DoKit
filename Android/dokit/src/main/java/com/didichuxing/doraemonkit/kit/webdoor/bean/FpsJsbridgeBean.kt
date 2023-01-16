package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.FpsEntity

data class FpsJsbridgeBean(
    val appName: String,
    val version: String,
    val fps: Fps
) {

    data class Fps(
        val xValues: ArrayList<Double>,
        val data: ArrayList<Int>,
    )
}

fun convertToFpsFromList(fpsEntities: MutableList<FpsEntity>): FpsJsbridgeBean.Fps{
    val timeList = arrayListOf<Double>()
    val valueList = arrayListOf<Int>()
    fpsEntities.forEach {
        timeList.add(it.time.toDouble())
        valueList.add(it.value.toInt())
    }
    return FpsJsbridgeBean.Fps(
        timeList,
        valueList
    )
}
