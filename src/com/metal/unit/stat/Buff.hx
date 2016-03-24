package com.metal.unit.stat ;

import com.metal.config.UnitModelType;
import com.metal.message.MsgActor;
import com.metal.message.MsgEffect;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStat;
import com.metal.message.MsgView;
import com.metal.proto.impl.BuffInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.weapon.impl.WeaponController;
import com.metal.unit.weapon.impl.WeaponFactory.WeaponType;
import de.polygonal.core.sys.Component;
/**
 * ...
 * @author weeky
 */
class Buff extends Component
{
	private var _info:BuffInfo;
	public var kind(get, null):Int;
	private function get_kind():Int{
		return _info.kind;
	}
	private var _actor:IActor;
	private var _stat:IStat;
	/**存在时间*/
	private var _remainTime:Float;
	private var _maxTime:Float;
	/**重叠数*/
	//private var overlap(default, null):Int;
	/**间隔时间*/
	private var _interval:Int;
	
	private var _damage:Int;
	
	private var _bulletLv:Int;
	
	public function new() 
	{
		super();
		_interval = 0;
		_bulletLv = 1;
	}
	public function initInfo(info:StatInfo):Void
	{
		_info = info.buffInfo;
		_maxTime = info.time;
		_remainTime = _maxTime * 60;
		_damage = info.damage;
		_stat = info.stat;
		switch(_info.kind) {
			case 1, 2, 13:// 1持续掉血 2/13持续回血
				_interval = _info.EffectScript[2] *60;
		}
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = cast owner.getComponent(MTActor);
		switch(_info.kind) {
			case 3:// 暴走
				runaway();
			case 4:// 减速
				changeSpeed();
			case 5:// 无敌护盾
				invincible();
			case 6:// 双倍积分
				doubleScore();
			case 7:
				changeWeapon();
			case 11://护甲1被动
			case 12://护甲2被动
			case 13://护甲3被动
			case 14://护甲4被动
		}
	}
	
	override function onDispose():Void 
	{
		_info = null;
		_actor = null;
		_stat = null;
		super.onDispose();
	}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		//无限时间 <0
		if (_maxTime > 0){
			if (_remainTime <= 0) {
				endBuff();
				return;
			}
			_remainTime--;
		}
		checkType();
	}
	
	private function endBuff()
	{
		switch(_info.kind) {
			case 3:// 暴走
				owner.notify(MsgEffect.EffectEnd, (owner.name == UnitModelType.Vehicle)?"chongci":"Z027");
				notifyParent(MsgView.ChangeMapSpeed, false);
				owner.notify(MsgStat.DoubleScore, 1);
				owner.notify(MsgPlayer.ChangeWeaponLevel, { "lv":_bulletLv, "runaway":false } );
			case 4:// 减速
				owner.notify(MsgStat.ChangeSpeed, [1, 1]);
			case 5:// 无敌护盾
				owner.notify(MsgEffect.EffectEnd, "Z001");//护盾
				owner.notify(MsgStat.Invincible, false);
			case 6:
				owner.notify(MsgStat.DoubleScore, 1);
			case 7:
				owner.notify(MsgPlayer.ChangeWeapon, {type:WeaponType.Shoot});
		}
		owner.notify(MsgStat.RemoveSubStatus, this);
	}
	
	private function checkType()
	{
		switch(_info.kind) {
			case 1:// 1持续掉血 
				minusHP();
			case 2://2持续回血
				regenHP();
				//owner.notify(MsgEffect.EffectStart, "Z002");
			case 11://护甲1被动
			case 12://护甲2被动
			case 13://护甲3被动
				regenHP();
			case 14://护甲4被动
		}
	}
	
	private function minusHP()
	{
		_interval--;
		if (_interval <= 0){
			_interval = _info.EffectScript[2] * 60;
			var hp = (_damage * _info.EffectScript[0]) / 10000;// +  _info.EffectScript[1];
			//trace("damage:" + _damage+" buff:" + hp);
			hp = _stat.hp - hp;
			if (_stat.hp <= 0){
				
			}else{
				//owner.notify(MsgActor.Injured, hp);
				owner.notify(MsgActor.Injured, _stat.hp + hp);
			}
		}
	}
	private function regenHP()
	{
		_interval--;
		if (_interval <= 0){
			_interval = _info.EffectScript[2] * 60;
			var hp = _stat.hpMax * _info.EffectScript[0] / 10000 + _info.EffectScript[1];
			trace("regenHP: " + hp + " maxhp: " +_stat.hpMax);
			if (_stat.hp < _stat.hpMax){
				owner.notify(MsgStat.RegenHp, hp);
				owner.notify(MsgEffect.EffectStart, "Z002");
			}
		}
	}
	private function changeSpeed()
	{
		var actorRate:Float = _info.EffectScript[0] / 100;
		var bulletRate:Float = _info.EffectScript[1] / 100;
		var speed = [bulletRate, bulletRate];
		owner.notify(MsgStat.ChangeSpeed, speed);
	}
	private function runaway()
	{
		owner.notify(MsgEffect.EffectStart, (owner.name == UnitModelType.Vehicle)?"chongci":"Z027");//暴走
		notifyParent(MsgView.ChangeMapSpeed, true);
		var weapon:WeaponController = owner.getComponent(WeaponController);
		_bulletLv = weapon.bulletLevel;
		owner.notify(MsgPlayer.ChangeWeaponLevel, { "lv":_info.EffectScript[0], "runaway":true } );
		owner.notify(MsgStat.DoubleScore, _info.EffectScript[1]);
	}
	private function doubleScore()
	{
		owner.notify(MsgStat.DoubleScore, _info.EffectScript[0]);
	}
	private function changeWeapon()
	{
		var weaponId = _info.EffectScript[0];
		owner.notify(MsgPlayer.ChangeWeapon, { type:WeaponType.Shoot, id:weaponId });
	}
	private function invincible()
	{
		//trace("invincible");
		owner.notify(MsgEffect.EffectStart, "Z001");//护盾
		owner.notify(MsgStat.Invincible, true);
		
	}
	/** 免伤害几率/子弹升级几率/无敌几率 */
	public function findOdds():Bool
	{
		var percent:Float = _info.EffectScript[0] / 10000;
		return (Math.random() <= percent);
	}
	
	public function levelupBullet():Void
	{
		if (findOdds()) {
			notify(MsgPlayer.ChangeSkill, _info.EffectScript[1]);
		}
	}
	public function passiveInvincible():Void
	{
		if (findOdds()) {
			notify(MsgPlayer.ChangeSkill, _info.EffectScript[1]);
		}
	}
}