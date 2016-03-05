package com.metal.unit.avatar;

import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.metal.config.MapLayerType;
import com.metal.enums.Direction;
import com.metal.proto.impl.ModelInfo;
import com.metal.unit.render.ViewDisplay;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class AbstractAvatar extends ViewDisplay
{
	private var _info:ModelInfo;
	
	public var res(get, null):String;
	private function get_res():String {
		return _info.res;
	}
	
	public function new(x:Float=0, y:Float=0, graphic:Graphic=null, mask:Mask=null) 
	{
		super(x, y, graphic, mask);
		layer = MapLayerType.ActorLayer;
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
	
	override private function onDispose():Void
	{
		_info = null;
		super.onDispose();
	}
}