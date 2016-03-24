package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;

/**
 * ...
 * @author li
 */
class BevNodePrioritySelector extends BevNode
{
	private var _currentSelectedIndex:Int;
	private var _lastSelectedIndex:Int;
	
	public function new(debugName:String=null) 
	{
		super(debugName);
		_currentSelectedIndex = -1;
		_lastSelectedIndex = -1;
	}
	
	override public function doEvaluate(input:BevNodeInputParam):Bool 
	{
		super.doEvaluate(input);
		
		_currentSelectedIndex = -1;
		
		var len:Int = _children.length;
		for (i in 0 ... len)
		{
			if (_children[i].evaluate(input))
			{
				_currentSelectedIndex = i;
				return true;
			}
		}
		return false;
	}
	
	override public function doTransition(input:BevNodeInputParam):Void 
	{
		super.doTransition(input);
		
		if (checkIndex(_lastSelectedIndex))
		{
			_children[_lastSelectedIndex].transition(input);
		}
		_lastSelectedIndex = -1;
	}
	
	override public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doTick(input, output);
		
		var isFinish:Int = BevNode.BRS_FINISH;
		
		if (checkIndex(_currentSelectedIndex))
		{
			if (_currentSelectedIndex != _lastSelectedIndex)
			{
				if (checkIndex(_lastSelectedIndex))
				{
					_children[_lastSelectedIndex].transition(input);
				}
				_lastSelectedIndex = _currentSelectedIndex;
			}
		}
		
		if (checkIndex(_lastSelectedIndex))
		{
			isFinish = _children[_lastSelectedIndex].tick(input, output);
			if (isFinish == BevNode.BRS_FINISH)
				_lastSelectedIndex = -1;
		}
		
		return isFinish;
	}
	
}