package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;

/**
 * ...
 * @author li
 */
class BevNodeNonePrioritySelector extends BevNodePrioritySelector
{

	public function new(debugName:String=null) 
	{
		super(debugName);
	}
	
	override public function doEvaluate(input:BevNodeInputParam):Bool 
	{
		if (checkIndex(_currentSelectedIndex))
		{
			if (_children[_currentSelectedIndex].evaluate(input))
			{
				return true;
			}
		}
		
		return super.doEvaluate(input);
	}
	
}