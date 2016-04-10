package com.metal.scene.effect.support;
import com.haxepunk.HXP;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.proto.manager.EffectManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.avatar.MTAvatar;
import motion.Actuate;

/**
 * ...
 * @author ...
 */
class EffectBoom2 extends EffectBoom1
{
	private var _attacker:MTAvatar;

	public function new(x:Float, y:Float) 
	{
		super(x,y);
	}
	override function onDispose():Void 
	{
		_attacker = null;
		super.onDispose();
	}
	
	override public function start(req:EffectRequest):Void 
	{
		//trace("boom2" + req.attacker);
		_attacker = req.attacker;
		info = EffectManager.instance.getProto(req.Key);
		x = req.x - req.width * 0.3;
		y = req.y - req.height;
		
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z016.xml");
		var eff1:TextureAtlasFix = TextureAtlasFix.loadTexture("effect/Z014.xml");
		
		var ran:Float;
		_numEffect = 6;
		for (i in 0..._numEffect)
		{
			var boomEff = new TextrueSpritemap(eff, false);
			boomEff.add(""+i, eff.getReginCount(), 30,false);
			boomEff.animationEnd.addOnce(function(e) {
				_numEffect--;
				var b =removeGraphic(boomEff);
				//trace(e+" "+b+">>"+_numEffect);
			});
			boomEff.visible = false;
			boomEff.centerOrigin();
			ran = Math.random();
			boomEff.scale = (ran * 0.8 + 0.6);
			boomEff.flipped = (ran <= 0.5) ? true : false;
			boomEff.x = ran * req.width * 0.7 ;//- boomEffect2.scaledWidth / 2;
			boomEff.y = ran * req.height * 0.5;// - boomEffect2.scaledHeight / 2;
			addGraphic(boomEff);
			Actuate.timer(i * 0.17).onComplete (effectTween, [boomEff, ""+i]);
		}
		//trace("x y " + x + ":" + y);
		if (graphic != null )
			graphic.resume();
		HXP.scene.add(this);
	}
	
	override public function update():Void 
	{
		super.update();
		if (_numEffect <= 1) {
			recycle();
		}
		if(_attacker!=null){
			x = _attacker.x;
			y = _attacker.y;
		}
	}
	
}