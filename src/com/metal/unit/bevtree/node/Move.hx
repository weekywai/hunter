package com.metal.unit.bevtree.node;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;

/**
 * 移动
 * @author li
 */
class Move extends BevNodeTerminal
{
	private var _time:Float;
	private var _dir:Bool; //移动方向，false:右 true:左

	public function new(debugName:String=null, dir:Bool=false) 
	{
		super(debugName);
		_dir = dir;
	}
	
	override function doEnter(input:BevNodeInputParam):Void 
	{
		super.doEnter(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		_time = inputData.BaseMoveTime;
	}
	
	override function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doExecute(input, output);
		var outputData:MonsterOutputData = cast(output, MonsterOutputData);
		outputData.CurrentStatus = AIStatus.Move;
		outputData.flipX = _dir;
		if(--_time > 0)
			return BevNode.BRS_EXECUTING;
		else
			return BevNode.BRS_FINISH;
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