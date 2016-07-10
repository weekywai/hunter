package com.metal.message;

/**
 * ...界面更新数据
 * @author hyg
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	StartBattle,			//
	Warehouse,      		//仓库更新
	Strengthen,      		//强化更新  
	Vit,					//体力
	Skill,      			//技能解锁
	Reward,      			//奖励界面
	BossInfoUpdate,			//boss属性更新
	UpdateInfo,				//更新角色属性 
	Update,					//更新 {type:UIUpdateType,data:}
	UpdateModel,          	//更新模型
	UpdataReturnBtn,     	//返回按钮状态更新
	ClearMainView,     		//清除返回按钮记录
	UpdateScore,			//更新分数
	SkillCD,           		//技能冷却到数
	UpdateResources,    	//更新角色资源
	NewBieUI,           	 	//新手战斗UI
	UpdateThumb,           	 	//更新预览 
	NewBie,					//新手引导
	ForgeUpdate,			//锻造
	UpdateCountDown,		//更新倒计时
	UpdateBullet,			//更新子弹
	UpdateMissionTxt		//更新关卡任务
]))
class MsgUIUpdate{}