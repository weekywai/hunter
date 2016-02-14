package com.metal.message;

@:build(de.polygonal.core.event.ObserverMacro.create
([
	AssignUnit,					//添加单元入游戏版
	AssignPlayer,				//创建控制角色
	CreateUnit,					//创建单元角色
	MonsterShow,                //怪物进场
	BossShow,                   //boss进场
	OnUnitFactionUpdated,		//更新阵营和类型
	OnUnitGroupUpdated,			//受伤
	OnGroupCountUpdated,		//
	Start,
	Reset,
	AddViewMap,					//添加地图
	StartAI,					//添加地图
	BindHideEntity				//生成当前屏幕隐藏怪物
]))
class MsgBoard {}