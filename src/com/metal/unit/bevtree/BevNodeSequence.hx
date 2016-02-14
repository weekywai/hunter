package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;

/**
 * BevNodeSequence
 * @author li
 */
class BevNodeSequence extends BevNode
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
		
		var index:Int = _currentNodeIndex;
		if (index == -1)
			index = 0;
			
		if (checkIndex(index))
		{
			if (_children[index].evaluate(input))
				return true;
		}
		
		return false;
	}
	
	override public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doTick(input, output);
		
		var isFinish:Int = BevNode.BRS_FINISH;
		
		if (_currentNodeIndex == -1)
			_currentNodeIndex = 0;
		
		isFinish = _children[_currentNodeIndex].tick(input, output);
		if (isFinish != 0)
		{
			++_currentNodeIndex;
			if (_currentNodeIndex == _children.length)
				_currentNodeIndex = -1;
			else
				isFinish = BevNode.BRS_EXECUTING;
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