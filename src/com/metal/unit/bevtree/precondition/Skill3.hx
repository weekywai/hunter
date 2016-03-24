package com.metal.unit.bevtree.precondition;

import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 生命值第一次处于生命值上限0%-5%之间(不包含0%，0%时死亡)
 * 生命值第一次处于生命值上限5%-20%之间
 * 释放技能3
 * @author li
 */
class Skill3 extends BevNodePrecondition
{

	public function new() 
	{
		super();
		
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.CurrentHP > 0 && inputData.CurrentHP <= inputData.MaxHp * 0.05 && !inputData.isFirstIn05 ||
			inputData.CurrentHP > inputData.MaxHp * 0.05 && inputData.CurrentHP <= inputData.MaxHp * 0.2 && !inputData.isFirstIn20)
		{
			return true;
		}
		return false;
	}
	
}