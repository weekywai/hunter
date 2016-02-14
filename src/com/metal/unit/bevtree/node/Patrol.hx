package com.metal.unit.bevtree.node;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.bevtree.data.AIStatus;

/**
 * 巡逻
 * @author li
 */
class Patrol extends BevNodeTerminal
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
		var outputData:MonsterOutputData = cast(output, MonsterOutputData);
		outputData.CurrentStatus = AIStatus.Patrol;
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