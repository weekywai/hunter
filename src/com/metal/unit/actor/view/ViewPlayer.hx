package com.metal.unit.actor.view;
import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.PlayerPropType;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.config.UnitModelType;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgCamera;
import com.metal.message.MsgInput;
import com.metal.message.MsgItr;
import com.metal.message.MsgPlayer;
import com.metal.player.core.PlayerStat;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.PlayerModelInfo;
import com.metal.proto.manager.PlayerModelManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletHitInfo;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.view.BaseViewActor.EffConfig;
import com.metal.unit.avatar.MTAvatar;
import com.metal.unit.weapon.impl.BaseWeapon;
import com.metal.unit.weapon.impl.WeaponController;
import com.metal.unit.weapon.impl.WeaponFactory.WeaponType;
import de.polygonal.core.event.IObservable;
import openfl.geom.Point;
import pgr.dconsole.DC;
import spinehaxe.animation.Animation;
import spinehaxe.Bone;
import spinehaxe.Event;

using com.metal.enums.Direction;
/**
 * ...
 * @author weeky
 */
class ViewPlayer extends BaseViewActor
{
	private var _backArmBone:Bone;
	private var _frontArmBone:Bone;
	private var _headBone:Bone;
	private var originHeadRo:Float;
	private var originBackRo:Float;
	private var originFrontRo:Float;
	private var _weapon:BaseWeapon;
	private var _info:PlayerInfo;
	private var _melee:Entity;
	private var _meleeCollides:Array<String>;
	private var _meleeAtk:Bool;
	
	
	private var _shootAnimation:Animation;
	private var _meleeAnimation:Animation;
	private var _throwBombAnimation:Animation;
	
	/**瞄准点视图*/
	private var aimPointView:Entity;
	//瞄准间补
	private var aimPoint:Point;
	private var aimHeight:Float = 0;
	private var targetAimPoint:Point;
	//var aimAdjust:Float = 10;
	private var aimAdjustY:Float = 20;
	private var rotationAdjust:Float = 5;
	private var onAim:Bool;
	
	public function new() 
	{
		super();
		_meleeAtk = false;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = cast owner.getComponent(MTActor);
		_actor.throwBomb = false;
		_stat = owner.getComponent(PlayerStat);
		_info = PlayerUtils.getInfo();
		_targetPos = new Point();
		targetAimPoint = new Point();		
		setDefaultAimPoint();
		aimPoint = new Point();
		lastDir = _actor.dir;
		onAim = false;
		//trace(_info.Job);
		//aimPointView = new Entity(targetAimPoint.x, targetAimPoint.y, Image.createCircle(4, 0xffffff, 1));
		//HXP.scene.add(aimPointView);		
	}
	function setAimPointWithoutTween()
	{
		aimPoint.x = targetAimPoint.x;
		aimPoint.y = targetAimPoint.y;
		//aimPointView.x = aimPoint.x;
		//aimPointView.y = aimPoint.y;
	}
	
	function setDefaultAimPoint(withoutTween:Bool=false)
	{
		//trace("setDefaultAimPoint");
		if (_actor.halfHeight!=0 && aimHeight==0) 
		{
			aimHeight = _actor.halfHeight *1.2;
			//trace("aimHeight: "+aimHeight);
			//trace("_actor.halfHeight: "+_actor.halfHeight);
		}
		
		targetAimPoint.x = _actor.x + ((_actor.dir == Direction.RIGHT)?1: -1) * 400;
		targetAimPoint.y = _actor.y - aimHeight;
		if (withoutTween) 
		{
			aimPoint.x = targetAimPoint.x;
			aimPoint.y = targetAimPoint.y;
			//aimPointView.x = aimPoint.x;
			//aimPointView.y = aimPoint.y;
		}
		
		//trace("_actor.y: "+_actor.y);
		//trace("aimHeight: "+aimHeight);
		//trace("targetAimPoint.y : "+targetAimPoint.y );
	}
	
