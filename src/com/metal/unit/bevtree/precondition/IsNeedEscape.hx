package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 逃跑判断条件
 * @author li
 */
class IsNeedEscape extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.isEscape == 2)
			return true;
		return false;
	}
	
}