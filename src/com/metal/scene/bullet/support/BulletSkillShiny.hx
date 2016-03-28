package com.metal.scene.bullet.support;

import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.ResPath;
import com.metal.config.UnitModelType;
import com.metal.message.MsgEffect;
import com.metal.message.MsgItr;
import com.metal.proto.impl.BulletInfo;
import com.metal.scene.board.impl.GameBoard;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletComponent;
import com.metal.scene.bullet.impl.BulletEntity;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.utils.effect.Animator;
import com.metal.utils.effect.component.EffectType;
import de.polygonal.core.sys.SimEntity;

/**
 * 全屏技能 
 * @author 3D
 */
class BulletSkillShiny extends BulletEntity
{

	
	private var _bullet:TextrueSpritemap;
	private var _bullet2:TextrueSpritemap;
	
	private var key:Bool = false;
	private var initX:Float;
	private var initY:Float;
	private var _attacker:BaseActor;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	
	override private function onDispose():Void 
	{
		if(_bullet!=null)
			_bullet.destroy();
		_bullet = null;
		if (_bullet2 != null)
			_bullet2 = null;
		_attacker = null;
		super.onDispose();
	}
	
	override public function setInfo(info:BulletInfo):Void
	{
		super.setInfo(info);
		xmlBullet();
	}
	


	/**此技能包含2个xml动画**/
	private function xmlBullet():Void
	{
		key = false;
		var eff2:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Z006.xml"));
		if(_bullet2==null){
			_bullet2 = new TextrueSpritemap(eff2);
			_bullet2.animationEnd.add(onComplete2);
		}else{
			_bullet2.resetTexture(eff2, onComplete2);
		}
		_bullet2.add("shinySceen", eff2.getReginCount(), 20);
		if (eff2.ox != 0 || eff2.oy != 0) {
			_bullet2.originX = eff2.ox;
			_bullet2.originY = eff2.oy;
			_bullet2.scale = eff2.scale;
		}else{
			_bullet2.centerOrigin();
		}
		//_bullet2.x = -1270;
		//_bullet2.y = -1320;
		
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("mxjn01_2.xml"));
		if(_bullet==null){
			_bullet = new TextrueSpritemap(eff);
			_bullet.animationEnd.add(onComplete);
		}else{
			_bullet.resetTexture(eff, onComplete);
		}
		_bullet.add("shinyBody", eff.getReginCount(), 20);
		if (eff.ox != 0 || eff.oy != 0) {
			_bullet.originX = eff.ox;
			_bullet.originY = eff.oy;
			_bullet.scale = eff.scale;
		}else{
			_bullet.centerOrigin();
		}
		
		//_bullet.centerOrigin();
		//_bullet.scaleX = 0.5;
		//_bullet.scaleY = 0.5;
		_bullet.visible = true;
		//graphic = _bullet;
		addGraphic(_bullet);
		_bullet.play("shinyBody", true);
		
	}
	
	/**第一段效果播放完毕**/
	private function onComplete(name):Void
	{
		//全屏伤害触发
		checkOnCameraEntity();
		_bullet.visible = false;
		key = true;
		//recycle();
		Animator.start(this, "", EffectType.LIGHTS_SHINY, null, true, null);
		//释放第二段
		addGraphic(_bullet2);
		//graphic = _bullet2;
		_bullet2.scaleX = 8;
		_bullet2.scaleY = 8;
		_bullet2.play("shinySceen", true);
		
	}
	
	
	private function onComplete2(name):Void
	{
		key = false;
		cast(graphic, Graphiclist).remove(_bullet2);
		//removeGraphic(_bullet2);
		recycle();
	}
	
	override public function start(req:BulletRequest):Void 
	{
		super.start(req);
		_attacker = cast req.attacker.getComponent(MTActor);
		initX = _attacker.x;
		initY = _attacker.y;
	}
	
	override public function update():Void 
	{
		if (isDisposed)
			return;
		
		if (_attacker == null) {
			return;
		}
		else {
			if(_bullet2 != null){
				_bullet2.x = _attacker.x - initX +(-105);
				_bullet2.y = _attacker.y - initY + (-110);
			}
			if (_bullet != null) {
				_bullet.x = _attacker.x - initX -105;
				_bullet.y = _attacker.y - initY-110;
			}
		}
		
		
		super.update();
		
		//if (collideEntity != null) {
			//onCollide();
		//}
		//if (computeInCamera()){
			//if (scene != null) 
				//recycle();
		//}
	}
	
	/**全屏技能效果处理**/
	private function checkOnCameraEntity()
	{
		//HXP.scene.
		var board:GameBoard = owner.getComponent(GameBoard);
		var arr:Array<SimEntity> = board.onCameraEntity();
		//怪物受击效果
		for (sm in arr) {
			if(sm.name != UnitModelType.Player && sm.name != UnitModelType.Vehicle){
				sm.notify(MsgEffect.EffectStart, 43);//特效ID 43
				_hitInfo.target = sm;
				//trace("info::"+_hitInfo.buffId+"<><>"+_hitInfo.fix);
				owner.notify(MsgItr.BulletHit,_hitInfo);
			}
		}
		//子弹消除处理
		var effT:TextrueSpritemap;
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Z018.xml"));
		
		var bullets = owner.getComponent(BulletComponent).bullets;
		for (bullet in bullets.iterator()) {
			//if (!bullet.rcKey) {
				if (!Std.is(bullet, BulletSkillShiny) && bullet.canRemove) {
					//不处于回收状态时 需要播放消失效果 
					effT = new TextrueSpritemap(eff);
					if (eff.ox != 0 || eff.oy != 0) {
						effT.originX = eff.ox;
						effT.originY = eff.oy;
						effT.scale = eff.scale;
					}else{
						effT.centerOrigin();
						effT.x = bullet.x-bullet._tx;
						effT.y = bullet.y-bullet._ty;
					}
					
					effT.add("clearEff", eff.getReginCount(), 25);
					effT.centerOrigin();
					addGraphic(effT);
					effT.play("clearEff");
					//回收自己 同时处理
					//trace("clear bullet"+this);
					//if(!Std.is(bullet, BulletMissile1)&&!Std.is(bullet, BulletFire))
					//trace(bullet);
					bullet.recycle();
				}
			//}
		}
	}
	
	override function onCheck():Void 
	{
		var vc:Float, i:Int, e:Entity;
		
		if (collideEntity != null) return;
		
		//if ((e = collideTypes(_collideTypes, x, y)) != null) {
			//if(e.type == "solid" ||e.type == "player"){
				//_effectReq.angle = 90;
				//y -= 150;
				////_effectReq.y -= 50;
				//collideEntity = e;
			//}else {
				//return;
			//}
		//}
	}
	
}