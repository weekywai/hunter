package com.metal.proto.impl;

/**
 * atk值 = actorInfo.hp/rate2*5
 * hp值 = actorInfo.dps*rate1
 * @author weeky
 */
class ActorPropertyInfo
{
	public var Level:Int;
	/**模型类型*/
	public var HP:Int;
	/**模型资源类型*/
	public var ATK:Int;
	/**是否翻转*/
	public var CD:Float; 
	/**是否飞行*/
	public var DEF:Int;
	/**缩放*/
	public var DPS:Int;
	public function new() 
	{
	}
	public function readXml(data:Dynamic):Void
	{
		Level = data.Level;
		HP = data.HP;
		ATK = data.ATK;
		CD = data.CD;
		DEF = data.DEF;
		DPS = data.DPS;
	}
}