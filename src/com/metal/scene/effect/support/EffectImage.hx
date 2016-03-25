package com.metal.scene.effect.support;

import com.haxepunk.graphics.Spritemap;
import com.metal.config.ResPath;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.impl.EffectEntity;

/**
 * ...
 * @author weeky
 */
class EffectImage extends EffectEntity
{
	private var _effect:Spritemap;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	override private function onDispose():Void 
	{
		if(_effect!=null)
			_effect.destroy();
		_effect = null;
		super.onDispose();
	}
	
	override function onStart(req:EffectRequest):Void 
	{
		if (_effect == null)
			_effect.destroy();
		_effect = new Spritemap(ResPath.getEffectRes(info.res, info.type), 150, 200, recycle);
		_effect.add("effect", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 26, false);
		_effect.play("effect");
		_effect.centerOrigin();
		_effect.y -= _effect.height * 0.3;
		graphic = _effect;
		_effect.angle = _angle;
	}
}