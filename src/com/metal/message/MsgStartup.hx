package com.metal.message;

@:build(de.polygonal.core.event.ObserverMacro.create
([
	Reset,			//重置场景
	Start,			//启动游戏版
	StartBattle,	//进入战斗
	AssignMap,		//指派地图 数据格式 : IMapGrid
	LoadMap,		//加载地图
	Finishbattle, 	//战斗完成结束
	BattleClear, 	//清除战斗敌人
	TransitionMap,	//转换地图
	FinishMap,		//完成地图
	GameInit,		//初始化战场数据
	BattleResult,	//副本结束记录
	NewBieGame,
	PauseCountDown, //暂停倒计时
	UpdateStar      //更新通关评级
]))
class MsgStartup {}