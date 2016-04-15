package com.metal.config;
import com.metal.proto.impl.EquipItemBaseInfo;
import com.metal.proto.impl.StrengthenInfo;
import com.metal.proto.manager.ForgeManager;

/**
 * ...
 * @author ...
 */
class EquipProp
{

	public function new() 
	{
		
	}
	
	/**lv color*/
	public static inline function levelColor(type:String):Int
	{
		switch(type) {
			case "1":
				return 0xffffff;/**WHITE*/
			case "2":
				return 0x73f936;/**GREEN*/
			case "3":
				return 0x478ae2;/**BLUE*/
			case "4":
				return 0xf557f6;/**GREEN*/
			default:
				return 0;
		}
	}
	public static inline function Strengthen(info:EquipItemBaseInfo, lv:Int):StrengthenInfo
	{
		return ForgeManager.instance.getProtoForge(info.equipType * 1000 + lv);
	}
	
	public static inline function compute(atk:Int, strengRate:Float):Int
	{
		return Std.int(atk * strengRate / 10000);
	}
}