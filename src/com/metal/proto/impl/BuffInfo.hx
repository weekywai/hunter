package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class BuffInfo
{
	public var Id:Int = 0;
	public var typeId:Int;
	public var kind:Int = 0;
	public var level:Int = 0;
	public var name:String;
	public var desc:String;
	public var EffectScript:Array<Int>;
	public var areaDamage:Int = 0;
	public var overlap:Int = 0;
	public var icon:String = "";
	public var res:String = "";
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "SN");
		typeId = XmlUtils.GetInt(data, "BuffID");
		level = XmlUtils.GetInt(data, "LV");
		name = XmlUtils.GetString(data, "Name");
		desc= XmlUtils.GetString(data, "Desc");
		kind= XmlUtils.GetInt(data, "Type");
		areaDamage = XmlUtils.GetInt(data, "AreaDamage");
		EffectScript = praseList(XmlUtils.GetString(data, "EffectScript"));
		overlap = XmlUtils.GetInt(data, "OverlapNum");
		icon = XmlUtils.GetString(data, "Icon");
		res = XmlUtils.GetString(data, "resIds");
	}
	private function praseList(data:Dynamic):Array<Int>
	{
		if (data == "")
			return null;
		var temp:Array<Int> = [];
		var ary = Std.string(data).split(",");
		for (i in 0...ary.length) 
		{
			temp.push(StringUtils.GetInt(ary[i]));
		}
		return temp;
	}
}