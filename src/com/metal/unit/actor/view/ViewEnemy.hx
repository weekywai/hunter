package com.metal.unit.actor.view;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.math.Vector;
import com.metal.component.BattleSystem;
import com.metal.config.UnitModelType;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgActor;
import com.metal.message.MsgItr;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.BulletManager;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletHitInfo;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.render.ViewDisplay;
import com.metal.unit.stat.UnitStat;
import com.metal.unit.weapon.api.AttackTypeList;
import motion.Actuate;
import openfl.geom.Point;
import spinehaxe.Event;

/**
 * ...
 * @author weeky
 */
class ViewEnemy extends ViewActor
{
	private var _player:IActor;
	private var temp1:Vector;
	private var temp2:Vector;
	private var _mInfo:MonsterInfo;
	private var _bulletReq:BulletRequest;
	private var _weapon:Entity;
	private var _skill:SkillInfo;
	
	private var hpBarSkin:Entity;
	private var hpBar:Entity;
	private var hpImage:Image;
	private var hpWidth:Int=100;
	private var hpHeight:Int = 10;
	private var hpMask:Image;
	
	
	public function new() 
	{
		super();
	}
	
	function initHpBar()
	{
		//trace("initHpBar");
		hpImage = Image.createRect(hpWidth, hpHeight, 0xff0000);
		//hpBarSkin = HXP.scene.create(Entity, true, [_actor.x, _actor.y, Image.createRect(hpWidth, hpHeight, 0x000000, 0.5)]);
		hpBarSkin = new Entity(_actor.x,_actor.y,Image.createRect(hpWidth,hpHeight,0x000000,0.5));
		//hpBar = HXP.scene.create(Entity, true, [_actor.x, _actor.y, hpImage]);
		hpBar = new Entity(_actor.x, _actor.y, hpImage);
		hpMask=	Image.createRect(hpWidth, hpHeight, 0x000000,0.1);
		hpBar.addGraphic(hpMask);
		HXP.scene.add(hpBarSkin);
		HXP.scene.add(hpBar);
		hpBarSkin.visible = false;
		hpBar.visible = false;
	}
	function updateHpBarXY()
	{
		if (hpBar == null) return;
		if (hpBar.visible) 
		{
			hpBarSkin.x = _actor.x-hpWidth/2;
			hpBarSkin.y = _actor.y - _actor.halfHeight * 2.5;
			hpBar.x = _actor.x-hpWidth/2;
			hpBar.y = _actor.y - _actor.halfHeight * 2.5;			
		}		
	}
	function updateHpPersent()
	{
		if (hpBar == null) return;
		if (!hpBar.visible) 
		{
			hpBarSkin.visible = true;
			hpBar.visible = true;
		}
		if (_stat!=null) 
		{			
			var persent:Float = _stat.hp / _stat.hpMax;
			Actuate.tween(hpImage, 0.4, { scaleX:persent > 0? persent:0 } );
			Actuate.tween(hpMask, 0.4, { scaleX:persent > 0? persent:0 } );
			Actuate.tween(hpMask,0.2,{alpha:0.4}).onComplete(function ()
			{
				Actuate.tween(hpMask, 0.2, {alpha:0.1 } );
			});
		}		
	}
	function disposeHpBar() 
	{
		if (hpBar == null) return;
		HXP.scene.remove(hpBarSkin);
		HXP.scene.remove(hpBar);
		hpBarSkin = null;
		hpBar = null;
		hpImage = null;
		hpMask = null;
	}
	override function onInit():Void 
	{
		super.onInit();
		_targetPos = new Point();
	}
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		_actor = owner.getComponent(UnitActor);
		_stat = owner.getComponent(UnitStat);
		initHpBar();
		super.Notify_PostBoot(userData);
		_mInfo = owner.getProperty(MonsterInfo);
		_bulletReq = new BulletRequest();
		//trace(_mInfo.SkillId);
		_skill = owner.getProperty(SkillInfo);
		_bulletReq.info = BulletManager.instance.getInfo(_skill.BulletID);
		_bulletReq.attacker = owner;
		//_bulletReq.attackerType = owner.name;
		_bulletReq.atk = _mInfo.Atk;
		_bulletReq.critPor= _mInfo.CritPor;
		_bulletReq.dir = _actor.dir;
		_bulletReq.fix = _skill.Effect.copy();
		//检测是否有buff
		if (_skill.buffId != 0) {
			_bulletReq.buffId = _skill.buffId;
			_bulletReq.buffTarget = _skill.buffTarget;
			_bulletReq.buffTime = _skill.buffTime;
		}
		_player = PlayerUtils.getPlayer().getComponent(MTActor);
		temp2 = new Vector();
		
