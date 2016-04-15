package com.metal.unit.bevtree.node;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.bevtree.data.AIStatus;

/**
 * 攻击
 * @author li
 */
class Attack extends BevNodeTerminal
{
	private var _time:Float; //攻击间隔
	private var _isFirstAttack:Bool; //首次攻击没有攻击间隔

	public function new(debugName:String=null) 
	{
		super(debugName);
		_isFirstAttack = true;
	}
	
	override function doEnter(input:BevNodeInputParam):Void 
	{
		super.doEnter(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		//_time = inputData.BaseAttackTime;
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
		outputData.CurrentStatus = AIStatus.Attack;
		if (inputData.isOnAttackStatus) 
		{			
			return BevNode.BRS_EXECUTING;
		}else 
		{
			return BevNode.BRS_FINISH;
		}
		//outputData.CurrentStatus = AIStatus.Attack;
		//if (--_time > 0)
		//{
			//if (_isFirstAttack)
			//{
				//outputData.isBaseAttack = false;
				//_isFirstAttack = false;
			//}
			//else
			//{
				//outputData.isBaseAttack = true;
			//}
			//return BevNode.BRS_EXECUTING;
		//}
		//else
		//{
			//outputData.isBaseAttack = false;
			//return BevNode.BRS_FINISH;
		//}
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