package com.metal.unit.bevtree.node;

import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.precondition.IsOnBornAction;
import com.metal.unit.bevtree.precondition.IsOnBornPos;

/**
 * 进场
 * @author li
 */
class Enter extends BevNodeTerminal
{
	private var _time:Int;
	public function new(debugName:String=null) 
	{
		super(debugName);
		_time = 55;
	}
	
	override function doEnter(input:BevNodeInputParam):Void 
	{
		super.doEnter(input);
		//var inputData:MonsterInputData = cast(input, MonsterInputData);
		//_time = inputData.BaseIdleTime;
	}
	
	override function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doExecute(input, output);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		var outputData:MonsterOutputData = cast(output, MonsterOutputData);
		if(inputData.SelfPoint!=null && inputData.BornPoint!=null){
			if (inputData.SelfPoint.x > inputData.BornPoint.x)
			{
				outputData.flipX = true;
			}
			else
			{
				outputData.flipX = false;
			}
		}
		if (!outputData.isEnter) {
			if(Std.is(_precondition, IsOnBornPos)){
				var dis = Math.abs(inputData.SelfPoint.x - inputData.BornPoint.x);
				if (dis <= 40) {
					outputData.isEnter = true;
				}
			}else if (Std.is(_precondition, IsOnBornAction)) {
				//trace(_time);
				if(_time<=0)
					outputData.isEnter = true;
				_time--;
			}
		}
		
		outputData.CurrentStatus = AIStatus.Enter;
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