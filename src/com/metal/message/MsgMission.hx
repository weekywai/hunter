package com.metal.message;

/**
 * ...
 * @author hyg
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	Add,			//奖励
	Init,			//初始化
	Reward,			//奖励
	Update,			//更新任务
	UpdateCopy,		//更新副本
	Forge,			//锻造更新
	UpdateReward	//
]))
class MsgMission{}