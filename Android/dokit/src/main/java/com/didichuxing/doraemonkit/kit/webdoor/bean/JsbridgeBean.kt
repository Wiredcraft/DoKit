package com.didichuxing.doraemonkit.kit.webdoor.bean

data class JsbridgeBean(
    val appName: String,
    val deviceInfo: String,
    val fps: List<FpsBean>,
    val network: NetWorkBean,
    val networkFlowData: List<NetWorkFlowBean>,
    val launchTimeData: List<CounterBean>,
    val memoryLeakData: List<MemoryLeakBean>,
    val locationData: List<LocationBean>,
    val pageLaunchTime: List<ActivityCounterBean>,
    val cpuData: CpuBean,
    val blockData: List<BlockBean>,
)

