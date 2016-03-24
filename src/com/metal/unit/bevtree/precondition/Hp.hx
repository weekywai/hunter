package com.metal.unit.bevtree.precondition;
import com.metal.unit.bevtree.BevNodeInputParam;
import com.metal.unit.bevtree.data.MonsterInputData;

/**
 * 当前血量的判断条件
 * @author li
 */
class Hp extends BevNodePrecondition
{
	private var _currentHP:Float;
	private var _maxHP:Float;
	private var _range1:Float;
	private var _range2:Float;
	private var _type:Bool;
	
	/**
	* 输入最大血量的百分比区间，默认情况下是判断当前血量是否大于零
	* @param range1, range2, type(类型判断，true:判断hp是否大于零，false:判断hp是否小于零)
	*/
	public function new(range1:Float = 0, range2:Float = 0, type:Bool = true) 
	{
		super();
		_range1 = range1;
		_range2 = range2;
		_type = type;
	}
	
	override public function evaluate(input:BevNodeInputParam):Bool 
	{
		//trace("hp");
		super.evaluate(input);
		var inputData:MonsterInputData = cast(input, MonsterInputData);
		_currentHP = inputData.CurrentHP;
		_maxHP = inputData.MaxHp;
		if (_range1 == 0 && _range2 == 0)
		{
			if (_type)
			{
				if (_currentHP > 0)
					return true;
				return false;
			}
			else
			{
				if (_currentHP <= 0 )
					return true;
				return false;
			}
		}
		else
		{
			if (_currentHP > _maxHP * _range1 && _currentHP <= _maxHP * _range2)
				return true;
			return false;
		}
	}
}