package com.metal.message;

/**
 * 角色消息
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	AssignAccount,		//传入外部挂接的账号信息
	InitAccount,		//传入外部挂接的账号信息
	OtherPalyerInfo,	//其他角色信息
	UpdateInfo,			//更新角色信息	
	UpdateMoney,			//更新金币	
	UpdateGem,				//更新钻石
	UpdateResources,     //更新角色资源
	UpdateTask,           //更新任务信息
	QuestList,         //完成任务
	AddStatScore,		//得分记录
	AddStatKill,		//杀怪数
	ShootStart,				//射击 近攻
	Attack,					//攻击
	ChangeWeapon,			//更换武器
	ChangeWeaponLevel,			//更换武器等级
	ChangeSkill,			//更换技能
	ItemSkill,				//道具技能
	AddCollide,			//添加碰撞物体
	UpdateSkill,			//开启技能
	UpdateBGM,				//背景音乐
	UpdateSounds,			//游戏音效
	UpdateInitFileData,		//初始界面更新
	ConsumeBullet,			//消费子弹
	Reload					//装填子弹
]))
class MsgPlayer{}