	override public function onDispose():Void 
	{
		trace("dispose");
		_info = null;
		_backArmBone = null;
		_frontArmBone = null;
		_headBone = null;
		_weapon = null;
		_targetPos = null;
		targetAimPoint = null;
		_melee = null;
		aimPoint = null;
		lastDir = null;		
		onAim = false;
		//HXP.scene.remove(aimPointView);
		//aimPointView = null;
		super.onDispose();
	}
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgPlayer.ChangeWeapon:
				cmd_ChangeWeapon(userData);
			case MsgActor.ThrowBomb:
				cmd_ThrowBomb(userData);
			case MsgInput.Aim:
				cmd_Aim(userData);			
		}
		super.onUpdate(type, source, userData);
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
		if (eff.ox != 0 || eff.oy != 0) {
			effect.x -= eff.ox;
			effect.y -= eff.oy;
			effect.scale = eff.scale;
		}else{
			effect.centerOrigin();
			effect.x += config.ox;
			effect.y += config.oy;
		}
		effect.add("runLight", eff.getReginCount(), 30, config.loop);
		if (userData == "Z002" || userData == "Z006") {
			
			effect.animationEnd.add(onEffectEnd);
		}
		SfxManager.getAudio(AudioType.Buff).play();
		effect.play("runLight");
		_avatar.addGraphic(effect);
		_effList.set(userData, effect);
	}
	
	private function getConfig(userData:String):EffConfig
	{
		var config = new EffConfig();
		config.name = userData;
		switch(userData) {
			case "Z001"://护盾
				config.oy = -70;
			case "Z002","Z006":
				config.ox = -30;
				config.oy = -100;
				config.loop = false;
			default:
				config.ox = -30;
				config.oy = -100;
		}
		return config;
	}
	
	private function onEffectEnd(obj)
	{
		Notify_EffectEnd("Z002");
		Notify_EffectEnd("Z006");
	}
	
	override function Notify_EnterBoard(userData:Dynamic):Void 
	{
		//trace("plsyer::" + _avatar.layer);
		super.Notify_EnterBoard(userData);
		//Notify_EffectStart("z006");
	}
	
	override function Notify_Soul(userData:Dynamic):Void 
	{
		//var info:PlayerModelInfo = PlayerModelManager.instance.getInfo(_info.getProperty(PlayerPropType.ROLEID));
		//createDropItem(info.dropItem);
	}
	override function Notify_Respawn(userData:Dynamic):Void 
	{
		super.Notify_Respawn(userData);
		var id = PlayerUtils.getUseWeaponId();
		_shootAnimation = _avatar.getAnimation("attack_" + id).clone();
	}
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		super.Notify_Destorying(userData);
		_avatar.animationState().clearTrack(1);
		//trace("Notify_Destorying");
		//trace("_actor.stateID: "+_actor.stateID);
	}
	override function Notify_Injured(userData:Dynamic):Void 
	{
		super.Notify_Injured(userData);
		//文字特效
		var msg:String = (userData==0)?"miss":Std.string(userData.damage);
		startEffect(0, EffectAniType.Text, msg,userData.renderType);
	}
	override function cmd_PostBoot(userData:Dynamic):Void 
	{
		super.cmd_PostBoot(userData);
		//trace("boot" );
		_backArmBone = _avatar.getBone("L_upperarm");
		_frontArmBone = _avatar.getBone("R_upperarm");
		_headBone = _avatar.getBone("head");
		
		originBackRo = _backArmBone.rotation;
		originFrontRo = _frontArmBone.rotation;
		originHeadRo = _headBone.rotation;
		
		_avatar.animationState().onEvent.add(onEventCallback);
		_avatar.animationState().onStart.add(onStartCallback);
		_avatar.animationState().onEnd.add(onEndCallback);
		_avatar.animationState().onComplete.add(onCompleteCallback);
		var weaponContorl:WeaponController = owner.getComponent(WeaponController);
		_weapon = weaponContorl.getWeapon(WeaponType.Shoot);
		
		//attack animation
		setGun();
		
		_melee = new Entity();
		_avatar.setGunHitbox("texiao");
		HXP.scene.add(_melee);
		_meleeAnimation = _avatar.getAnimation("cut_1").clone();
		_throwBombAnimation=_avatar.getAnimation("throwBomb_1").clone();
		_meleeCollides = [UnitModelType.Unit];
	}
	
	private function cmd_ChangeWeapon(userData:Dynamic):Void
	{
		trace("cmd_ChangeWeapon");
		setGun((userData.id != null)?userData.id:0);
		_attcking = false;
		var weaponContorl:WeaponController = owner.getComponent(WeaponController);
		_weapon = weaponContorl.getWeapon(WeaponType.Shoot);
		//_avatar.animationState().setAnimation(1, _shootAnimation, false);
	}
	
	//private function cmd_Melee(userData:Dynamic):Void
	//{
		////trace(_meleeAtk);
		//if (cast(_stat, PlayerStat).melee) return;
		////trace("_meleeAtk: "+_meleeAtk);
		////_meleeAtk = true;
		//_avatar.animationState().setAnimation(1, _meleeAnimation, false);
		//SfxManager.getAudio(AudioType.Cut).play();
	//}
	private function cmd_ThrowBomb(userData:Dynamic):Void
	{		
		trace("ThrowBomb");
		_avatar.animationState().setAnimation(1, _throwBombAnimation, false);
	}
	var lostAimPoint:Bool;
	private function cmd_Aim(userData:Dynamic):Void
	{
		if (userData.target!=null) 
		{
			//if (lostAimPoint) {
				//trace("getAimPoint");	
				//lostAimPoint = false;
			//}
			//trace("cmd_Aim");
			targetAimPoint.x = _actor.x + ((_actor.dir == Direction.RIGHT)?1: -1) * 400;
			targetAimPoint.y = _actor.y - aimHeight + (userData.target.y - (_actor.y- aimHeight)) / Math.abs((userData.target.x - _actor.x)) * 400;
		}else 
		{
			//if (!lostAimPoint) {
				//trace("lostAimPoint");	
				//lostAimPoint = true;
			//}
			setDefaultAimPoint();
		}		
	}
	private function setGun(id:Int=0):Void
	{
		//trace("setAttachMent(index)");		
		var index = PlayerUtils.getUseWeaponId(id); 
		_shootAnimation = _avatar.getAnimation("attack_" + index).clone();
		_avatar.setAttachMent("gun_1", "gun_" + index);
		//trace("setGun: "+"gun_" + index);
		//if (!_actor.isGrounded) 
		//{
			//_actor.transition(ActorState.Jump);
		//}else 
		//{
			//_actor.transition(ActorState.None);
			//_actor.transition(ActorState.Stand);
		//}
	}
	//var m:Int = 0;
	
	
	override public function onDraw() 
	{
		if (_actor.stateID == ActorState.DoubleJump && _stat.holdFire) 
		{
			//trace("transition(ActorState.Stand)");
			_actor.transition(ActorState.Jump);	
		}
		super.onDraw();
		if (_actor.stateID == ActorState.Destroying) 
			return;
		if (_meleeAtk) {
			meleeCollide();
			_headBone.data.rotation = originHeadRo;
			return;
		}
		//if (!onAim) {
			//if (_actor.isGrounded) {
				////trace("set onAim");
				//onAim = true; 
				//setDefaultAimPoint(true);
			//}
		//}	
		//trace("aiming");
		if (onAim &&(_actor.stateID == ActorState.Move || _actor.stateID == ActorState.Attack || _actor.stateID == ActorState.Jump || _actor.stateID == ActorState.Stand)) {		
			//trace("onaim");
			if (aimPoint==null) 
			{
				//trace("new aimPoint");
				aimPoint = new Point();
				setDefaultAimPoint(true);
			}else 
			{				
				aimPoint.x= targetAimPoint.x;
				aimPoint.y = complement(aimPoint.y, targetAimPoint.y, aimAdjustY);
				setHeadRotation(aimPoint, _actor.dir);
				setGunRotation(aimPoint, _actor.dir);
				//aimPointView.x = aimPoint.x;
				//aimPointView.y = aimPoint.y;
				//trace("aimPoint.x: "+aimPoint.x);
				//trace("aimPoint.y: "+aimPoint.y);
			}				
		}else {
			//trace("no aimPoint");
			if (!onAim){
				if(_actor.isGrounded) {
					onAim = true; 
					setDefaultAimPoint(true);
					//trace("first set");
				}else 
				{
					setDefaultAimPoint(true);
					//trace("before first set");
				}
			}
			_headBone.data.rotation=originHeadRo;
			_backArmBone.data.rotation=originBackRo;
			_frontArmBone.data.rotation = originFrontRo;
			setAimPointWithoutTween();
		}
		onAttack();
		//m++;
		//if(m%60==0)
			//Animator.start(_actor, "", EffectType.COIN_FADE);
	}
	private var lastDir:Direction;
	override private function Notify_Move(userData:Dynamic):Void 
	{
		if (lastDir==null || lastDir!=userData) 
		{
			lastDir = userData;
			_headBone.data.rotation = originHeadRo;
			_backArmBone.data.rotation = originBackRo;
			_frontArmBone.data.rotation = originFrontRo;	
			setDefaultAimPoint(true);
			//trace("turn back");
		}
	}
	
	/**从from向to（递增/递减），单次增量为space*/
	private function complement(from:Float,to:Float,space:Float,rotate:Bool=false):Float
	{
		if (from == to) return from; 
		if (rotate) 
		{
			if (to - from > 180 ) {
				//trace("to - from > 180 : " + from);
				from += 360;
				
			}else if (from - to > 180 ) {
				//trace("(from - to > 180 ): " + from);
				from -= 360;
			}
		}
		if (from<to) 
		{
			from += space;
			if (from > to) from = to;
		}else if (from>to) 
		{
			from -= space;
			if (from < to) from = to;
		}
		return from;
	}
	
	private function meleeCollide()
	{
		//trace(_meleeHit);
		if (!_meleeHit) {
			_melee.collidable = true;
			_melee.setHitboxTo(_avatar.getGunHitbox());
			//trace("_avatar.x : "+_avatar.x);
			//trace("_avatar.y : "+_avatar.y);
			_melee.x = _avatar.x;
			_melee.y = _avatar.y;
			
			var collides:Array<Entity> = [];
			_melee.collideTypesInto(_meleeCollides, _melee.x, _melee.y, collides);
			if (collides.length > 0) {
				_meleeHit = true;
				for (e in collides) 
				{
					var hitInfo = new BulletHitInfo();
					hitInfo.atk = PlayerModelManager.instance.getInfo(_info.getProperty(PlayerPropType.ROLEID)).Att*10;//近身5倍攻击力
					hitInfo.fix = _weapon.bulletReq.fix;
					hitInfo.melee = true;
					//trace(Type.typeof(e));
					hitInfo.target = cast(e, MTAvatar).owner;
					hitInfo.renderType=BattleResolver.resolveAtk(_weapon.bulletReq.critPor);
					notifyParent(MsgItr.BulletHit, hitInfo);
					_melee.collidable = false;
					//hitInfo.target
				}
			}
		}
	}
	
	private function onEventCallback(value:Int, event:Event):Void
	{
		//#if debug
		//trace("event: " + value + " " +  event.data.name + ": " + event.intValue + ", " + event.floatValue + ", " + event.stringValue);
		//#end
		//trace("event.data.name: "+event.data.name);
		if (event.data.name == "attack_1") 
		{
			//trace(event.data.name);			
			//_avatar.addGraphic(new Image());
			//notify(MsgPlayer.Attack, WeaponType.Shoot);
			//notify(MsgPlayer.ShootStart, new Point(_avatar.x + gun.worldX, _avatar.y + gun.worldY));
		}else if (event.data.name == "skill") {
			//notify(MsgPlayer.Attack, WeaponType.Skill);
			//notify(MsgPlayer.ShootStart, new Point(_avatar.x, _avatar.y - _avatar.height*0.5));
		}else if (event.data.name == "cut_1") {
			_meleeAtk = true;
			//trace("onCut");
		}else if (event.data.name == "throwBomb_1") {
			//trace("onThrowBomb");
			_actor.throwBomb = true;
		}
	}
	
	private function onStartCallback(i:Int, value:String):Void
	{
		if(value == "dead_1")
			SfxManager.getAudio(AudioType.DeadPlayer).play();
		else if(value == "walk_1")
			SfxManager.getAudio(AudioType.WalkFloor).play(0.5);
		
	}
	private function onEndCallback(i:Int, value:Dynamic) {
		if (value == _meleeAnimation.name){
			//HXP.scene.remove(_melee);
			_actor.throwBomb = false;
			_meleeAtk = false;
			_meleeHit = false;
			_attcking = false;
			_melee.collidable = false;
		}
		//if (value == _shootAnimation.name)
			//_attcking = false;
	}
	private function onCompleteCallback(i:Int, value:Dynamic)
	{
		//trace(value);
		if (value == _shootAnimation.name) {
			_attcking = false;
		}
	}
	private function onAttack():Void 
	{
		if (!_stat.holdFire)
			return;
		if(_attcking) return;
		if (_shootAnimation == null)
			return;
		//trace("view fire");
		//if (_actor.dir==Direction.LEFT && aimPoint.x>_actor.x) 
		//{
			//trace("player left aimpoint right");
		//}else if (_actor.dir==Direction.RIGHT && aimPoint.x<_actor.x) 
		//{
			//trace("player right aimpoint left");
		//}
		//trace("onAttack");
		if (aimPoint.y == _actor.y - aimHeight) {
			notify(MsgInput.DirAttack, { melee:false, target:null } );
			//trace("default attack");
		}else 
		{
			notify(MsgInput.DirAttack, {melee:false, target:aimPoint});
		}
		//setAnimation(1)原有上动作添加多一个
		//trace(_shootAnimation);
		_avatar.animationState().setAnimation(1, _shootAnimation, false);
		//_avatar.animationState().setAnimation(1, _shootAnimation, false).onComplete = function(count:Int, name:String) { trace(name ); };
		_attcking = true;
	}
	
	//设置头部旋转角度
	private function setHeadRotation(pos:Point, dir:Direction):Void
	{
		var ro:Float = 0;
		#if cpp
		if (!Math.isNaN(_headBone.worldX) && !Math.isNaN(_headBone.worldY))
		#else
		if (_headBone.worldX != null && _headBone.worldY != null)
		#end
		{
			var angle:Float = HXP.angle(_headBone.worldX + _avatar.x, _headBone.worldY + _avatar.y, pos.x, pos.y-_actor.halfHeight*0.8);
			ro = (dir == Direction.LEFT)?180 - angle:angle;
			//取消转头
			_headBone.data.rotation = originHeadRo + ro;
		}
	}
	
	private function setGunRotation(mousePos:Point, dir:Direction):Void
	{
		var armPos:Point = new Point();
		#if cpp
		if (!Math.isNaN(_frontArmBone.worldX) && !Math.isNaN(_frontArmBone.worldY))
		#else
		if (_frontArmBone.worldX != null && _frontArmBone.worldY != null)
		#end
		{
			armPos.x = _frontArmBone.worldX * _modelInfo.scale + _avatar.x;
			armPos.y = _frontArmBone.worldY * _modelInfo.scale + _avatar.y;	
		}
		
		var angle:Float = HXP.angle(armPos.x, armPos.y, mousePos.x, mousePos.y);
		//trace(armPos +"::" + mousePos+"  : "+angle);
		if (_avatar.flip)
			angle = -angle-180;
		_backArmBone.data.rotation = originBackRo + angle;
		_frontArmBone.data.rotation = originFrontRo + angle;
	}
}