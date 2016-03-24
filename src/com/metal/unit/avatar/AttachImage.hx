package com.metal.unit.avatar;

import com.haxepunk.Graphic.ImageType;
import com.haxepunk.graphics.Image;
import com.metal.enums.Direction;
import openfl.geom.Rectangle;

/**
 * 
 * @author weeky
 */
class AttachImage extends Image implements IAttach
{

	public function new(?source:ImageType, ?clipRect:Rectangle) 
	{
		super(source, clipRect);
	}
	
	
	/* INTERFACE com.metal.unit.avatar.IAttach */
	
	@:isVar public var flip(get, set):Bool;
	function get_flip():Bool { return flipped; }
	function set_flip(value:Bool):Bool 
	{
		return flipped = value;
	}
	
	public function initAttach(callback:Dynamic = null):Void { }
	
	public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void { }
	
	inline public function as<T:IAttach>(clss:Class<T>):T
	{
		#if flash
		return untyped __as__(this, clss);
		#else
		return cast this;
		#end
	}
}