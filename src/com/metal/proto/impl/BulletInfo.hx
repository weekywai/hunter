package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class BulletInfo
{
	/**id*/
	public var Id:Int;
	/**子弹类型*/
	public var type:Int;
	/**类型参数*/
	public var param:Int;
	/**飞行速度*/
	public var speed:Int;
	/**子弹大小*/
	public var size:Int;
	/**子弹行为*/
	public var behavior:Int;
	/**BUFF挂载目标*/
	public var buffTarget:Int;
	/**挂载BUFF ID*/
	public var buffId:Int;
	/**BUFF持续时间*/
	public var buffTime:Int;
	/**动画类型**/
	public var buffMovieType:Int;
	/**子弹资源*/
	public var img:String;
	/**特效资源*/
	public var effId:Int;
	/**是否贯穿**/
	public var isThrough:Int;
	/**预警资源*/
	public var warning:String;
	
	public function new() 
	{
	}
	
	public function readXml(data:Dynamic):Void
	{
		Id = data.ID;
		type = data.type;
		param = data.param;
		speed = data.speed;
		size = data.size;
		behavior = data.effecttype;
		buffTarget = data.bufftarget;
		buffId = data.buffid;
		buffTime = data.bufftime;
		img = data.img;
		isThrough = data.IsThrough;
		buffMovieType = data.IsXml;
		effId = data.effimg;
		warning = data.warning;
	}
}