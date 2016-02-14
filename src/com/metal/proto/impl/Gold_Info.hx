package com.metal.proto.impl;
import com.metal.utils.StringUtils;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class Gold_Info
{
	/**id*/
	public var Id:Int;
	/**金币描述*/
	public var Description:String;
	/**获得金币*/
	public var Gold:Int;
	/**购买价格*/
	public var Price:Int;
	/**已送比例*/
	public var Proportion:Int;
	
	public function new() 
	{
		
	}
	
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "SN");
		Description = XmlUtils.GetString(data, "Description");
		Gold = XmlUtils.GetInt(data, "Gold");
		Price = XmlUtils.GetInt(data, "Price");
		Proportion = XmlUtils.GetInt(data, "Proportion");
	}
	
	private function praseEfect(data:Dynamic):Array<Int>
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