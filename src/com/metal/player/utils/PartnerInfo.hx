package com.metal.player.utils;
import com.metal.config.PlayerPropType;
import haxe.ds.IntMap;

/**
 * ...
 * @author li
 */
class PartnerInfo
{
	public var PartnerId:Int; //伙伴的ID  
	public var RoleId:Int; //伙伴所在角色的ID  
	public var PartnerName:String; //伙伴的名字   
	public var PartnerSN:Int; //伙伴的SN   
	public var PartnerJob:Int; //伙伴的职业   
	public var PartnerAnger:Int; //伙伴的怒气
	public var PartnerType:Int; //当前伙伴是否为角色本身的标志  1 为角色 0为伙伴
	//public var LV:Int; //等级   
	//public var HP:Int; //血量   
	//public var EXP:Int; //经验
	//public var MELEE_ATK:Int; //攻击    
	//public var MELEE_DEF:Int; //防御    
	//public var CRITICAL_LEVEL:Int; //暴击值   
	//public var CRITICAL_RATE:Int; //暴击率   
	//public var STR:Int; //力量   
	//public var STA:Int; //体质   
	//public var DEX:Int; //护甲   
	//public var GS:Int; //战斗力   
	//public var ATK_SPEED:Int; //攻击速度   
	//public var SPEED:Int; //移动速度   
	
	public var PartnerInfoMap:IntMap<Int>;
	
	public function new() 
	{
		PartnerInfoMap = new IntMap();	
	}
	
	public function setProperty(key:Int, value:Int):Void
	{
		PartnerInfoMap.set(key, value);
	}
	public function getProperty(key:Int):Int
	{
		return PartnerInfoMap.get(key);
	}
	
}