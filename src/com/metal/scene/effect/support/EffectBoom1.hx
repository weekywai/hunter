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
	private var _numEffect:Int;
	//var boomEffectArray:Array<TextrueSpritemap>;

	public function new(x:Float, y:Float) 
	{
		super(x, y);
	}
	
	override private function onDispose():Void 
	{
		if(_effect!=null)
			_effect.destroy();
		_effect = null;
		//boomEffectArray = null;
		super.onDispose();
	}
	
	
	override public function start(req:EffectRequest):Void 
	{
		info = EffectManager.instance.getProto(req.Key);
		x = req.x - req.width * 0.3;
		y = req.y - req.height;
		
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z016.xml");
		var eff1:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z014.xml");
		
		var scale = req.attacker.getScale();
		//boomEffectArray = new Array();
		//var num = Math.floor((Math.random() * 2 + 2));
		_numEffect = 6;
		var ran:Float, boomEff:TextrueSpritemap;
		for (i in 0...8)
		{
			boomEff = new TextrueSpritemap(eff, false);
			boomEff.add(""+i, eff.getReginCount(), 30,false);
			boomEff.animationEnd.addOnce(function(e) {
				_numEffect--;
				removeGraphic(boomEff);
				boomEff = null;
			});
			boomEff.visible = false;
			boomEff.centerOrigin();
			addGraphic(boomEff);
			ran = Math.random();
			boomEff.scale = (ran * 1 + 1);
			//boomEffect2.scale = (Math.random() * 1 + scale);
			boomEff.flipped = (ran <= 0.5) ? true : false;
			boomEff.x = ran * req.width * 0.7 ;//- boomEffect2.scaledWidth / 2;
			boomEff.y = ran * req.height * 0.7;// - boomEffect2.scaledHeight / 2;
			//boomEffectArray.push(boomEff);
			Actuate.timer(i * 0.25).onComplete (effectTween, [boomEff, ""+i]);
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
		Actuate.timer(2).onComplete (effectTween, [_effect, "boom"]);
			//}, Math.floor(boomEffectArray.length*170*0.85));
		//_effect.angle = req.angle-90;
		//super.start(req);
		
		//trace("x y " + x + ":" + y);
		HXP.scene.add(this);
	}
	private function effectTween(tex:TextrueSpritemap, name:String)
	{
		if (scene == null) return;
		tex.active = true;
		tex.visible = true;
		tex.play(name);
	}
	override public function removed():Void 
	{
		/*for (i in boomEffectArray) 
		{
			i.destroy();
		}*/
		Actuate.stop(this);
		//boomEffectArray = [];
		super.removed();
	}
	/*
	private function onComplete(name):Void
	{
		var num:Int = Std.parseInt(name);
		var b:TextrueSpritemap = boomEffectArray[num];
		b.visible = false;
	}
	*/
	private function onBoomComplete(name):Void
	{
		//trace("boom complete");
		removeGraphic(_effect);
		recycle();
	}
	
}