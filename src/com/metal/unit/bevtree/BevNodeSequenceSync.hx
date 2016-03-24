package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;

/**
 * ...
 * @author ...
 */
class BevNodeSequenceSync extends BevNode
{
	private var _currentNodeIndex:Int;
	
	public function new(debugName:String=null) 
	{
		super(debugName);
		_currentNodeIndex = -1;
	}
	
	override public function doEvaluate(input:BevNodeInputParam):Bool 
	{
		super.doEvaluate(input);
		var len:Int = _children.length;
		for (i in 0 ... len)
		{
			if (!_children[i].evaluate(input))
			{
				return false;
			}
		}
		
		return true;
	}
	
	override public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doTick(input, output);
		
		var isFinish:Int = BevNode.BRS_FINISH;
		if (_currentNodeIndex == -1)
			_currentNodeIndex = 0;
			
		while (true)
		{
			isFinish = _children[_currentNodeIndex].tick(input, output);
			if (isFinish != BevNode.BRS_FINISH)
				break;
			if (++_currentNodeIndex == _children.length)
			{
				_currentNodeIndex = -1;
				break;
			}
		}
		
		if (isFinish < 0)
			_currentNodeIndex = -1;
		return isFinish;
	}
	
	override public function doTransition(input:BevNodeInputParam):Void 
	{
		super.doTransition(input);
		if (checkIndex(_currentNodeIndex))
			_children[_currentNodeIndex].transition(input);
		_currentNodeIndex = -1;
	}
}