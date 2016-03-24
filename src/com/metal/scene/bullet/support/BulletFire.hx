package com.metal.scene.bullet.support;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgItr;
import com.metal.proto.impl.BulletInfo;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import com.metal.unit.render.ViewDisplay;

/**
 * 喷火
 * @author li
 */
class BulletFire extends BulletEntity
{
	private var _fireStart:TextrueSpritemap;
	private var _fire:TextrueSpritemap;
	private var _fireEnd:TextrueSpritemap;
	private var _count:Int;

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
		super.onDispose();
	}
	
	override public function setInfo(info:BulletInfo):Void
	{
		super.setInfo(info);
		//判断资源类型
		_count = 0;
		_angle = 0;
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
		
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q110.xml"));
		_fireStart = new TextrueSpritemap(eff);
		_fireStart.add("fireStart", eff.getReginCount(), 25, false);
		
		_fireStart.animationEnd.add(onStartComplete);
		_fireStart.centerOrigin();
		_fireStart.play("fireStart", true);
		//_fireStart.scaleX = 1.3;
		_fireStart.originX = eff.ox;//-_fireStart.scaledWidth - 340;
		_fireStart.originY = eff.oy;//180;
		_fireStart.scale = eff.scale;
		_fireStart.scaleX = 1.7;
		setHitbox(_fireStart.width,Std.int(_fireStart.height*0.5), _fireStart.width,Std.int(_fireStart.height*0.25));
		
		
		var eff1:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q111.xml"));
		_fire = new TextrueSpritemap(eff1);
		_fire.add("fire", eff1.getReginCount(), 25,true);
		_fire.animationEnd.add(onComplete);
		
		_fire.visible = false;
		//_fire.scaleX = 1.3;
		//_fire.play("fire");
		_fire.originX = eff1.ox; //-_fire.scaledWidth - 345;
		_fire.originY = eff1.oy;//_fire.height / 2 + 70;
		_fire.scale = eff1.scale;
		_fire.scaleX = 1.7;
		
		var eff2:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q112.xml"));
		_fireEnd = new TextrueSpritemap(eff2);
		_fireEnd.add("fireEnd", eff2.getReginCount(), 25, false);
		_fireEnd.animationEnd.add(onEndComplete);
		_fireEnd.centerOrigin();
		
		_fireEnd.visible = false;
		//_fireEnd.scaleX = 1.3;
		//_fireEnd.play("fireEnd");
		_fireEnd.originX = eff2.ox;//-_fireEnd.scaledWidth - 190;
		_fireEnd.originY = eff2.oy;//170;
		_fireEnd.scale = eff2.scale;
		_fireEnd.scaleX = 1.7;
		
		_fire.angle = _angle;
		_fireEnd.angle = _angle;
		_fireStart.angle = _angle;
		addGraphic(_fireStart);
		addGraphic(_fire);
		addGraphic(_fireEnd);
		//var hitMask = new Polygon([new Vector(0, 110), new Vector(300, 0), new Vector(310, 40), new Vector(0, 210),new Vector(-60, 140)]);
		//hitMask.x = Std.int(-545);
		//hitMask.y = Std.int(30);
		//mask = hitMask;
		
	}
	
	private function onStartComplete(obj):Void
	{
		//recycle();
		//scene.remove(this);
		_fireStart.visible = false;
		_fire.visible = true;
		setHitbox(Std.int(_fire.width*_fire.scaleX),Std.int(_fire.height*0.5), Std.int(_fire.width*_fire.scaleX),Std.int(_fire.height*0.25));
		_fire.play("fire", true);
	}
	
	private function onComplete(name):Void
	{
		
		_count++;
		//trace("count " + _count);
		if (_count == 2)
		{
			//scene.remove(this);
			//trace("fire end");
			_fire.visible = false;
			_fire.pause();
			_fireEnd.visible = true;
			_fireEnd.play("fireEnd", true);
		}
		setHitbox(Std.int(_fireEnd.width*_fireEnd.scaleX),Std.int(_fireEnd.height*0.5), Std.int(_fireEnd.width*_fireEnd.scaleX),Std.int(_fireEnd.height*0.25));
		//setHitbox(_fire.width,_fire.height, Std.int(_fire.originX),Std.int(_fire.originY+100));
	}
	
	private function onEndComplete(obj):Void
	{
		_fireEnd.visible = false;
		//scene.remove(this);
		recycle();
	}
	
	override public function start(req:BulletRequest):Void 
	{
		//_effect.angle = req.angle-90;
		super.start(req);
		x = req.x ;//- HXP.camera.x;
		y = req.y ;//- HXP.camera.y;
		trace("x y " + x + ":" + y);
		HXP.scene.add(this);
	}
	
	override public function update():Void 
	{
		super.update();
		if (collideEntity != null) {
			onCollide();
		}
	}
	
	override function onCollide():Void 
	{
		if(collideEntity.type != "solid")
		{
			//trace("collideEntity " + collideEntity);
			var avatar:ViewDisplay = cast(collideEntity, ViewDisplay);
			_hitInfo.target = avatar.owner;
			_hitInfo.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
			owner.notify(MsgItr.BulletHit, _hitInfo);
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