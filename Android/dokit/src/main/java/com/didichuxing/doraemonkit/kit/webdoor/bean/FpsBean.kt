package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.FpsEntity

data class FpsBean(
    val value: String,
    val time: String,
    val topView: String
)

fun convertToFpsFromList(fpsEntities: MutableList<FpsEntity>): List<FpsBean> {
    val data = arrayListOf<FpsBean>()
    fpsEntities.forEach {
        data.add(FpsBean(it.value, it.time, it.topView))
    }
    return data
}
