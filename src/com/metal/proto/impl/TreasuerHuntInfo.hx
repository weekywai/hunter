package com.metal.proto.impl;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 宝箱掉落
 * @author hyg
 */
class TreasuerHuntInfo
{
	public var id:Int;
	public var ItemList:String;
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		id = XmlUtils.GetInt(data, "ID");
		ItemList = XmlUtils.GetString(data, "ItemList");
	}
	
}