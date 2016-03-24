package com.metal.unit.actor.view;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.player.core.PlayerStat;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.view.BaseViewActor.EffConfig;
import com.metal.unit.weapon.impl.BaseWeapon;
import com.metal.unit.weapon.impl.WeaponController;
import com.metal.unit.weapon.impl.WeaponFactory.WeaponType;
import openfl.geom.Point;
import spinehaxe.Bone;
import spinehaxe.animation.Animation;

using com.metal.enums.Direction;
/**
 * ...
 * @author weeky
 */
class ViewVehicle extends ViewActor
{
	private var _gunBone:Bone;
	private var _weapon:BaseWeapon;
	private var originRotation:Float;
	private var r:Float = 0;
	private var _attackAnimation:Animation;
	
	public function new() 
	{
		super();
	}
	
	override function onInit():Void 
	{
		super.onInit();
		_actor = owner.getComponent(MTActor);
		_stat = owner.getComponent(PlayerStat);
	}
	override public function onDispose():Void 
	{
		_weapon = null;
		_gunBone = null;
		super.onDispose();
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		super.Notify_PostBoot(userData);
		_gunBone = getBone("paoguan");
		originRotation = _gunBone.data.rotation;
		animationState().onStart.add(onStartCallback);
		animationState().onComplete.add(onCompleteCallback);
		_actor.isNeedLeftFlip = false;
		var weaponContorl:WeaponController = owner.getComponent(WeaponController);
		_weapon = weaponContorl.getWeapon(WeaponType.Shoot);
		//Notify_EffectStart("z006");
		//attack animation
		_attackAnimation = getAnimation(Std.string(ActionType.attack_1));
		//setAttachMent("gun_1", "gun_1");
	}
	override function Notify_EffectStart(userData:Dynamic):Void
	{
		//trace("add Effect :" + userData);
		if (userData == null)
			return;
		Notify_EffectEnd(userData);
		var config:EffConfig = getConfig(userData);
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getEffectRes(userData, 2));
		var effect = new TextrueSpritemap(eff);
		effect.centerOrigin();
		if (eff.ox != 0 || eff.oy != 0) {
			effect.x -= eff.ox-120;
			effect.y -= eff.oy-100;
			effect.scaleX = 2;
			effect.scaleY = eff.scale;
		}else{
			effect.x += config.ox;
			effect.y += config.oy;
			effect.scaleX = config.scaleX;
			effect.scaleY = config.scaleY;
		}
		
		effect.add("runLight", eff.getReginCount(), 30, config.loop);
		if(userData == "Z002" || userData == "Z006"){
			effect.animationEnd.add(onEffectEnd);
		}
		SfxManager.getAudio(AudioType.Buff).play();
		effect.play("runLight");
		addGraphic(effect);
		_effList.set(userData, effect);
	}
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		super.Notify_Destorying(userData);
		animationState().clearTrack(1);
	}
	override function Notify_Soul(userData:Dynamic):Void 
	{
		//var playerInfo = PlayerUtils.getInfo();
		//var info:PlayerModelInfo = PlayerModelManager.instance.getInfo(playerInfo.getProperty(PlayerPropType.ROLEID));
		//createDropItem(info.dropItem);
	}
	override function Notify_Injured(userData:Dynamic):Void 
	{
		super.Notify_Injured(userData);
		//文字特效
		var msg:String = (userData==0)?"miss":Std.string(userData.damage);
		startEffect(0, EffectAniType.Text, msg,userData.renderType);
	}
	private function getConfig(userData:String):EffConfig
	{
		var config = new EffConfig();
		config.name = userData;
		switch(userData) {
			case "Z001"://护盾
				config.ox = 20;
				config.oy = -100;
				config.scaleX = 2.2;
				config.scaleY = 1.5;
			case "chongci":
				config.ox = -130;
				config.oy = -100;
			case "Z002","Z006":
				config.ox = -20;
				config.oy = -150;
				config.scaleX = 1.3;
				config.scaleY = 1.3;
				config.loop = false;
		}
		return config;
	}
	private function onEffectEnd(obj)
	{
		Notify_EffectEnd("Z002");
		Notify_EffectEnd("Z006");
	}
	
	override public function update() 
	{
		super.update();
		if( _actor.stateID == ActorState.Victory)
			return;
		if(_actor.stateID == ActorState.Destroying)
			return;
		onAttack();
		
		//D点
		var mousePos:Point = new Point();
		//mousePos.x = Input.mouseX + HXP.camera.x;
		//mousePos.y = Input.mouseY + HXP.camera.y;
		mousePos.x = _weapon.bulletReq.targetX;
		mousePos.y = _weapon.bulletReq.targetY;
		if(_stat.holdFire){
			setGunRotationLine(mousePos);
		}else{
			_gunBone.data.rotation = originRotation;
		}
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		if( _actor.stateID == ActorState.Victory)
			return;
		super.setAction(action, loop);
	}
	
	private function onAttack():Void 
	{
		if (!_stat.holdFire)
			return;
		if(_attcking) return;
		if (_attackAnimation == null)
			return;
		//setAnimation(1)原有上动作添加多一个
		animationState().setAnimation(1, _attackAnimation, false);
		_attcking = true;
		trace("viewVehicle fire");
	}
	
	override function Notify_Respawn(userData:Dynamic):Void 
	{
		type = owner.name;
	}
	
	private function onStartCallback(i:Int, value:String):Void
	{
		if(value.indexOf("attack")!=-1)
			SfxManager.getAudio(AudioType.Gun).play(0.2);
		else if(value == "dead_1")
			SfxManager .getAudio(AudioType.DeadPlayer).play(0.5);
	}
	private function onCompleteCallback(i:Int, value:Dynamic)
	{
		if (value == _attackAnimation.name)
			_attcking = false;
	}
	
	private function setGunRotationLine(mousePos:Point):Void
	{
		var armPos:Point = new Point();
		#if cpp
		if (!Math.isNaN(_gunBone.worldX) && !Math.isNaN(_gunBone.worldY))
		#else
		if (_gunBone.worldX !=null && _gunBone.worldY!=null)
		#end
		{
			armPos.x = _gunBone.worldX * _info.scale + x;
			armPos.y = _gunBone.worldY * _info.scale + y;	
		}
		var angle:Float;
		if (mousePos.y == armPos.y)
			angle = Math.PI / 2;
		else
			angle = Math.atan2((mousePos.y - armPos.y), (mousePos.x - armPos.x));
		//trace("angle " + angle * 180 / Math.PI);
		var angle = angle * 180 / Math.PI;
		_gunBone.data.rotation = originRotation + angle;
	}
}