package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 生命值第一次处于生命值上限60%-80%之间
 * 释放技能1
 * @author li
 */
class Skill1 extends BevNodePrecondition
{

	public function new() 
	{
		super();
		
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.CurrentHP > inputData.MaxHp * 0.6 && inputData.CurrentHP <= inputData.MaxHp * 0.8 && !inputData.isFirstIn80)
		{
			return true;
		}
		return false;
	}
	
}