package com.metal.message;

/**
 * UI界面事件
 * @author 
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	GMLogin,//GM命令跳过登录
	Loading,			//loading界面
	SkillCD,
	GoodsTip,           //宝箱获取物品界面
	SeekTreasures,        //宝箱界面
	Task,				//任务界面
	StopGame,           //暂停游戏
	oneNews,			//消息
	GameSet	,			//游戏设置
	GameNoviceCourse,	//游戏新手指引
	ScreenMessage,		//屏幕消息
	InitThumb,		//初始预览
	FinishBattleTip,     //完成关卡
	Dilaogue,     		//对话框
	Control
]))
class MsgUI2{}