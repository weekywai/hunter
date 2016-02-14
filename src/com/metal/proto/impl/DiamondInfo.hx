package com.metal.proto.impl;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 购买钻石属性值
 * @author ...
 */
class DiamondInfo
{
	/**购买id*/
	public var id:Int;
	/**描述*/
	public var Description:String;
	/**获得*/
	public var Gold:Int;
	/**价格*/
	public var Price:Int;
	/**增送描述*/
	public var Proportion:String;
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		id = XmlUtils.GetInt(data, "SN");
		Description = XmlUtils.GetString(data, "Description");
		Gold = XmlUtils.GetInt(data, "Gold");
		Price = XmlUtils.GetInt(data, "Price");
		Proportion = XmlUtils.GetString(data, "Proportion");
	}
	public function initDefaultValues():Void
	{
		id = 0;
		Description = "";
		Gold = 0;
		Price = 0;
		Proportion ="";
	}
}