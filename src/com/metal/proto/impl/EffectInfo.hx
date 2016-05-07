package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class EffectInfo
{
	/**id*/
	public var Id:Int;
	/**动画类型*/
	public var type:Int;
	/**类型参数*/
	public var res:String;
	/**播放类型*/
	public var kind:Int;
	/**播放速度*/
	public var speed:Float;
	
	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		Id = data.ID;
		type = data.Type;
		res = data.Res;
		kind = data.Kind;
		speed = data.speed;
	}
}