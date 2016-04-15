package com.metal.unit.avatar;
import com.metal.enums.Direction;

/**
 * @author weeky
 */
interface IAttach 
{
	public var flip(get, set):Bool;
	
	public var color(get, set):Int;
	
	public function destroy():Void;
	
	public function update():Void;
   
	public function initAttach(callback:Dynamic = null):Void;
	
	public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void;
	
	public function as<T:IAttach>(clss:Class<T>):T;
}