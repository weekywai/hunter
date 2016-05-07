package com.metal.proto.impl;
import com.metal.utils.FileUtils.ActiveVo;
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
	public var Name:String;
	/**次数*/
	public var Count:Int;
	/**活跃度数值*/
	public var Point:Int;
	/*任务类型*/
	public var TaskType:Int=0;
	
	public var vo:ActiveVo;
	/**完成次数*/
	//public var Num:Int = 0;
	/**是否已领取*/
	//public var isDraw:Int = 0;
	
	/**奖励*/
	public var reward:Dynamic;

	public function new() 
	{
		
	}
	
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		Name = data.Name;
		Count = data.Count;
		Point = data.Point;
		TaskType = data.Type;
		//reward = data.Reward;
		vo = { Id:Id, Draw:0, Times:0 };
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