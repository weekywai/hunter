package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 宝箱掉落
 * @author hyg
 */
class TreasuerHuntInfo
{
	public var Id:Int;
	public var ItemList:String;
	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		ItemList = data.ItemList;
	}
	
}