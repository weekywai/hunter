package com.metal.scene.effect.support;

import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.impl.EffectEntity;
import de.polygonal.core.time.Delay;
import haxe.Timer;
import motion.Actuate;

/**
 * ...
 * @author li
 */
class EffectBallLightning extends EffectEntity
{
	private var _effect:TextrueSpritemap;
	var boomEffectArray:Array<TextrueSpritemap>;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
	}
	
	override private function onDispose():Void 
	{
		_effect.destroy();
		_effect = null;
		boomEffectArray = null;
		super.onDispose();
	}
	
	override function onInit():Void 
	{
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z001.xml");
		//var eff1:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z014.xml");
		
		var scale = effectRequest.attacker.getScale();
		boomEffectArray = [];
		var num = Math.floor((Math.random() * 2 + 2));
		for (i in 0...6)
		{
			var boomEffect2 = new TextrueSpritemap(eff);
			boomEffect2.add(""+i, eff.getReginCount(), 30,false);
			boomEffect2.animationEnd.add(onComplete);
			boomEffect2.visible = false;
			boomEffect2.centerOrigin();
			addGraphic(boomEffect2);
			boomEffect2.scale = (Math.random() * 0.5 + scale);
			boomEffect2.flipped = (Math.random() <= 0.5) ? true : false;
			boomEffect2.x = Math.random() * effectRequest.width * 0.6 ;//- boomEffect2.scaledWidth / 2;
			boomEffect2.y = Math.random() * effectRequest.height * 0.6;// - boomEffect2.scaledHeight / 2;
			boomEffectArray.push(boomEffect2);
		}
		for (i in 0...boomEffectArray.length)
		{
			var boomEffect:TextrueSpritemap = boomEffectArray[i];
			Actuate.tween(boomEffect, i*0.17, { } ).onComplete(function () {
				boomEffect.visible = true;
				boomEffect.play("" + i);
			});
		}
	}
	
	override public function start(req:EffectRequest):Void 
	{
		//_effect.angle = req.angle-90;
		//super.start(req);
		x = req.x - req.width * 0.3;
		y = req.y - req.height;
		//trace("x y " + x + ":" + y);
		HXP.scene.add(this);
	}
	override public function removed():Void 
	{
		for (i in boomEffect2) 
		{
			i.destroy();
		}
		boomEffectArray = [];
		super.removed();
	}
	
	private function onComplete(name):Void
	{
		
		//name.visible = false;
		var num:Int = Std.parseInt(name);
		var b:TextrueSpritemap = boomEffectArray[num];
		b.visible = false;
		if (num == boomEffectArray.length - 1)
			recycle();
	}
	
}