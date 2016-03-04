package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author hyg
 */
class MonsterAppearInfo
{
	public var ID:Int;
	/**出场方向*/
	public var Direction:Int;
	/**行为类型*/
	public var BehaviorType:Int;
	/**出场类型*/
	public var ApperType:Int;
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		ID = XmlUtils.GetInt(data, "ID");
		Direction = XmlUtils.GetInt(data, "Direction");
		BehaviorType = XmlUtils.GetInt(data, "BehaviorType");
		ApperType = XmlUtils.GetInt(data, "ApperType");
	}
	
}