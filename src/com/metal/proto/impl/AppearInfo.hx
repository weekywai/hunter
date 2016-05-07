package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import openfl.geom.Point;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class AppearInfo
{	
	public var ID:Int;
	/**入场类型*/
	public var type:Int;
	/**延迟时间*/
	public var delay:Float; 
	/**间隔时间*/
	public var interval:Float; 
	/**怪物列表*/
	public var enemies:Array<Int>;
	/**怪物出生点*/
	public var BornAt:Array<Point>;
	/**怪物入场点*/
	public var EnAt:Array<Point>;
	/**怪物出场类型*/
	public var Enter:Int;
	public function new() 
	{
		enemies = [];
		BornAt = [];
		EnAt = [];
	}
	public function readXml(data:Dynamic):Void
	{
		ID = data.ID;
		type = data.Type;
		delay = data.Delayed;
		interval = data.Interval;
		enemies = parseList(data.MonsterList);
		BornAt = parsePoint(data.BornAt);
		EnAt = parsePoint(data.EnAt);
		Enter = data.Enter;
	}
	/*private function parseList(data:String):Array<Int>
	{
		var temp = [];
		var ary = [];
		data = data.substring(1, data.length - 1);
		temp = data.split(",");
		for (i in temp) 
		{
			ary.push(StringUtils.GetInt(i));
		}
		return ary;
	}*/
	private function parseList(data:Dynamic):Array<Int>
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
	private function parsePoint(data:Dynamic):Array<Point>
	{
		var ary:Array<Point> = new Array();
		var pos:Array<String> = new Array();
		pos = Std.string(data).split("|");
		for (i in pos)
		{
			var perPos:Array<String> = new Array();
			perPos = i.split(",");
			var point:Point = new Point();
			point.x = StringUtils.GetFloat(perPos[0]) / 100;
			point.y = StringUtils.GetFloat(perPos[1]) / 100;
			
			ary.push(point);
		}
		return ary;
	}
}