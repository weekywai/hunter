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
	public var Name:String;
	public var isDraw:Int = 0;//是否已领取
	public var Num:Int;
	public var Description:String;
	public function new() 
	{
		//Id = 1;
		//newsName = "封测奖励";
		//isDraw = 0;
		//newsNum = 100000;
		//newsDesc = "所有玩家";
	}
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		Name = data.Name;
		Description= data.Description;
		Num= data.Num;
	}
}