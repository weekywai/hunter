package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author cqm
 */
class NoviceInfo
{
	public var Id:Int;
	public var text:String;

	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		text = data.text;
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