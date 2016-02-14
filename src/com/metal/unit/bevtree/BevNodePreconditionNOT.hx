package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;

/**
 * ...
 * @author ...
 */
class BevNodePreconditionNOT extends BevNodePrecondition
{
	private var _a:BevNodePrecondition;
	
	public function new(a:BevNodePrecondition) 
	{
		super();
		if (a == null)
			throw("Invalid arguments!");
		_a = a;
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		return !_a.evaluate(input);
	}
	
}