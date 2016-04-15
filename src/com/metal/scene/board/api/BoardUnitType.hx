package com.metal.scene.board.api ;
/**
 * 单元物理类型
 * @author weeky
 */
class BoardUnitType 
{
	
	private static var typeTrans:Array<String> = ["", "actor", "solid", "enemy", "blocker", "dropItem", "vehicle"];
	public static function getType(type:Int):String { return typeTrans[type]; }
	
	public static inline var Actor:Int = 1;
	public static inline var Enemy:Int = 2;
	public static inline var Solid:Int = 3;
	public static inline var Blocker:Int = 4;
	public static inline var DropItem:Int = 5;
	public static inline var Vehicle:Int = 6;
}