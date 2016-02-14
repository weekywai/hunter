package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;

/**
 * ...
 * @author ...
 */
class BevNodeParallel extends BevNode
{
	public static var CON_OR:Int = 0;
	public static var CON_AND:Int = 1;
	
	private var _finishCondition:Int;
	private var _childrenStatus:Array<Int>;

	public function new(debugName:String=null) 
	{
		super(debugName);
		_finishCondition = CON_OR;
		_childrenStatus = new Array();
		
		resetChildrenStatus();
	}
	
	public function setFinishCondition(condition:Int):BevNode
	{
		_finishCondition = condition;
		return this;
	}
	
	override public function doEvaluate(input:BevNodeInputParam):Bool 
	{
		super.doEvaluate(input);
		
		var len:Int = _children.length;
		for (i in 0 ... len)
		{
			if (_childrenStatus[i] == BevNode.BRS_EXECUTING)
			{
				if (!_children[i].evaluate(input))
				{
					return false;
				}
			}
		}
		
		return true;
	}
	
	override public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doTick(input, output);
		
		var len:Int = _children.length;
		
		if (_finishCondition == CON_OR)
		{
			for (i in 0 ... len)
			{
				if (_childrenStatus[i] == BevNode.BRS_EXECUTING)
					_childrenStatus[i] = _children[i].tick(input, output);
					
				if (_childrenStatus[i] != BevNode.BRS_EXECUTING)
				{
					resetChildrenStatus();
					return BevNode.BRS_FINISH;
				}
			}
		}
		else if (_finishCondition == CON_AND)
		{
			var finishedCount:Int = 0;
			
			for (i in 0 ... len)
			{
				if (_childrenStatus[i] == BevNode.BRS_EXECUTING)
					_childrenStatus[i] = _children[i].tick(input, output);
					
				if (_childrenStatus[i] != BevNode.BRS_EXECUTING)
					++finishedCount;
			}
			
			if (finishedCount == len)
			{
				resetChildrenStatus();
				return BevNode.BRS_FINISH;
			}
		}
		else
		{
			throw("Unknown finish condition : " + _finishCondition);
		}
		
		return BevNode.BRS_EXECUTING;
	}
	
	override public function doTransition(input:BevNodeInputParam):Void 
	{
		super.doTransition(input);
		
		resetChildrenStatus();
		
		var len:Int = _children.length;
		for (i in  0 ... len)
			_children[i].transition(input);
	}
	
	private function resetChildrenStatus():Void
	{
		for (i in 0 ... BevNode.MAX_CHILDREN)
			_childrenStatus[i] = BevNode.BRS_EXECUTING;
	}
	
}