package com.metal.unit.avatar;

import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.enums.Direction;

/**
 * AttachSpine
 * @author weeky
 */
class AttachTexture extends TextrueSpritemap implements IAttach
{
	public function new(source:TextureAtlasFix) 
	{
		super(source);
	}
	
	public function initAttach(callback:Dynamic = null)
	{
		add("ani", _atlas.getReginCount(), 14);
		//frame = 0;
		if(callback!=null)
			animationEnd.add(callback);
		centerOrigin();
		play("ani");
	}
	
	public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void { }
	
	@:isVar public var flip(get, set):Bool;
	function get_flip():Bool { return flipped; }
	function set_flip(value:Bool):Bool
	{
		return flipped = value;
	}
	
	inline public function as<T:IAttach>(clss:Class<T>):T
	{
		#if flash
		return untyped __as__(this, clss);
		#else
		return cast this;
		#end
	}
}
