package com.metal.unit.bevtree.node;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.bevtree.data.AIStatus;

/**
 * 追击
 * @author li
 */
class Follow extends BevNodeTerminal
{

	public function new(debugName:String=null) 
	{
		super(debugName);
	}
	
	override function doEnter(input:BevNodeInputParam):Void 
	{
		super.doEnter(input);
	}
	
	override function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doExecute(input, output);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		var outputData:MonsterOutputData = cast(output, MonsterOutputData);
		if (inputData.SelfPoint.x > inputData.TargetPoint.x)
		{
			outputData.flipX = true;
		}
		else
		{
			outputData.flipX = false;
		}
		outputData.CurrentStatus = AIStatus.Follow;
		return BevNode.BRS_EXECUTING;
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