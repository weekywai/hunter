package com.metal.unit.bevtree.node;

import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.BevNodeOutputParam;
import com.metal.unit.bevtree.BevNodeTerminal;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.bevtree.data.AIStatus;

/**
 * 技能
 * @author li
 */
class Skill extends BevNodeTerminal
{
	private var _skillType:Int;
	private var _isFirst:Bool;
	
	public function new(debugName:String = null, skillType:Int = 0) 
	{
		super(debugName);
		_skillType = skillType;
		_isFirst = true;
	}
	
	override function doEnter(input:BevNodeInputParam):Void 
	{
		super.doEnter(input);
		_isFirst = true;
	}
	
	override function doExecute(input:BevNodeInputParam, output:BevNodeOutputParam):Int 
	{
		super.doExecute(input, output);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		var outputData:MonsterOutputData = cast(output, MonsterOutputData);
		outputData.CurrentStatus = AIStatus.Skill;
		outputData.SkillType = _skillType;
		//trace("skill " + _skillType);
		if (_isFirst)
		{
			_isFirst = false;
			return BevNode.BRS_EXECUTING;
		}
		else
		{
			if (inputData.isOnAttackStatus)
			{
				//trace("skill executing");
				return BevNode.BRS_EXECUTING;
			}
			else
			{
				//trace("skill finish");
				return BevNode.BRS_FINISH;
			}
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