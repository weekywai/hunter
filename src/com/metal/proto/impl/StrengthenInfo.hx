package com.metal.proto.impl;
import com.utils.XmlUtils;
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
	public function readXml(data:Dynamic):Void
	{
		SnID = data.SnID;
		//strengthLevel = data.StrengthLevel;
		HPvalue = data.Hp;
		Attack = data.Att;
		//DestParam = data.DestParam;
		MaxExp = data.MaxExp;
		MaxMoney = data.MaxMoney;
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