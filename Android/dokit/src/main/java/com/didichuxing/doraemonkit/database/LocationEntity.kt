package com.didichuxing.doraemonkit.database

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.didichuxing.doraemonkit.kit.webdoor.bean.LocationBean

@Entity
data class LocationEntity(
    val totalTime: Long,
    val startTime: Long,
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0
)

fun convertToLocationFrom(locationEntitys: List<LocationEntity>): List<LocationBean> {
    return locationEntitys.map {
        LocationBean(it.startTime, it.totalTime)
    }
}
