package com.metal.unit.bevtree;

/**
 * BevNode
 * @author li
 */
class BevNode
{
	public static var BRS_EXECUTING:Int = 0;
	public static var BRS_FINISH:Int = 1;
	public static var BRS_ERROR_TRANSITION:Int = -1;
	
	public static var MAX_CHILDREN:Int = 16;
	
	private var _debugName:String;
	private var _precondition:BevNodePrecondition;
	private var _children:Array<BevNode>;
	private var _parent:BevNode;
	
	/**
	 * constructor  
	 * @param debugName
	 */
	public function new(debugName:String = null) 
	{
		if(debugName != null)
			_debugName = debugName;
		else
			_debugName = "";
	}
	
	public function GetDebugName():String
	{
		return _debugName;
	}
	
	/**
	 * add a child of bevhaior node 
	 * @param node
	 * @return this
	 */
	public function addChild(node:BevNode):BevNode
	{
		if (_children == null)
			_children = new Array();
		if (_children.length == MAX_CHILDREN)
			throw(this + "overflow, max children number is " + MAX_CHILDREN);
		_children.push(node);
		node._parent = this;
		return this;
	}
	
	/**
	 * insert a child at the specified index 
	 * @param node
	 * @param index 
	 * @return this
	 */
	public function addChildAt(node:BevNode, index:Int)
	{
		this.addChild(node);
		
		if (index < 0)
			index = 0;
		else if (index > _children.length - 1)
			index = _children.length;
		var i:Int = _children.length - 1;
		while (i > index)
		{
			_children[i] = _children[i - 1];
			--i;
		}
		_children[index] = node;
		
		return this;
	}
	
	/**
	 * set the precondition 
	 * @param precondition
	 * @return this 
	 */
	public function setPrecondition(precondition:BevNodePrecondition):BevNode
	{
		_precondition = precondition;
		return this;
	}
	
	/**
	 * evaluate the node whether execute or not 
	 * @param input, input param
	 * @return 
	 */
	public function evaluate(input:BevNodeInputParam):Bool
	{
		//var ret:Bool = (_precondition == null) || _precondition.evaluate(input);
		var ret:Bool;
		if (_precondition == null)
			ret = true;
		else
			ret = _precondition.evaluate(input);
		return ret && doEvaluate(input);
	}
	
	/**
	 * transition to another node 
	 */
	public function transition(input:BevNodeInputParam):Void
	{
		doTransition(input);
	}
	
	/**
	 * on tick 
	 */
	public function tick(input:BevNodeInputParam, output:BevNodeOutputParam):Int
	{
		return doTick(input, output);
	}
	
	// ----------------------------------------------------------------
	// :: Override Methods
	/**
	 * inner evaluate 
	 * @param input
	 * @return 
	 */
	public function doEvaluate(input:BevNodeInputParam):Bool
	{
		return true;
	}
	
	public function doTransition(input:BevNodeInputParam):Void
	{
		// nothing to do ... implement yourself
	}
	
	public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int
	{
		return BRS_FINISH;
	}
	
	public function checkIndex(i:Int):Bool
	{
		return i > -1 && i < _children.length;
	}
	// ----------------------------------------------------------------
}