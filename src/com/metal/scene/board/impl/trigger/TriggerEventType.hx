package com.metal.scene.board.impl.trigger;

/**
 * ...
 * @author 3D
 */
class TriggerEventType
{

	public function new() 
	{
		
	}
	/**新手引导*/
	public static var NewBie:String = "0";
	/**怪物出场*/
	public static var ShowMonster:String = "1";
	
	/**锁屏 解锁条件为清完锁屏时出场的怪**/
	public static var Lock:String = "2";
	
	/**解锁*/
	public static var UnLock:String = "3";
	
	/**通知怪物进场**/
	public static var CallMonsters:String = "4";
	
	/**正常锁频*/
	public static var NorMalLock:String = "5";
	
	/**直接通关*/
	public static var VictoryPlace:String = "6";
	
	/**触发当前屏幕隐藏类（7）怪物生成*/
	public static var ShowCameraMonster:String = "7";
	
	/**在当前屏幕所有隐藏类（7）怪物的出生位置，随机生成怪物（怪物ID及生成几率根据出生位置所配置的ID种类及各种类数量决定）*/
	public static var ShowRandomMonster:String = "8";
	
	/**清场解锁**/
	public static var ClearUnLock:String = "99";
}