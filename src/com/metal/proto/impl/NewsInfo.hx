package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author cqm
 */
class NewsInfo
{
	public var Id:UInt;
	public var newsName:String;
	public var isDraw:Int = 0;//是否已领取
	public var newsNum:Int;
	public var newsDesc:String;
	public function new() 
	{
		//Id = 1;
		//newsName = "封测奖励";
		//isDraw = 0;
		//newsNum = 100000;
		//newsDesc = "所有玩家";
	}
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "ID");
		newsName = XmlUtils.GetString(data, "Name");
		newsDesc= XmlUtils.GetString(data, "Description");
		newsNum= XmlUtils.GetInt(data, "Num");
	}
}