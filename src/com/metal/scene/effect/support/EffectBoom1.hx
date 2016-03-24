package com.metal.scene.effect.support;

import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.proto.manager.EffectManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.impl.EffectEntity;
import motion.Actuate;

/**
 * ...
 * @author li
 */
class EffectBoom1 extends EffectEntity
{
	private var _effect:TextrueSpritemap;
	var boomEffectArray:Array<TextrueSpritemap>;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
	}
	
	override private function onDispose():Void 
	{
		if(_effect!=null)
			_effect.destroy();
		_effect = null;
		boomEffectArray = null;
		super.onDispose();
	}
	
	
	override public function start(req:EffectRequest):Void 
	{
		info = EffectManager.instance.getProto(req.Key);
		x = req.x - req.width * 0.3;
		y = req.y - req.height;
		
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z016.xml");
		var eff1:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z014.xml");
		
		//var scale = req.attacker.getScale();
		boomEffectArray = new Array();
		var num = Math.floor((Math.random() * 2 + 2));
		for (i in 0...8)
		{
			var boomEffect2 = new TextrueSpritemap(eff);
			boomEffect2.add(""+i, eff.getReginCount(), 30,false);
			boomEffect2.animationEnd.add(onComplete);
			boomEffect2.visible = false;
			boomEffect2.centerOrigin();
			addGraphic(boomEffect2);
			boomEffect2.scale = (Math.random() * 1 + 1);
			//boomEffect2.scale = (Math.random() * 1 + scale);
			boomEffect2.flipped = (Math.random() <= 0.5) ? true : false;
			boomEffect2.x = Math.random() * req.width * 0.7 ;//- boomEffect2.scaledWidth / 2;
			boomEffect2.y = Math.random() * req.height * 0.7;// - boomEffect2.scaledHeight / 2;
			boomEffectArray.push(boomEffect2);
		}
		for (i in 0...boomEffectArray.length)
		{
			var boomEffect:TextrueSpritemap = boomEffectArray[i];
			Actuate.tween(boomEffect, i*0.25, {}).onComplete(function () {
				boomEffect.visible = true;
				boomEffect.play("" + i);
			});
		}
		
		_effect = new TextrueSpritemap(eff1);
		_effect.add("boom", eff1.getReginCount(), 17, false);
		_effect.animationEnd.add(onBoomComplete);
		_effect.centerOrigin();
		_effect.visible = false;
		_effect.scale = 1.4;
		addGraphic(_effect);
		_effect.x =  -req.width * 0.3;
		_effect.y = 20;
		Actuate.tween(this, 2, {}).onComplete(function () {
				_effect.visible = true;
				_effect.play("boom");
			});
			//}, Math.floor(boomEffectArray.length*170*0.85));
		//_effect.angle = req.angle-90;
		//super.start(req);
		
		//trace("x y " + x + ":" + y);
		HXP.scene.add(this);
	}
	
	override public function removed():Void 
	{
		for (i in boomEffectArray) 
		{
			i.destroy();
		}
		Actuate.stop(this);
		boomEffectArray = [];
		super.removed();
	}
	
	private function onComplete(name):Void
	{
		
		//name.visible = false;
		var num:Int = Std.parseInt(name);
		var b:TextrueSpritemap = boomEffectArray[num];
		b.visible = false;
	}
	
	private function onBoomComplete(name):Void
	{
		//trace("boom complete");
		_effect.visible = false;
		recycle();
	}
	
}