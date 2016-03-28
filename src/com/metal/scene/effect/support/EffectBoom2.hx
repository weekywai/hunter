package com.metal.scene.effect.support;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.render.ViewDisplay;
import motion.Actuate;

/**
 * follow entity x/y effect
 * @author weerky
 */
class EffectBoom2 extends EffectBoom1
{
	private var _attacker:ViewDisplay;

	public function new(x:Float, y:Float) 
	{
		super(x,y);
	}
	override function onDispose():Void 
	{
		_attacker = null;
		super.onDispose();
	}
	
	override function onComplete(name):Void 
	{
		super.onComplete(name);
		if (Std.parseInt(name) == boomEffectArray.length-1)
			recycle();
	}
	
	override public function start(req:EffectRequest):Void 
	{
		_attacker = req.attacker;
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z016.xml");
		
		boomEffectArray = new Array();
		var num = Math.floor((Math.random() * 2 + 2));
		for (i in 0...6)
		{
			var boomEffect2 = new TextrueSpritemap(eff);
			boomEffect2.add(""+i, eff.getReginCount(), 30,false);
			boomEffect2.animationEnd.add(onComplete);
			boomEffect2.visible = false;
			boomEffect2.centerOrigin();
			addGraphic(boomEffect2);
			boomEffect2.scale = (Math.random() * 0.5 + 0.8);
			boomEffect2.flipped = (Math.random() <= 0.5) ? true : false;
			boomEffect2.x = Math.random() * req.width * 0.6 ;//- boomEffect2.scaledWidth / 2;
			boomEffect2.y = Math.random() * req.height * 0.6;// - boomEffect2.scaledHeight / 2;
			boomEffectArray.push(boomEffect2);
		}
		for (i in 0...boomEffectArray.length)
		{
			var boomEffect:TextrueSpritemap = boomEffectArray[i];
			Actuate.tween(boomEffect, i*0.17, {}).onComplete(function () {
				boomEffect.visible = true;
				boomEffect.play("" + i);
			});
		}
		super.start(req);
	}
	
	override public function update():Void 
	{
		super.update();
		if(_attacker!=null){
			x = _attacker.x;
			y = _attacker.y;
		}
	}
	
}