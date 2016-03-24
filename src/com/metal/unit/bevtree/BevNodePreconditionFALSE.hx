package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;

/**
 * ...
 * @author ...
 */
class BevNodePreconditionFALSE extends BevNodePrecondition
{

	public function new() 
	{
		super();
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		return false;
	}
	
}