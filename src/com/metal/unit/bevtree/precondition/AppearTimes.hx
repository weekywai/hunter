package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 出场时间判断条件
 * @author li
 */
class AppearTimes extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.CurrentAppearTimes >= inputData.MaxAppearTimes)
			return true;
			
		return false;
	}
	
}