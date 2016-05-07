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
	public function readXml(data:Dynamic):Void
	{
		Id = data.SN;
		Name = data.Name;
		Desc = data.Desc;
		Kind = data.Type;
		Lock = data.Lock;
		CDTime = data.CDTime;
		Consume = data.Consume;
		attradius = data.attradius;
		AttackType = data.AttackType;
		BulletID = data.BulletID;
		angle = data.angle;
		num = data.num;
		interval = data.interval;
		buffTarget = data.bufftarget;
		buffId = data.buffid;
		buffTime = data.bufftime;
		Radius = data.Radius;
		Effect = praseEfect(data.Effect);
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