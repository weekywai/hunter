package com.metal.scene.bullet.support;
import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.metal.config.ResPath;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgItr;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import com.metal.unit.avatar.AbstractAvatar;
import com.metal.unit.avatar.MTAvatar;

/**
 * ...
 * @author zxk
 */
class BulletLaser extends BulletEntity
{
	private var _bullet:Image;
	private var _bullet2:TextrueSpritemap; 
	private var _spark:Dynamic;
	private var _setId:Array<Int>;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	
	override private function onDispose():Void 
	{
		//_bullet.destroy();
		_bullet = null;
		_bullet2 = null;
		_spark = null;
		_setId = null;
		super.onDispose();
	}
	
	override function onInit():Void 
	{
		//判断资源类型
		switch (info.buffMovieType) {
			case EffectAniType.Image:
				imageBullet();
			case EffectAniType.Texture://2
				xmlBullet();
		}
		_setId = [];
	}
	
	
	private function imageBullet():Void
	{
		_bullet = new Image(ResPath.getBulletRes(info.img));
		_bullet.centerOrigin();
		//var box = Image.createCircle(Std.int(_bullet.height * 1.5));
		var box = Image.createCircle(Std.int(10 * 1.5));
		box.centerOO();
		setHitboxTo(box);
		graphic = _bullet;
	}
	
	
	private function xmlBullet():Void
	{
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes(info.img));
		_bullet2 = new TextrueSpritemap(eff);
		_bullet2.add("blast", eff.getReginCount(), 25);
		_bullet2.animationEnd.add(onComplete);
		if (eff.ox != 0 || eff.oy != 0) {
			_bullet2.x = -eff.ox;
			_bullet2.y = -eff.oy;
			_offset = true;
		}else {
			_bullet2.centerOrigin();
		}
		
		graphic = _bullet2;
		_bullet2.play("blast");
	}
	
	private function onComplete(name):Void
	{
		//recycle();
	}
	
	
	override public function start(req:BulletRequest):Void 
	{
		super.start(req);
		
		if(_bullet != null){
			_bullet.centerOrigin();
			_bullet.angle = _angle;
		}
		
		if (_bullet2 != null) {
			if(!_offset)
				_bullet2.centerOrigin();
			_bullet2.angle = _angle;
		}
	}
	override public function update():Void 
	{
		if (info == null ||_collideTypes==null)
			return;
		super.update();
		moveAtAngle(_angle, info.speed * _rate);
		/*if (collideEntity != null){
			var avatar = cast(collideEntity, AbstractAvatar);
			if (avatar != null && avatar.owner!=null)
				avatar.owner.key = 
		}*/
		if (collideEntity != null) {
			//_effectReq.angle = _angle-90;
			_effectReq.angle = _angle;
			//trace("hit: "+ node.getList().size());
			onCollide();
		}
		if (computeInCamera()) {
			//trace("not in camera: "+ node.getList().size());
			if (scene != null) 
				recycle();
		}
	}
	
	override function onCollide():Void 
	{
		
		var e = collideTypes(_collideTypes, x, y);
		
		if (e != null && e.type != "solid")
		{	
			var avatar = cast(e, AbstractAvatar);
			if (avatar != null && avatar.owner!=null){
				if (Lambda.has(_setId, avatar.owner.id.index))
					return;
				_setId.push(avatar.owner.id.index);
				_hitInfo.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
				_hitInfo.target = avatar.owner;
				_owner.notify(MsgItr.BulletHit, _hitInfo);
			}
			commitEffect();
		}
	}
	override function onCheck():Void 
	{
		var vc:Float, i:Int, e:Entity;
		if (collideEntity != null) return;
		//trace("x y" + x + " " + y+""+_collideTypes);
		if ((e = collideTypes(_collideTypes, x, y)) != null) {
			collideEntity = e;
		}
	}
}