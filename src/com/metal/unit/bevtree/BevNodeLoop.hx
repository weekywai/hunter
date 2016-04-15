package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;

/**
 * ...
 * @author li
 */
class BevNodeLoop extends BevNode
{
	private var _loopCount:Int;
	private var _currentLoop:Int;

	public function new(debugName:String=null) 
	{
		super(debugName);
		_loopCount = -1;
		_currentLoop = 0;
	}
	
	public function setLoopCount(n:Int):BevNode
	{
		_loopCount = n;
		return this;
	}
	
	override public function doEvaluate(input:BevNodeInputParam):Bool 
	{
		super.doEvaluate(input);
		var checkLoop:Bool = (_loopCount == -1) || (_currentLoop < _loopCount);
		if (!checkLoop)
			return false;
		
		if (checkIndex(0))
			if (_children[0].evaluate(input))
				return true;
		
		return false;
	}
	
	override public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doTick(input, output);
		
		var isFinish:Int = BevNode.BRS_FINISH;
		
		if (checkIndex(0))
		{
			isFinish = _children[0].tick(input, output);
			
			if (isFinish == BevNode.BRS_FINISH)
			{
				if (_loopCount == -1)
					isFinish = BevNode.BRS_EXECUTING;
				else
				{
					++_currentLoop;
					if (_currentLoop < _loopCount)
						isFinish = BevNode.BRS_EXECUTING;
				}
			}	
		}
		
		if (isFinish == BevNode.BRS_FINISH)
			_currentLoop = 0;
		
		return isFinish;
	}
	
	override public function doTransition(input:BevNodeInputParam):Void 
	{
		super.doTransition(input);
		if (checkIndex(0))
			_children[0].transition(input);
		
		_currentLoop = 0;
	}
	
}