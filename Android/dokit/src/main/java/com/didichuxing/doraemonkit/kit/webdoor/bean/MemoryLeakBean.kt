package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.MemoryEntity

data class MemoryLeakBean(
    var count: Int,
    val info: String
)

fun convertToMemoryFromList(memoryLeaks: List<MemoryEntity>): ArrayList<MemoryLeakBean> {
    val memoryMap = mutableMapOf<Int, MemoryLeakBean>()
    val memoryList = arrayListOf<MemoryLeakBean>()

    memoryLeaks.forEach { m ->
        val contains = memoryMap.contains(m.type)
        if (contains) {
            val memoryLeak = memoryMap[m.type]
            memoryLeak?.count = memoryLeak?.count?.plus(1) ?: 1
        } else {
            memoryMap.put(m.type, MemoryLeakBean(1, getActivityFromInfo(m.info)))
        }
    }
    memoryMap.filter { !isDoKitClass(it.value.info) }.forEach { (_, memoryLeak) ->
        memoryList.add(memoryLeak)
    }
    return memoryList
}

fun isDoKitClass(className: String): Boolean {
    return className.contains("com.wiredcraft.doraemonkit") || className.contains("com.didichuxing.doraemonkit")
}

fun getActivityFromInfo(info: String): String {
    val prefix = "\"activity\":\""
    info.indexOf(prefix).let { indexStart ->
        if (indexStart == -1) {
            return info
        } else {
            val indexEnd = info.indexOf("\"", indexStart + prefix.length)
            if (indexEnd == -1) {
                return info
            } else {
                return info.substring(indexStart + prefix.length, indexEnd)
            }
        }
    }
}
