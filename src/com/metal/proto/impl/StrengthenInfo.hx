package com.metal.proto.impl;
import com.metal.proto.impl.WeaponInfo;
import com.utils.XmlUtils;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 装备强化属性值
 * @author ...
 */
class StrengthenInfo
{
	/**装备类型Id*/
	public var SnID:Int;
	/**当前强化等级*/
	public var strengthLevel:Int;
	/**生命**/
	public var HPvalue:Int;
	/**攻击**/
	public var Attack:Int;
	/**影响属性值*/
	public var DestParam:String;
	/**强化至此总经验*/
	public var MaxExp:Int;
	/**强化至此总金币*/
	public var MaxMoney:Int;
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		SnID = XmlUtils.GetInt(data, "SnID");
		//strengthLevel = XmlUtils.GetInt(data, "StrengthLevel");
		HPvalue = XmlUtils.GetInt(data, "Hp");
		Attack = XmlUtils.GetInt(data, "Att");
		//DestParam = data, "DestParam");
		MaxExp = XmlUtils.GetInt(data, "MaxExp");
		MaxMoney = XmlUtils.GetInt(data, "MaxMoney");
	}
	public function initDefaultValues():Void
	{
		SnID = 0;
		strengthLevel = 0;
		DestParam = "";
		MaxExp = 0;
		MaxMoney = 0;
	}
}