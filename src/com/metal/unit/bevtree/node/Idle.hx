package com.metal.unit.bevtree.node;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.bevtree.data.AIStatus;

/**
 * 待机
 * @author li
 */
class Idle extends BevNodeTerminal
{
	private var _time:Float;

	public function new(debugName:String=null) 
	{
		super(debugName);
	}
	
	override function doEnter(input:BevNodeInputParam):Void 
	{
		super.doEnter(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		_time = inputData.BaseIdleTime;
		//trace("_time " + _time);
	}
	
	override function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doExecute(input, output);
		var outputData:MonsterOutputData = cast(output, MonsterOutputData);
		outputData.CurrentStatus = AIStatus.Idle;
		if (--_time > 0)
		{
			//trace("idle executing");
			return BevNode.BRS_EXECUTING;
		}
		else
		{
			//trace("idle finish");
			return BevNode.BRS_FINISH;
		}

	}
	
	override function doExit(input:BevNodeInputParam, exitID:Int):Void 
	{
		super.doExit(input, exitID);
	}
	
	override public function doTransition(input:BevNodeInputParam):Void 
	{
		super.doTransition(input);
	}
	
}