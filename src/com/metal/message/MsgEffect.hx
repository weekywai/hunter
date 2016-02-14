package com.metal.message;

/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	Create, 		//创建
	Recycle,			//回收
	EffectStart,		//开启特效
	EffectEnd			//关闭特效
]))
class MsgEffect{}