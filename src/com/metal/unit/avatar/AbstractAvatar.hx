package com.metal.unit.avatar;

import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.haxepunk.Tween.TweenType;
import com.haxepunk.tweens.TweenEvent;
import com.haxepunk.tweens.misc.ColorTween;
import com.metal.config.MapLayerType;
import com.metal.enums.Direction;
import com.metal.manager.ResourceManager;
import com.metal.proto.impl.ModelInfo;
import com.metal.unit.render.ViewDisplay;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class AbstractAvatar extends ViewDisplay
{
	private var _model:IAttach;
	private var _info:ModelInfo;
	private var _recolor:Int;
	private var _colorT:ColorTween;
	
	public var res(get, null):String;
	private function get_res():String {
		return _info.res;
	}
	
	public function new(x:Float=0, y:Float=0, graphic:Graphic=null, mask:Mask=null) 
	{
		super(x, y, graphic, mask);
		layer = MapLayerType.ActorLayer;
	}
	
	override public function removed():Void 
	{
		//ResourceManager.instance.recycleGraphic(_model.as(Graphic));
		super.removed();
	}
	
	/**
	 * 
	 */
	public function preload():Void
	{
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
		//if(_model!=null)
			//_model.destroy();
		_model = null;
		super.onDispose();
	}
	public function setCallback(fun:Dynamic) { }
	public function startChangeColor():Void
	{
		if (_colorT != null)
			_colorT.start();
	}
	//设置受击闪红
	private function changeColor(tune:Int = 0xff0000):Void
	{
		var _tuneColor:Int = tune;
		_recolor = _model.color;
		_colorT = new ColorTween(TweenType.Persist);
		_colorT.tween(0.1, _recolor, _tuneColor, 0, 0.6);
		_colorT.addEventListener(TweenEvent.FINISH, function(e){
			_colorT.color = -1;
		});
		_colorT.cancel();
		addTween(_colorT);
	}
}