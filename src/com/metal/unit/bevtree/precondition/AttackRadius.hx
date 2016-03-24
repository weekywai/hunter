package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.data.MonsterInputData;
import openfl.geom.Point;

/**
 * 攻击范围判断条件
 * @author li
 */
class AttackRadius extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.TargetPoint == null)
			return false;
		var distance:Float = GetDistance2(inputData.TargetPoint, inputData.SelfPoint);
		//trace(bg_width * inputData.AttackingRadius + " "  + distance);
		if (bg_width * inputData.AttackingRadius >= distance)
		{
			//trace("attack true");
			return true;
		}
		return false;
	}
	
	private function GetDistance2(p1:Point, p2:Point):Float
	{
		return Point.distance(p1, p2);
		//var x:Float = p1.x - p2.x;
		//var y:Float = p1.y - p2.y;
		//return Math.sqrt(x * x + y * y);
	}	
}