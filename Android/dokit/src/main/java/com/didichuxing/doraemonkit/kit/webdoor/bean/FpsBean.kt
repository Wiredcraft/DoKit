package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.FpsEntity

data class FpsBean(
    val value: Int,
    val time: Long,
    val topView: String
)

fun convertToFpsFromList(fpsEntities: List<FpsEntity>): List<FpsBean> {
    val data = arrayListOf<FpsBean>()
    fpsEntities.filter { !isDoKitClass(it.topView) }.forEach {
        data.add(FpsBean(it.value, it.time, it.topView))
    }
    return data
}
