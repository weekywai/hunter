package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 站前准备信息
 * @author li
 */
class BattlePrepareInfo
{
	public var ID:Int; 		//物品ID
	public var MaxNum:Int;	//可购买最大值
	public var HasNum:Int;	//已有的数量
	public var SkillId:Int;	//技能ID
	public var Gold:Int;		//购买需要金币数量
	public var Dimond:Int;	//购买需要钻石数量
	public var useType:Int;	//使用类型
	
	public function new() 
	{
		HasNum = 0;
	}
	
	public function readXml(data:Fast):Void
	{
		ID = XmlUtils.GetInt(data, "ID");
		MaxNum = XmlUtils.GetInt(data, "MaxNum");
		SkillId = XmlUtils.GetInt(data, "Skills");
		Gold = XmlUtils.GetInt(data, "Gold");
		Dimond = XmlUtils.GetInt(data, "Dimond");
		useType = XmlUtils.GetInt(data, "UseType");
	}
	
}