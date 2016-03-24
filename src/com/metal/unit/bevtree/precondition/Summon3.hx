package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 使用固定召唤槽3里的召唤事件
 * @author li
 */
class Summon3 extends BevNodePrecondition
{

	public function new() 
	{
		super();	
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.CurrentAttackTimes == 20)
		{
			return true;
		}
		return false;
	}
	
}