package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 屏蔽字库信息
 * @author ...
 */
class FilterInfo
{
	/**名字id*/
	public var id:Int;
	/**名字*/
	public var name:String;
	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		id = data.ID;
		name = data.String;
	}
	
}