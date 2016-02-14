package com.metal.scene.board.api;
import com.metal.config.UnitModelType;
/**
 * 单元物理阵营
 * @author weeky
 */
class BoardFaction 
{
	/**碰撞类型*/
	public static var collideType:Array<String> = ["",UnitModelType.Solid, UnitModelType.Player, UnitModelType.Unit, UnitModelType.Vehicle, UnitModelType.Block, UnitModelType.Boss, UnitModelType.Elite];
	public static function getType(type:Int):String { 
		switch(type) {
			case Solid:
				return UnitModelType.Solid;
			case Player:
				return UnitModelType.Player;
			case Enemy, FlyEnemy:
				return UnitModelType.Unit;
			case Block:
				return UnitModelType.Block;
			case Item:
				return UnitModelType.DropItem;
			case Vehicle:
				return UnitModelType.Vehicle;
			case Npc:
				return UnitModelType.Npc;
			case Boss, Boss1:
				return UnitModelType.Boss;
			case Elite, Machine:
				return UnitModelType.Elite;
			default:
				return null;
		}
	}
	
	/**获取阵型*/
	public static function getFaction(modelType:Int):Int 
	{
		switch(modelType) {
			case 3:
				return BoardFaction.Machine;
			case 4: 
				return BoardFaction.FlyEnemy;
			case 5: 
				return BoardFaction.Block;
			case 6, 7: 
				return BoardFaction.Elite;
			case 8: 
				return BoardFaction.Npc;
			case 11, 14: 
				return BoardFaction.Boss1;
			case 12, 13, 15: 
				return BoardFaction.Boss;
			default: //1,2
				return BoardFaction.Enemy;
		}
	}
	public static inline var None:Int = 0;
	public static inline var Solid:Int = 1;
	public static inline var Player:Int = 2;
	public static inline var Enemy:Int = 3;
	public static inline var FlyEnemy:Int = 4;
	public static inline var Block:Int = 5;
	public static inline var Item:Int = 6;
	public static inline var Vehicle:Int = 7;
	public static inline var Npc:Int = 8;
	public static inline var Boss:Int = 9;
	public static inline var Boss1:Int = 10;
	public static inline var Machine:Int = 11;
	public static inline var Elite:Int = 12;
}