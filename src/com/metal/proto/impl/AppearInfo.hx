package com.metal.proto.impl;
import com.metal.utils.StringUtils;
import com.metal.utils.XmlUtils;
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
	public function readXml(data:Fast):Void
	{
		ID = XmlUtils.GetInt(data, "ID");
		type = XmlUtils.GetInt(data, "Type");
		delay = XmlUtils.GetFloat(data, "Delayed");
		interval = XmlUtils.GetFloat(data, "Interval");
		enemies = parseList(XmlUtils.GetString(data, "MonsterList"));
		BornAt = parsePoint(XmlUtils.GetString(data, "BornAt"));
		EnAt = parsePoint(XmlUtils.GetString(data, "EnAt"));
		Enter = XmlUtils.GetInt(data, "Enter");
	}
	private function parseList(data:String):Array<Int>
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
	}
	private function parsePoint(data:String):Array<Point>
	{
		var ary:Array<Point> = new Array();
		var pos:Array<String> = new Array();
		pos = data.split("|");
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