package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class LiveNessInfo
{
	/**id*/
	public var Id:Int;
	/**活跃度获取规则*/
	public var name:String;
	/**次数*/
	public var Count:Int;
	/**活跃度数值*/
	public var Point:Int;
	/*任务类型*/
	public var TaskType:Int=0;
	
	/**完成次数*/
	public var Num:Int = 0;
	/**是否已领取*/
	public var isDraw:Int = 0;
	
	/**奖励*/
	public var reward:Dynamic;

	public function new() 
	{
		
	}
	
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "ID");
		name = XmlUtils.GetString(data, "Name");
		Count = XmlUtils.GetInt(data, "Count");
		Point = XmlUtils.GetInt(data, "Point");
		TaskType = XmlUtils.GetInt(data, "Type");
		//reward = XmlUtils.GetInt(data, "Reward");
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