		if (_skill.AttackType == AttackTypeList.Cut){
			_weapon = new Entity();
			setGunHitbox("gun_1");
			//setGunHitbox("gun_1");
			HXP.scene.add(_weapon);
		}
		
		animationState().onEvent.add(onEventCallback);
		animationState().onStart.add(onStartCallback);
		animationState().onComplete.add(onCompleteCallback);
	}
	
	override public function onDispose():Void 
	{
		super.onDispose();
		temp1 = null;
		temp2 = null;
		_player = null;
		_bulletReq = null;
		_weapon = null;
		_mInfo = null;
		disposeHpBar();
	}
	override public function update() 
	{
		//if (_actor.stateID == ActorState.Move)
			//trace(_mInfo.res);
		//滚屏死亡移动
		if (_actor.isRunMap && _actor.stateID == ActorState.Destroying && _actor.isGrounded)
			_actor.x-=15;
		super.update();
		
		if (_weapon != null && !_meleeHit && _attcking) {
			//trace("melee");
			_weapon.setHitboxTo(getGunHitbox());
			_weapon.x = x;
			_weapon.y = y;
			var hitEntity = _weapon.collide(UnitModelType.Player, _weapon.x, _weapon.y);
			if (hitEntity != null){
				_meleeHit = true;
				var hitInfo = new BulletHitInfo();
				hitInfo.atk = _bulletReq.atk;
				hitInfo.fix = _bulletReq.fix;
				hitInfo.target = cast(hitEntity, ViewDisplay).owner;
				hitInfo.renderType=BattleResolver.resolveAtk(_bulletReq.critPor);
				notifyParent(MsgItr.BulletHit, hitInfo);
			}
		}
		updateHpBarXY();
	}
	
	override function Notify_ChangeSpeed(userData:Dynamic):Void 
	{
		_bulletReq.rate = userData[1];
	}
	override function Notify_Injured(userData:Dynamic):Void 
	{
		super.Notify_Injured(userData);
		//受击特效
		if (_info.hit != 0) 
			startEffect(_info.hit);
		//文字特效
		var msg:String = (userData.damage==0)?"miss":Std.string(userData.damage);
		startEffect(0, EffectAniType.Text, msg,userData.renderType);
		updateHpPersent();
	}
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		super.Notify_Destorying(userData);
		disposeHpBar();
		if (_mInfo.isBoom) {
			//通知处理爆炸
			startEffect(0, _mInfo.boomType+4);
		}
		var rate =  GameProcess.root.getComponent(BattleSystem).BuffRate();
		//trace(dropRan);
		if (Math.random() <= 0.2*rate) {
			var index:Int = 0;
			var ran = Math.random() * 20;
			switch(ran) {
				case 1,2: index = 0;
				case 3: index = 1;
				case 4,5: index = 2;
				case 6,7,8,9,10: index = 3;
				//case 11,12,13: index = 4;
				//case 14: index = 5;
				//case 14,15,16,17: index = 6;
				//case 18,19,20: index = 7;
			}
			//10602-2-1|10601-1-1|10603-2-1|10604-1-1|10608-5-1|10610-3-1|10607-1-1|10609-5-1
			//index = Std.int(Math.random() * 4)+3;//测试
			//无手枪掉落
			
			var item = _mInfo.dropItem[index];
			if (item == null) {//Bug
				trace("Model id:" + _mInfo.ID +">>" + _info.ID);
				return;
			}
			if(item.ItemId==0){//Bug
				trace("Model id:" + _mInfo.ID +">>" + _info.ID);
				return;
			}
			var drop =	[item];
			//掉落物品在此解锁
			//createDropItem(drop);
		}
	}
	override function Notify_Destory(userData:Dynamic):Void 
	{
		
		if(_weapon!=null) HXP.scene.remove(_weapon);
		super.Notify_Destory(userData);
	}
	
	override function Notify_EffectStart(userData:Dynamic):Void
	{
		//trace("add Effect :" + userData);
		if (userData == null)
			return;
		startEffect(userData);
	}
	
	private function onEventCallback(value:Int, event:Event):Void {
		//trace("callback"); 
		if (isDisposed)
			return;
		if (event.data.name == "attack") _attcking = true;
	}
	private function onStartCallback(i:Int, value:Dynamic):Void
	{
		if (isDisposed)
			return;
			//trace(value);
		if (value == "attack_1")
		{
			//_attcking = true;
				//trace("onStartCallback");
			notify(MsgActor.AttackStatus ,true);
		}
	}
	
	private function onCompleteCallback(count:Int, value:String):Void
	{
		if (isDisposed)
			return;
		if (value == "attack_1")
		{
			_attcking = false;
				//trace("onCompleteCallback");
			notify(MsgActor.AttackStatus ,false);
			_actor.transition(ActorState.Stand);
		}
	}
}