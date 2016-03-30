package com.metal.message;

/**
 * UI界面事件
 * @author 
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	Tips,				//提示
	NewBie,				//新手
	MainPanel,          //主界面
	Battle,				//战斗界面
	Warehouse,          //仓库
	Forge,              //锻造
	LatestFashion,      //时装
	CreateModel,        //创建模型
	BossPanel,
	HintPanel,			//消息提示界面
	Through,     		//打开副本界面
	EndlessCopy,        //无尽副本界面    
	BattleResult,    	//打开副本胜利结算界面
	BattleFailure,    	//打开副本失败结算界面
	RevivePanel,        //买活界面
	BuyGold,            //购买金币
	BuyDiamonds,        //购买钻石
	TreasureHunt,       //购买宝箱
	AwardPanel,         //奖励任务界面
	RewardPanel,		//奖励活跃度界面
	GetChest,			//打开领取宝箱界面
	Skill,				//技能解锁界面
	UnclockSkill,		//解锁技能消
	Reward,				//奖励界面
	Recharge
]))
class MsgUI{}