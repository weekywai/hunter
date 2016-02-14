package com.metal.unit.bevtree.data;

import com.metal.unit.bevtree.BevNodeOutputParam;
import openfl.geom.Point;

/**
 * 输出数据
 * @author li
 */
class MonsterOutputData extends BevNodeOutputParam
{
	public var CurrentPoint:Point;
	public var NextPoint:Point;
	public var FaceDirection:Float;
	public var CurrentStatus:String;
	public var flipX:Null<Bool>;
	public var SkillType:Int;
	public var SummonType:Int;
	public var isBaseAttack:Bool;			//是否是攻击间隔
	public var isBaseIdle:Bool;				//是否是待机间隔
	public var isEnter:Bool;
	
	public function new() 
	{
		super();
	}
	
}