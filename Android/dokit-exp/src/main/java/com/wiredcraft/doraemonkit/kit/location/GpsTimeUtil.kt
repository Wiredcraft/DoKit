package com.wiredcraft.doraemonkit.kit.location

object GpsTimeUtil {
    var startMS = 0L
    private var endMS = 0L

    fun start() {
        startMS = System.currentTimeMillis()
    }

    fun end() {
        endMS = System.currentTimeMillis()
    }

    fun getDuration(): Long {
        val ms = endMS - startMS
        startMS = 0
        endMS = 0
        return ms
    }
}
