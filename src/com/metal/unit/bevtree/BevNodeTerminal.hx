package com.metal.unit.bevtree;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeInputParam;

/**
 * BevNodeTerminal
 * @author li
 */
class BevNodeTerminal extends BevNode
{
	public static var STA_READY:Int = 0;
	public static var STA_RUNNING:Int = 1;
	public static var STA_FINISH:Int = 2;
	
	private var _status:Int = STA_READY;
	private var _needExit:Bool;

	public function new(debugName:String = null) 
	{
		super(debugName);
	}
	
	override public function doTick(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doTick(input, output);
		
		var isFinish:Int = BevNode.BRS_FINISH;
		
		if (_status == STA_READY)
		{
			doEnter(input);
			_needExit = true;
			_status = STA_RUNNING;
		}
		
		if (_status == STA_RUNNING)
		{
			isFinish = doExecute(input, output);
			if (isFinish == BevNode.BRS_FINISH || isFinish < 0)
			{
				_status = STA_FINISH;
			}
		}
		
		if (_status == STA_FINISH)
		{
			if (_needExit)
				doExit(input , isFinish);
				
			_status = STA_READY;
			_needExit = false;
		}
		
		return isFinish;
	}
	
	override public function doTransition(input:BevNodeInputParam):Void 
	{
		super.doTransition(input);
		
		if (_needExit)
			doExit(input, BevNode.BRS_ERROR_TRANSITION);
			
		_status = STA_READY;
		_needExit = false;
	}
	
	private function doEnter(input:BevNodeInputParam):Void
	{
		// nothing to do...implement yourself
	}
	
	private function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):Int
	{
		return BevNode.BRS_FINISH;
	}
	
	private function doExit(input:BevNodeInputParam, exitID:Int):Void
	{
		// nothing to do...implement yourself
	}
}