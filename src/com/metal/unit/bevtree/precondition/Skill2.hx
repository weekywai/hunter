package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 生命值第一次处于生命值上限20%-40%之间
 * 生命值第一次处于生命值上限40%-60%之间
 * 释放技能2
 * @author li
 */
class Skill2 extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.CurrentHP > inputData.MaxHp * 0.2 && inputData.CurrentHP <= inputData.MaxHp * 0.4 && !inputData.isFirstIn40 ||
			inputData.CurrentHP > inputData.MaxHp * 0.4 && inputData.CurrentHP <= inputData.MaxHp * 0.6 && !inputData.isFirstIn60)
		{
			return true;
		}
		return false;
	}
	
}