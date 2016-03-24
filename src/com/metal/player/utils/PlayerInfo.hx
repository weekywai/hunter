package com.metal.player.utils;
import haxe.ds.IntMap;

/**
 * ...
 * @author weeky
 */
class PlayerInfo
{
	public var Id:Int;		//对象ID
	public var RoleId:Int;	//角色ID
	public var Name:String;	//名字
	//public var Level:Int;	//等级
	//public var Gender:Int;	//性别
	//public var Job:Int;		//职业
	//public var EXP:Int;		//经验
	//public var Gem:Int;		//宝石数量
	//public var BoundGem:Int;//绑定宝石数量
	//public var Gold:Int;	//金币数量
	public var Vit:Int;		//体力
	//public var VIP:Int;		//角色VIP等级
	//public var Fight:Int;	//战斗力
	public var PlayerPartner:PartnerInfo; //自己的信息(角色在伙伴数据库的信息)
	public var Partner:Array<PartnerInfo>; //伙伴的信息和属性
	
	public var PlayerInfoMap:IntMap<Int>;
	public var res:Int = 1001;
	public var vehicle:Int = 2001;
	public var buffID:Int;
	
	public function new() 
	{
		Partner = new Array();
		PlayerInfoMap = new IntMap();
	}
	
	public function setProperty(key:Int, value:Int):Void
	{
		PlayerInfoMap.set(key, value);
	}
	public function getProperty(key:Int):Int
	{
		return PlayerInfoMap.get(key);
	}
	
}