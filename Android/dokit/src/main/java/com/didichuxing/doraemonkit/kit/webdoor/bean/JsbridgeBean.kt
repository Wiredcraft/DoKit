package com.didichuxing.doraemonkit.kit.webdoor.bean

data class JsbridgeBean(
    val appName: String,
    val deviceInfo: String,
    val fps: List<FpsBean>,
    val network: NetWorkBean,
    val launchTimeData: MutableList<CounterBean>,
    val memoryLeakData: MutableList<MemoryLeakBean>,
    val locationData: LocationBean
)

