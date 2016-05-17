package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 随机名字数据
 * @author ...
 */
class RandomNameInfo
{
	/**判断性别id 1~1000男  1001~2000女*/
	public var id:Int;
	/**姓*/
	public var Surname:String;
	/**名*/
	public var Name:String;
	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		id = data.ID;
		Surname = data.Surname;
		Name = data.Name;
	}
	
}