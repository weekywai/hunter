package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 是否到达出生点
 * @author li
 */
class IsOnBornPos extends BevNodePrecondition
{
	private var _isOnBornPos:Bool;

	public function new() 
	{
		super();
		_isOnBornPos = false;
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		var inputdata:MonsterInputData = cast(input, MonsterInputData);
		//trace("enter " + inputdata.SelfPoint.x + " " + inputdata.BornPoint.x);
		if(getRange(inputdata.SelfPoint.x, inputdata.BornPoint.x) > 30 && !_isOnBornPos)//|| getRange(inputdata.SelfPoint.y, inputdata.BornPoint.y) > 50)
		{
			return true;
		}
		else
		{
			_isOnBornPos = true;
		}
		return false;
		
	}
	private function getRange(sel:Float, born:Float):Float
	{
		return Math.abs(sel - born);
	}
	
}