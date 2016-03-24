package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * ...
 * @author weeky
 */
class VictoryEscape extends BevNodePrecondition
{
	public function new()
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		if (inputData.isEscape == 2 && inputData.Victory) {
			return true;
		}
		return false;
	}
	
}