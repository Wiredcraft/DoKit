package com.didichuxing.doraemonkit.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class FpsEntity(
    @PrimaryKey val time: String,
    val value: String,
)
