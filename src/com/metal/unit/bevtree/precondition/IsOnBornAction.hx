package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 是播放出生动作
 * @author weeky
 */
class IsOnBornAction extends BevNodePrecondition
{
	private var _time:Int;
	public function new() 
	{
		super();
		_time = 60;
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputdata:MonsterInputData = cast(input, MonsterInputData);
		if (_time <= 0)
			return false;
		_time--;
		return true;
	}
}