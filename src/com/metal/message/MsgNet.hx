package com.metal.message;

/**
 *网络消息
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	OnStartGame,			//重置场景
	OnFightingConnected,	//指派地图 数据格式 : IMapGrid
	OnAccountConnected,
	AssignAccount,			//传入外部挂接的账号信息
	UpdateInfo,				//更新角色信息
	UpdateResources,     	//更新角色资源
	UpdateTask,          	//跟新任务进展
	UpdataReward,			//更新奖励进度(!!!!!)
	UpdateBag,				//更新背包
	QuestList,        		//完成任务
	Intensify,              //更新强化
	Advance,              	//更新进阶 
	OpenStage,             	//开启副本
	BuyGold,               	//购买金币
	BuyChest,               //购买宝箱
	BuyOneClip,				//购买一个弹夹
	BuyFullClip				//补满子弹
]))
class MsgNet {}