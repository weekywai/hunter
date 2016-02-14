package com.metal.proto.api;

	
/**
 * 单元基础 
 */
interface IUnitBasicInfo
{
	/** 键 */
	function Key():String;
	
	/** 名称 */
	function Name():String;
	
	/** 模型定义Key */
	//function Model():String;
	
	/** 单元类型 */
	function UnitType():String;
	
	/** 墙体碰撞检测 */
	function HitTestWall():Bool;
	
	/** 单元碰撞检测 */
	//function HitTestUnit():Bool;
	
	
	/** 是否可移动 */
	function CanMove():Bool;
	
	/** 是否可被攻击(排除攻击，子弹穿透) */
	//function Attackable():Bool;
	
	/** 是否可被保护(接受攻击，但不更改任何属性) */
	//function CanDamage():Bool;
	
	/** 摧毁后是否删除此单元 */
	//function DestroyDelete():Bool;

	/** 是否掉落物品 */
	//function DropItem():Bool;
	
	/** AI类型 */
	//function AI():String;
	
	/** AI攻击类型*/
	//function AIAttack():String;
	
	/** 击杀分数，如果填小于0，则统计伤害而非分数 */
	//function Score():Int;
	
	/** 专属于玩家的ID */
	function PlayerID():Int;
	

}