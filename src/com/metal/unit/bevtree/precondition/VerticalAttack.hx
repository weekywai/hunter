package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;
import openfl.geom.Point;

/**
 * 攻击垂直范围判断条件
 * @author li
 */
class VerticalAttack extends BevNodePrecondition
{

	public function new() 
	{
		super();
		
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		//trace(inputData.SelfPoint.x + " : " + inputData.TargetPoint.x);
		if (getRange(inputData.SelfPoint, inputData.TargetPoint) <= 25)
		{
			return true;
		}
		return false;
	}
	
	private function getRange(pos1:Point, pos2:Point):Float
	{
		return Math.abs(pos1.x - pos2.x);
	}
}