package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * atk值 = actorInfo.hp/rate2*5
 * hp值 = actorInfo.dps*rate1
 * @author weeky
 */
class ModelInfo
{
	public var ID:Int;
	/**模型类型*/
	public var type1:Int;
	/**模型资源类型*/
	public var type:Int;
	/**武器骨络名字*/
	public var gun1:Array<String>; 
	public var gun2:Array<String>;
	public var gun3:Array<String>;
	public var gun4:Array<String>;
	public var gun5:Array<String>;
	/**非碰撞骨骼*/
	//public var unSlot:Array<String>;
	/**是否翻转*/
	public var flip:Int; 
	/**是否飞行*/
	public var fly:Int = 1;
	/**缩放*/
	public var scale:Float=1;
	/**资源*/
	public var res:String;
	/**受击特效*/
	public var hit:Int = 0;
	public var skin:Int = 1;
	
	public var rate1:Float;
	public var rate2:Int;
	public function new() 
	{
	}
	public function readXml(data:Fast):Void
	{
		ID = XmlUtils.GetInt(data, "Id");
		type1 = XmlUtils.GetInt(data, "Type1");
		type = XmlUtils.GetInt(data, "Type");
		gun1 = parseList(XmlUtils.GetString(data, "gun1"));
		gun2 = parseList(XmlUtils.GetString(data, "gun2"));
		gun3 = parseList(XmlUtils.GetString(data, "gun3"));
		gun4 = parseList(XmlUtils.GetString(data, "gun4"));
		gun5 = parseList(XmlUtils.GetString(data, "gun5"));
		//unSlot = parseList(XmlUtils.GetString(data, "UnBone"));
		flip = XmlUtils.GetInt(data, "IsFlip");
		scale = XmlUtils.GetFloat(data, "Size");
		res = XmlUtils.GetString(data, "ModelPic");
		hit = XmlUtils.GetInt(data, "hit");
		skin = XmlUtils.GetInt(data, "skin");
		rate1 = XmlUtils.GetFloat(data, "rate1");
		rate2 = XmlUtils.GetInt(data, "rate2");
	}
	
	private function parseList(data:String):Array<String>
	{
		var temp = [];
		temp = data.split(",");
		return temp;
	}
}