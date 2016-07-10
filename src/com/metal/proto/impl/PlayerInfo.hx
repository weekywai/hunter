package com.metal.proto.impl;

import haxe.ds.IntMap;
import com.metal.config.PlayerPropType;
typedef PlayerVo = {
	var Id:Int;		//对象ID
	var ROLEID:Int;	//角色ID
	var NAME:String;	//名字
	var LV:Int;		//等级
	var EXP:Int;		//经验
	var GEM:Int;		//宝石数量
	var GOLD:Int;	//金币数量
	var POWER:Int;		//体力
	var VIP:Int;		//角色VIP等级
	var DAY:Int;	//战斗力
	var MP:Int;	//战斗力
	var MAX_MP:Int;	//战斗力
	var HP:Int;	//战斗力
	var MAX_HP:Int;	//战斗力
	var FIGHT:Int;	//战斗力
	var CRITICAL_LEVEL:Int;	//战斗力
	var SKILL1:Int;	//战斗力
	var SKILL2:Int;	//战斗力
	var SKILL3:Int;	//战斗力
	var SKILL4:Int;	//战斗力
	var SKILL5:Int;	//战斗力
	var THROUGH:Int;	//战斗力
	var HUNT:Int;	//战斗力
	var NOWTIME:String;	//战斗力
	var WEAPON:Int;	//战斗力
	var ARMOR:Int;	//战斗力
	var SOUNDS:Int;	//战斗力
	var BGM:Int;	//战斗力
}
/**
 * ...
 * @author weeky
 */
class PlayerInfo
{
	//public var PlayerPartner:PartnerInfo; //自己的信息(角色在伙伴数据库的信息)
	//public var Partner:Array<PartnerInfo>; //伙伴的信息和属性
	public var data:PlayerVo;
	
	public var res:Int = 1001;
	public var vehicle:Int = 2001;
	
	public function new() 
	{
	}
	
	private function parse(obj:String):Array <Int>
	{
		var temp = obj.split(",");
		var list:Array <Int> = [];
		for (i in temp) 
		{
			list.push(Std.parseInt(i));
		}
		return list;
	}
}