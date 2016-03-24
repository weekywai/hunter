package com.metal.proto.impl;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class SkillInfo
{
	/**id*/
	public var Id:Int;
	/**技能名称*/
	public var Name:String;
	/**技能注解*/
	public var Desc:String;
	/**技能类型*/
	public var Kind:Int;
	/**锁怪类型*/
	public var Lock:Int;
	/**释放CD时间*/
	public var CDTime:Float;
	/**消耗怒气*/
	public var Consume:Int;
	/**攻击半径*/
	public var attradius:Float;
	/**攻击类型*/
	public var AttackType:Int;
	/**子弹ID*/
	public var BulletID:Int;
	/**散射角度*/
	public var angle:Int;
	/**子弹数量**/
	public var num:Int;
	/**连发间隔*/
	public var interval:Float;
	/**BUFF挂载目标*/
	public var buffTarget:Int;
	
	public var Radius:Int;
	/**效果脚本*/
	public var Effect:Array<Int>;
	/**挂载BUFF ID*/
	public var buffId:Int;
	/**BUFF持续时间*/
	public var buffTime:Int;
	//public var Render
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		Id = XmlUtils.GetInt(data, "SN");
		Name = XmlUtils.GetString(data, "Name");
		Desc = XmlUtils.GetString(data, "Desc");
		Kind = XmlUtils.GetInt(data, "Type");
		Lock = XmlUtils.GetInt(data, "Lock");
		CDTime = XmlUtils.GetFloat(data, "CDTime");
		Consume = XmlUtils.GetInt(data, "Consume");
		attradius = XmlUtils.GetFloat(data, "attradius");
		AttackType = XmlUtils.GetInt(data, "AttackType");
		BulletID = XmlUtils.GetInt(data, "BulletID");
		angle = XmlUtils.GetInt(data, "angle");
		num = XmlUtils.GetInt(data, "num");
		interval = XmlUtils.GetFloat(data, "interval");
		buffTarget = XmlUtils.GetInt(data, "bufftarget");
		buffId = XmlUtils.GetInt(data, "buffid");
		buffTime = XmlUtils.GetInt(data, "bufftime");
		Radius = XmlUtils.GetInt(data, "Radius");
		Effect = praseEfect(XmlUtils.GetString(data, "Effect"));
	}
	
	private function praseEfect(data:Dynamic):Array<Int>
	{
		var temp:Array<Int> = [];
		var ary = Std.string(data).split(",");
		for (i in 0...ary.length) 
		{
			temp.push(StringUtils.GetInt(ary[i]));
		}
		return temp;
	}
}