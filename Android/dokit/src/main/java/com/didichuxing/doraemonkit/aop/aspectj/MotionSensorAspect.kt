package com.didichuxing.doraemonkit.aop.aspectj

import android.util.Log
import org.aspectj.lang.ProceedingJoinPoint
import org.aspectj.lang.annotation.Around
import org.aspectj.lang.annotation.Aspect

@Aspect
class MotionSensorAspect {

    @Around("call(* android.hardware.SensorManager.getDefaultSensor(..))")
    fun aroundGetDefaultSensor(joinPoint: ProceedingJoinPoint): Any? {
        Log.d("MethodAspect", "拦截 getDefaultSensor")
        return joinPoint.proceed(joinPoint.args)
    }

    @Around("call(* android.hardware.SensorManager.registerListener(..))")
    fun aroundSensorManagerRegisterListener(joinPoint: ProceedingJoinPoint): Any? {
        Log.d("MethodAspect", "拦截 registerListener ${joinPoint.args}")
        return joinPoint.proceed(joinPoint.args)
    }

    @Around("call(* android.hardware.SensorManager.unregisterListener(..))")
    fun aroundSensorManagerUnregisterListener(joinPoint: ProceedingJoinPoint): Any? {
        Log.d("MethodAspect", "拦截 unregisterListener ${joinPoint.args}")
        return joinPoint.proceed(joinPoint.args)
    }

}
