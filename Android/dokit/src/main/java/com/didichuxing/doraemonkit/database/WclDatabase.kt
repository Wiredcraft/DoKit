package com.didichuxing.doraemonkit.database

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [Counter::class, NetworkRecordDBEntity::class], version = 3, exportSchema = false)
abstract class WclDatabase : RoomDatabase() {
    abstract fun wclDao(): WclDao
}
