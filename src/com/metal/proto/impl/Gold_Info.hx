package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
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
	
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		Description = data.Description;
		Gold = data.Gold;
		Price = data.Price;
		Proportion = data.Proportion;
	}
}