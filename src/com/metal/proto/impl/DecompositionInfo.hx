package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author hyg
 */
class DecompositionInfo
{
	public var Id:Int ;
	public var Items:Array<Array<Int>>;
	public function new() 
	{
		Items = new Array();
	}
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "ID");
		analytical(XmlUtils.GetString(data, "Items"));
	}
	private function analytical(str:String):Void
	{
		var arr1:Array<String> = str.split(",");
		Items = [];
		for (i in 0...arr1.length)
		{
			var str1:String = arr1[i];
			var arr2:Array<String> = str1.split("|");
			var arr3:Array<Int> = new Array();
			for (j in 0...arr2.length)
			{
				arr3.push(Std.parseInt(arr2[j]));
			}
			Items.push(arr3);
		}
	}
	
}