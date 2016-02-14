package com.metal.unit.avatar;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.metal.config.MapLayerType;
import com.metal.enums.Direction;
import com.metal.proto.impl.ModelInfo;
import de.polygonal.core.sys.IDisposer;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class AbstractAvatar extends Entity implements IDisposer
{
	private var _info:ModelInfo;
	public var owner(default, null):SimEntity;
	public var res(get, null):String;
	private function get_res():String {
		return _info.res;
	}
	
	public function new(x:Float=0, y:Float=0, graphic:Graphic=null, mask:Mask=null) 
	{
		super(x, y, graphic, mask);
		isDisposed = false;
		layer = MapLayerType.ActorLayer;
	}
	
	public function init(owner:SimEntity):Void
	{
		this.owner = owner;
		type = owner.name;
	}
	/**
	 * 
	 */
	public function preload(info:ModelInfo):Void
	{
		_info = info;
		initTexture();
	} 
	private function initTexture() { }
	private function createAvatar(name:String, type:String):Dynamic { return null; }
	public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void { }
	public var flip(get, set):Bool;
	private function get_flip():Bool { return false; }
	private function set_flip(value:Bool):Bool { return value; }
	/* INTERFACE de.polygonal.core.sys.IDisposer */
	
	public var isDisposed(default, null) : Bool;
	
	public function dispose():Void 
	{
		onDispose();
	}
	private function onDispose():Void
	{
		_info = null;
		owner = null;
		if (scene != null)
			//scene.recycle(this);
			scene.remove(this);
		isDisposed = true;
	}
	
}