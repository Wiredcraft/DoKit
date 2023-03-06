package com.didichuxing.doraemonkit.database

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.didichuxing.doraemonkit.kit.webdoor.bean.LocationBean

@Entity
data class LocationEntity(
    var totalTime: Long,
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0
)

fun convertToLocationFrom(locationEntitys: List<LocationEntity>): LocationBean {
    var time = 0L
    locationEntitys.forEach {
        time = time + it.totalTime
    }

    return LocationBean(locationEntitys.size,time)
}
