package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 是否处在攻击状态下的判断条件
 * @author li
 */
class NotOnAttackStatus extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.isOnAttackStatus)
		{
			return false; //处在攻击状态下，不做其他事
		}
		return true;
	}
	
}