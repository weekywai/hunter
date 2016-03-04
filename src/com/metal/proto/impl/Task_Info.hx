package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class Task_Info
{

	/**id*/
	public var Id:Int;
	/**任务名称*/
	public var name:String;
	/**任务类型*/
	public var taskType:String;

	public function new() 
	{
		
	}
	
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "ID");
		name = XmlUtils.GetString(data, "Name");
		taskType = XmlUtils.GetString(data, "taskType");
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