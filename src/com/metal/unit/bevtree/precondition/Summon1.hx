package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 使用固定召唤槽1里的召唤事件
 * @author li
 */
class Summon1 extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.CurrentAppearTimes == 5 || inputData.CurrentAppearTimes == 10 || inputData.CurrentAppearTimes == 15 
			|| inputData.CurrentAttackTimes == 5 || inputData.CurrentAttackTimes == 10 || inputData.CurrentAttackTimes == 15)
		{
			return true;
		}
		return false;
	}
	
}