package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 通关星级判断条件
 * @author 3D
 */
class GradeConditionInfo
{
	/**ID*/
	public var Id:Int;
	/**类型（0血量/1复活/2时间）*/
	public var ConditionType:Int;
	/**描述*/
	public var Description:String;
	/**条件限定数值*/
	public var Condition:String;
	//条件描述=txt1+conditional+txt2
	public var Txt1:String;
	public var Txt2:String;
	
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "Id");
		ConditionType = XmlUtils.GetInt(data, "ConditionType");
		Description = XmlUtils.GetString(data, "Description");
		Condition = XmlUtils.GetString(data, "Condition");
		Txt1 = XmlUtils.GetString(data, "Txt1");
		Txt2 = XmlUtils.GetString(data, "Txt2");		
	}
}