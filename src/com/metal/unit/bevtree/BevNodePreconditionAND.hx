package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;

/**
 * ...
 * @author ...
 */
class BevNodePreconditionAND extends BevNodePrecondition
{
	private var _list:Array<BevNodePrecondition>;

	public function new(rest:Array<BevNodePrecondition>) 
	{
		super();
		if (rest.length < 2)
			throw("Invalid arguments!");
		_list = new Array();
		for (i in 0 ... rest.length)
		{
			_list[i] = rest[i];
		}
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		super.evaluate(input);
		for (i in 0 ... _list.length)
		{
			if (!_list[i].evaluate(input))
				return false;
		}
		return true;
	}
	
}