package com.metal.unit.bevtree;
import com.haxepunk.HXP;
import openfl.Lib;

/**
 * BevNodePrecondition
 * @author li
 */
class BevNodePrecondition
{
	private var bg_width:Float;
	private var bg_heght:Float;
	
	public function new() 
	{
		bg_width = HXP.width;
		bg_heght = HXP.height;
	}
	
	public function evaluate(input:BevNodeInputParam):Bool
	{
		//throw("This is an abstract method. You need to implement yourself.");
		return true;
	}
}