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
	
	
	override public function start(req:EffectRequest):Void 
	{
		super.start(req);
		//init
		_effAtlas= TextureAtlasFix.loadTexture(ResPath.getEffectRes(info.res, info.type));
		_effect = new TextrueSpritemap(_effAtlas);
		_effect.add("blast", _effAtlas.getReginCount(), info.speed);
		_effect.animationEnd.add(onComplete);
		
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
		_effect.play("blast");
		
		
		if (_offset) {
			//var p1 = new Point();
			//var p2 = new Point(-_effAtlas.ox, -_effAtlas.oy);
			//HXP.rotateAround(p1, p2, _angle+_effAtlas.r);
			
			if (_effAtlas.r != 0)
			{
				_effect.angle = _angle+_effAtlas.r;
			}
			//_effect.x = _effect.y = 0;
			//_effect.angle = _angle+_effAtlas.r;
			//trace("_effect.angle=========" + _effect.angle);
			//_effect.x = _effAtlas.ox;
			//_effect.y = _effAtlas.oy;
			//var d = Point.distance(p1, p2);
			//_effect.x = p2.x+d;
			//_effect.y = p2.y+d;
		}
		else {
			_effect.angle = _angle;// -90;
		}
		//trace("====asdf");
	}
	
	private function onComplete(name):Void
	{
		recycle();
	}
}