package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.Counter
import com.didichuxing.doraemonkit.kit.timecounter.bean.CounterInfo

data class CounterBean(
    val launchCost: Long,
    val time: Long,
    val uid: String
)

data class ActivityCounterBean(
    val duration: Long,
    val pageName: String
)

fun convertToAppCounters(counter: List<Counter>): List<CounterBean> {
    val counters = arrayListOf<CounterBean>()

    counter.filter { it.type == CounterInfo.TYPE_APP }.forEach {
        counters.add(
            CounterBean(
                it.totalCost,
                it.time,
                it.uid.toString()
            )
        )
    }
    return counters
}

fun convertToActivityCounters(counter: List<Counter>): List<ActivityCounterBean> {
    val counters = arrayListOf<ActivityCounterBean>()
    counter.filter { it.type == CounterInfo.TYPE_ACTIVITY }.forEach {
        counters.add(
            ActivityCounterBean(
                it.totalCost,
                getActivityName(it.title)
            )
        )
    }
    return counters
}

private fun getActivityName(counterTitle: String): String {
    counterTitle.split(" -> ").let {
        return if (it.size == 2) {
            it[1]
        } else {
            counterTitle
        }
    }
}
