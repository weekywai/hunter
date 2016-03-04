package com.utils;
import haxe.xml.Fast;

/**
 * ...
 * @author Simage
 */
class XmlUtils 
{
	public static function GetBool(xml:Fast, name:String, init:Bool = false):Bool {
		var str:String = xml.node.resolve(name).innerData;
		if (!StringUtils.IsNullOrEmpty(str)) {
			return str == "true";
		} else {
			return init;
		}
	}
	public static function GetInt(xml:Fast, name:String, init:Int = 0):Int {
		var str:String = xml.node.resolve(name).innerData;
		if (!StringUtils.IsNullOrEmpty(str)) {
			return Std.parseInt(str);
		} else {
			return init;
		}
	}
	public static function GetFloat(xml:Fast, name:String, init:Float = 0):Float {
		var str:String = xml.node.resolve(name).innerData;
		if (!StringUtils.IsNullOrEmpty(str)) {
			return Std.parseFloat(str);
		} else {
			return init;
		}
	}
	public static function GetString(xml:Fast, name:String, init:String = ""):String {
		var str:String = xml.node.resolve(name).innerData;
		if (!StringUtils.IsNullOrEmpty(str)) {
			return str;
		} else {
			return init;
		}
	}
}