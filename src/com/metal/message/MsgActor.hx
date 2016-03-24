package com.metal.message;
/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	PostLoad, 			//加载完成
	EnterBoard,			//已记录到游戏板
	ExitBoard,			//退出游戏板
	InitFaction,		//初始化阵营和类型
	InitAI,				//初始化AI
	PosForceUpdate,		//更新位置
	BornPos,            //出生点
	Stand,				//待机
	Move,				//移动
	Jump,				//跳跃
	Attack,				//开枪
	Melee,				//近战
	ThrowBomb,			//扔炸弹
	Skill,				//技能
	Injured,			//受伤
	Patrol,				//巡逻
	Escape,				//逃跑
	Victory,			//胜利
	Destroying,			//死亡动作
	OpenStage,          //更新副本开启
	Destroy,			//完成死亡
	Soul,				//灵魂状态
	Respawn,            //复活
	AttackStatus,       //攻击状态 
	Enter				//进场
]))
class MsgActor{}