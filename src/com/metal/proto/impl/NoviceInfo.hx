package com.metal.proto.impl;
import com.metal.utils.StringUtils;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author cqm
 */
class NoviceInfo
{
	public var ID:Int;
	public var text:String;

	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		ID = XmlUtils.GetInt(data, "ID");
		text = XmlUtils.GetString(data, "text");
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