package com.metal.unit.stat;

/**
 * @author weeky
 */

interface IStat 
{
	var hpMax(default, null):Int;
	var hp(default, null):Int;
	var speedAdd(default, null):Float;
	var shootspanAdd(default, null):Float;
	/**攻击力*/
	var atk(default, null):Int;
	/**攻击修正*/
	function damageModify(): Array<Int>;
	function MyBuff():Array<Buff>;
	function findStatusByKey(key:Int):Buff;
	/**积分比率*/
	function ScoreRate():Float;
	
	var holdFire(get, set):Bool;

}