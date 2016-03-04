package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * atk值 = actorInfo.hp/rate2*5
 * hp值 = actorInfo.dps*rate1
 * @author weeky
 */
class ActorPropertyInfo
{
	public var Lv:Int;
	/**模型类型*/
	public var HP:Int;
	/**模型资源类型*/
	public var ATK:Int;
	/**是否翻转*/
	public var CD:Float; 
	/**是否飞行*/
	public var DEF:Int;
	/**缩放*/
	public var DPS:Int;
	public function new() 
	{
	}
	public function readXml(data:Fast):Void
	{
		Lv = XmlUtils.GetInt(data, "Level");
		HP = XmlUtils.GetInt(data, "HP");
		ATK = XmlUtils.GetInt(data, "ATK");
		CD = XmlUtils.GetFloat(data, "CD");
		DEF = XmlUtils.GetInt(data, "DEF");
		DPS = XmlUtils.GetInt(data, "DPS");
	}
}