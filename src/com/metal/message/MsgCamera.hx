package com.metal.message;

/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	Lock,			//锁 解锁屏幕 参数Bool
	SetCameraPos,	//设置Camera坐标
	ShakeCamera		//震动屏幕
]))
class MsgCamera{}