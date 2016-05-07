package com.metal.config;

/**
 * ...
 * @author ...
 */
enum PlayerProp{
	LV;						// 等级
	ROLEID;					// 角色皮肤
	HP;						// 当前血量
	MP;						// 当前MP
	POWER;					// 当前体力
	DAY;					// 签到次数
	GEM;					// 钻石
	GOLD;					// 金币
	FIGHT;					// 战斗力
	MAX_MP;                 // 最大MP量
	MAX_HP;                 // 最大血量
	CRITICAL_LEVEL;			// 暴击值										
	STR;                 	// 力量
	STA;                 	// 体质
	WEAPON;                 // 武器
	ARMOR;					// 护甲
	SOUNDS;					// 游戏音效
	BGM;		     		// 背景音乐
	THROUGH;                //关卡进度
	HUNT;					//单次寻宝次数
	NOWTIME;				//当前时间
}

class PlayerPropType
{	
	
	public static var LV:Int              =   101;                   // 等级
	public static var ROLEID:Int          =   102;                   // 角色皮肤
	public static var HP:Int              =   103;                   // 当前血量
	public static var POWER:Int           =   104;                   // 当前体力
	public static var MP:Int      		  =   105;                   // 当前MP
	public static var SEX:Int             =   106;                   // 性别
	public static var EXP:Int             =   107;                   // 经验值
	public static var VIP:Int             =   109;                   // 玩家VIP等级
	public static var DAY:Int             =   110;                   // 签到次数
	public static var GEM:Int             =   116;                  // 钻石
	public static var BOUNDGEM:Int        =   117;                  // 绑定钻石
	public static var GOLD:Int            =   118;                  // 金币
	public static var FIGHT:Int			  =   140;				   // 战斗力
	public static var MAX_MP:Int          =   499;                 // 最大MP量
	public static var MAX_HP:Int          =   500;                 // 最大血量
	public static var MELEE_ATK:Int       =   501;                 // 物理攻击力
	public static var MELEE_DEF:Int       =   502;                 // 物理防御力
	public static var CRITICAL_RATE:Int   =   510;                 // 暴击率
	public static var CRITICAL_LEVEL:Int  =   551;         		   // 暴击值										
	public static var STR:Int             =   540;                 // 力量
	public static var STA:Int             =   541;                 // 体质
	public static var WEAPON:Int          =   542;                 // 武器
	public static var ARMOR:Int           =   543;                 // 护甲
	public static var SKILL1:Int          =   1;                 // 技能1
	public static var SKILL2:Int          =   2;                 // 技能2
	public static var SKILL3:Int          =   3;                 // 技能3
	public static var SKILL4:Int          =   4;                 // 技能4
	public static var SKILL5:Int          =   5;                 // 技能5
	public static var SOUNDS:Int         =   549;                // 游戏音效
	public static var BGM:Int            =   550;                // 背景音乐
	public static var THROUGH:Int        =   551;                //关卡进度
	public static var HUNT:Int           =   552;				 //单次寻宝次数

	public function new() 
	{
		
	}
	
}