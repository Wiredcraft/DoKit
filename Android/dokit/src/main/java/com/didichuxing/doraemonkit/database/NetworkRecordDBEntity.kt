package com.didichuxing.doraemonkit.database

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class NetworkRecordDBEntity(
    @PrimaryKey(autoGenerate = true) val mRequestId: Int,
    @ColumnInfo(name = "url") val url: String,
    @ColumnInfo(name = "method") val method: String,
    @ColumnInfo(name = "headers") val headers: String,
    @ColumnInfo(name = "postData") val postData: String,
    @ColumnInfo(name = "encode") val encode: String,
    @ColumnInfo(name = "mPlatform") val mPlatform: String,
    @ColumnInfo(name = "mResponseBody") val mResponseBody: String,
    @ColumnInfo(name = "requestLength") val requestLength: Long,
    @ColumnInfo(name = "responseLength") val responseLength: Long,
    @ColumnInfo(name = "startTime") val startTime: Long,
    @ColumnInfo(name = "endTime") val endTime: Long,
)
