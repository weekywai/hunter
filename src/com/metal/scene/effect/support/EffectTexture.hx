package com.metal.scene.effect.support;

import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.ResPath;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.impl.EffectEntity;
import openfl.geom.Point;

/**
 * ...
 * @author weeky
 */
class EffectTexture extends EffectEntity
{
	private var _effect:TextrueSpritemap;
	private var _effAtlas:TextureAtlasFix;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	override private function onDispose():Void 
	{
		if(_effect != null)
			_effect.destroy();
		_effect = null;
		_effAtlas = null;
		super.onDispose();
	}
	
	override function onStart(req:EffectRequest):Void 
	{
		_effAtlas = TextureAtlasFix.loadTexture(ResPath.getEffectRes(info.res, info.type));
		if(_effect==null){
			_effect = new TextrueSpritemap(_effAtlas);
			_effect.animationEnd.add(onComplete);
		} else {
			_effect.resetTexture(_effAtlas, onComplete);
			
		}
		_effect.add("blast", _effAtlas.getReginCount(), info.speed);
		
		if (_effAtlas.ox != 0 || _effAtlas.oy != 0) {
			_effect.originX = _effAtlas.ox;
			_effect.originY = _effAtlas.oy;
			_effect.scale = _effAtlas.scale;
			////trace("==========" + eff.r);
			_effect.angle = _effAtlas.r;
			_offset = true;
		}else {
			_effect.centerOrigin();
		}
		graphic = _effect;
		
		_effect.play("blast",true);
		
		
		if (_offset) {
			if (_effAtlas.r != 0)
			{
				_effect.angle = _angle+_effAtlas.r;
			}
		}
		else {
			_effect.angle = _angle;// -90;
		}
	}
	
	private function onComplete(name):Void
	{
		recycle();
	}
}