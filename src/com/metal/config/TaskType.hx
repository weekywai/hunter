package com.metal.config;

/**
 * 任务类型
 * @author ...
 */
class TaskType
{
	//--------------------type-----------------------
	/**主线任务*/
	public static var MainTask:Int = 0;
	/**支线任务*/
	public static var BranchTask:Int = 1;
	/**日常任务*/
	public static var DailyTask:Int = 2;
	/**成就任务*/
	public static var AchievementTask:Int = 3;
	
	
	
	//--------------------RunType-----------------------
	/**对话*/
	public static var Talk:Int = 0;
	/**杀怪*/
	public static var KillMonster:Int = 1;
	/**通关关卡*/
	public static var FinishMission:Int = 2;
	/**强化次数*/
	public static var Strengthen:Int = 3;
	/**消费钻石*/
	public static var ConsumeDiamond:Int = 4;
	/**充值*/
	public static var Recharge:Int = 5;
	/**进阶次数*/
	public static var AdvancedTimes:Int = 6;	
	/**角色等级*/
	public static var Level:Int = 7;
	/**强化等级*/
	public static var StrengthenLevel:Int = 8;
	/**进阶等级*/
	public static var AdvancedLevel:Int = 9;		
	/**寻宝*/
	public static var Treasure:Int = 10;
	/**分解装备*/
	public static var Decompose:Int = 11;
	/**进行一次无尽关卡*/
	public static var EndlessMode:Int = 12;
	/**进行一次武器副本*/
	public static var WeaponMode:Int = 13;
	/**进行一次防具副本*/
	public static var ArmorMode:Int = 14;
	/**进行一次金钱副本*/
	public static var MoneyMode:Int = 15;
	/**购买一次体力*/
	public static var BuyPower:Int = 16;
	
	public function new() 
	{
		
	}
	
}