package com.metal.scene.bullet.support;

import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgItr;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.avatar.MTAvatar;

/**
 * ...
 * @author ...
 */
class BulletFire1 extends BulletEntity
{
	private var _fireStart:TextrueSpritemap;
	private var _fire:TextrueSpritemap;
	private var _fireEnd:TextrueSpritemap;
	private var _count:Int;
	private var _req:BulletRequest;
	private var _attacker:BaseActor;
	private var _originX:Float;

	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	
	override function onDispose():Void 
	{
		_fireStart.destroy();
		_fire.destroy();
		_fireEnd.destroy();
		_fireStart = null;
		_fire = null;
		_fireEnd = null;
		_req = null;
		_attacker = null;
		super.onDispose();
	}
	override public function removed():Void 
	{
		super.removed();
		SfxManager.getAudio(AudioType.Fire).stop();
	}
	
	override function onInit():Void 
	{
		//判断资源类型
		_count = 0;
		canRemove = false;
		switch (info.buffMovieType) {
			case EffectAniType.Image:
				xmlFire();// imageBullet();
			case EffectAniType.Texture://2
				xmlFire();
		}
	}
	
	private function xmlFire():Void
	{
		trace("====");
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q114.xml"));
		_fireStart = new TextrueSpritemap(eff);
		_fireStart.add("fireStart", eff.getReginCount(), 25,false);
		_fireStart.animationEnd.add(onStartComplete);
		_fireStart.centerOrigin();
		addGraphic(_fireStart);
		_fireStart.play("fireStart");
		_fireStart.scaleX = 1.3;
		_fireStart.scaleY = 1.3;
		_fireStart.x = 70;//-_fireStart.scaledHeight / 2;
		_fireStart.y = 40;
		
		var eff1:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q115.xml"));
		_fire = new TextrueSpritemap(eff1);
		_fire.add("fire", eff1.getReginCount(), 25,true);
		_fire.animationEnd.add(onComplete);
		addGraphic(_fire);
		_fire.visible = false;
		_fire.scaleX = 2.55;
		_fire.scaleY = 2.55;
		//_fire.play("fire");
		_fire.x =  -_fire.scaledWidth * 0.15;
		_fire.y = -110;
		
		var eff2:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q116.xml"));
		_fireEnd = new TextrueSpritemap(eff2);
		_fireEnd.add("fireEnd", eff2.getReginCount(), 25, false);
		_fireEnd.animationEnd.add(onEndComplete);
		_fireEnd.centerOrigin();
		addGraphic(_fireEnd);
		_fireEnd.visible = false;
		_fireEnd.scaleX = 1.3;
		_fireEnd.scaleY = 1.3;
		//_fireEnd.play("fireEnd");
		_fireEnd.x = 70;
		_fireEnd.y = 75;
		SfxManager.getAudio(AudioType.Fire).play(1, 0, true);
		this.setHitbox(100,350, -120,-60);
	}
	
	private function onStartComplete(name):Void
	{
		_fireStart.visible = false;
		_fire.visible = true;
		_fire.play("fire");
	}
	
	private function onComplete(name):Void
	{
		
		_count++;
		if (_count == 6)
		{
			_fire.visible = false;
			_fire.pause();
			_fireEnd.visible = true;
			_fireEnd.play("fireEnd");
		}
	}
	
	private function onEndComplete(name):Void
	{
		_fireEnd.visible = false;
		recycle();
	}
	
	override public function start(req:BulletRequest):Void 
	{
		//_effect.angle = req.angle-90;
		super.start(req);
		_attacker = cast req.attacker.getComponent(UnitActor);
		_req = req;
		_originX = req.x - _attacker.x;// - HXP.camera.x;
		x = req.x;// - HXP.camera.x;
		y = req.y;// - HXP.camera.y;
		//trace("x y " + x + ":" + y);
		HXP.scene.add(this);
	}
	
	override public function update():Void 
	{
		super.update();
		if (_attacker.stateID == ActorState.Destroying) {
			recycle();
			return;
		}
			
		x = _attacker.x + _originX;
		if (collideEntity != null) {
			onCollide();
		}
	}
	
	override function onCollide():Void 
	{
		if(collideEntity.type != "solid")
		{
			//trace("collideEntity " + collideEntity);
			var avatar:MTAvatar = cast(collideEntity, MTAvatar);
			_hitInfo.target = avatar.owner;
			_hitInfo.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
			_owner.notify(MsgItr.BulletHit, _hitInfo);
		}
	}
	
	override function onCheck():Void 
	{
		var vc:Float, i:Int, e:Entity;
		
		if (collideEntity != null) return;
		//trace("x y" + x + " " + y+""+_collideTypes);
		if ((e = collideTypes(_collideTypes, x, y)) != null) {
			//trace(e.type);
			collideEntity = e;
		}
	}
}