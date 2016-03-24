package com.metal.message;

/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	AddSubStatus,		//添加状态
	RemoveSubStatus,	//移除状态
	RegenHp,			//回复
	Invincible,			//无敌
	Runaway,			//暴走
	ChangeSpeed,		//改变速度
	DoubleScore,		//积分双倍
	UpdatePreStats,		//更新用户数值
	UpdateMp			//更新MP
]))
class MsgStat{}