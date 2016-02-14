package com.metal.player.core;
import com.metal.component.GameSchedual;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStat;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.BuffInfo;
import com.metal.proto.impl.EquipItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.BuffManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.SkillManager;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.stat.Buff;
import com.metal.unit.stat.BuffType;
import com.metal.unit.stat.IStat;
import com.metal.unit.stat.StatInfo;
import com.metal.utils.BagUtils;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import haxe.ds.IntMap;
import pgr.dconsole.DC;
import ru.stablex.ui.widgets.Text;
/**
 * 角色状态管理(Buff) 
 * @author weeky
 */
class PlayerStat extends Component implements IStat
{
	public var weapon:WeaponInfo;
	public var hpMax(default, null):Int;
	public var hp(default, null):Int;
	public var mpMax(default, null):Int;
	public var mp(default, default):Int;
	public var atk(default, null):Int;
	private var _damageModify:Array<Int>;
	public function damageModify():Array<Int> { return _damageModify; };
	public var speedAdd(default, null):Float = 1;
	public var shootspanAdd(default, null):Float = 1;
	public function findStatusByKey(key:Int):Buff {
		if (_buffs.exists(key)) {
			var list = _buffs.get(key);
			//默认返回首个buff
			if (list.first() == null)
				return null;
			return untyped list.first();
		}
		return null;
	}
	// Buff
	private var _buffs:IntMap<List<Buff>>;
	public function MyBuff():Array<Buff> { return null; }
	/**积分倍数*/
	private var _scoreRate:Float = 1;
	public function ScoreRate():Float { return _scoreRate; }
	
	
	
	private var _actor:IActor;
	/**无敌*/
	private var _invincible:Bool;
	private var _playerInfo:PlayerInfo;
	
	private var _melee:Bool=false;
	public var melee(get, set):Bool;
	private function get_melee():Bool{return _melee;}
	private function set_melee(value:Bool):Bool
	{
		_melee = value;
		if (melee)
			_holdFire = false;
		return _melee;
	}
	
	private var _holdFire:Bool=false;
	public var holdFire(get, set):Bool;
	private function get_holdFire():Bool{return _holdFire;}
	private function set_holdFire(value:Bool):Bool
	{	
		//开火状态条件
		if (weapon.currentBullet <= 0 && weapon.currentBackupBullet<=0) {
			//通知购买子弹
			GameProcess.root.notify(MsgUI.Recharge, Math.floor((weapon.ClipCost/weapon.OneClip)*(weapon.OneClip+weapon.MaxBackupBullet)));
		}
		if (weapon.currentBullet<=0 || _actor.stateID!=ActorState.Attack && _actor.stateID!=ActorState.Stand && _actor.stateID!=ActorState.Move && _actor.stateID!=ActorState.Jump && _actor.stateID!=ActorState.DoubleJump) 
		{
			_holdFire = false;
			return _holdFire;
		}
		//trace("_actor.stateID: "+_actor.stateID);
		_holdFire = value;
		return _holdFire;
	}
	//处于陷阱状态，此状态下不再中陷阱
	private var _istrapping:Bool=false;
	public var istrapping(get, set):Bool;
	private function get_istrapping():Bool{return _istrapping;}
	private function set_istrapping(value:Bool):Bool {
		if (!_istrapping && value) 
		{
			trapCount = trapTime;
		}
		_istrapping = value;
		return _istrapping;
	}
	//陷阱触发间隔：秒*每秒帧数3*60 
	private var trapTime:Int = 120;
	private var trapCount:Int = 0;
	override public function onTick(timeDelta:Float){
		if (trapCount>0) 
		{
			//trace("trapCount: "+trapCount);
			trapCount--;
		}else if (trapCount==0 && istrapping) 
		{
			istrapping = false;
		}
	}
	
	public function new() 
	{
		super();
		_buffs = new IntMap();
		_invincible = false;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = owner.getComponent(MTActor);
		_playerInfo = PlayerUtils.getInfo();
		hpMax = _playerInfo.getProperty(PlayerPropType.MAX_HP);
		hp = _playerInfo.getProperty(PlayerPropType.HP);
		//hp = hpMax;
		mpMax = _playerInfo.getProperty(PlayerPropType.MAX_MP);
		mp = _playerInfo.getProperty(PlayerPropType.MP);
		//mp = mpMax;
		atk = _playerInfo.getProperty(PlayerPropType.FIGHT);
		_damageModify = SkillManager.instance.getInfo(2511).Effect;
		//trace("onInitComponent");
		weapon = cast(cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.getItemByKeyId(_playerInfo.getProperty(PlayerPropType.WEAPON)));
	}
	/**消费子弹*/
	private function cmd_consumeBullet(userData:Int=1)
	{		
		if (weapon.currentBullet < userData) return; 
		//trace("cmd_consumeBullet"+weapon.currentBullet);
		weapon.currentBullet -= userData;
		//通知界面更新
		GameProcess.UIRoot.notify(MsgUIUpdate.UpdateBullet, weapon);
		//注意备用子弹是否无限
		if (weapon.currentBullet<userData) 
		{
			if (weapon.currentBackupBullet>0) 
			{
				//通知换弹夹动作
				notify(MsgPlayer.Reload);
			}		
		}
	}
	/**装填子弹,播完动画再执行*/
	private function cmd_reloadClip(userData:Dynamic)
	{
		//注意备用子弹是否无限
		if (weapon.currentBackupBullet >= weapon.OneClip - weapon.currentBullet) 
		{
			weapon.currentBackupBullet -= weapon.OneClip - weapon.currentBullet;
			weapon.currentBullet = weapon.OneClip;
		}else 
		{
			weapon.currentBullet += weapon.currentBackupBullet;
			weapon.currentBackupBullet = 0;
		}
		//通知界面更新
		GameProcess.UIRoot.notify(MsgUIUpdate.UpdateBullet, weapon);
	}
	
	override function onDispose():Void 
	{
		for (key in _buffs.keys()) 
		{
			var list = _buffs.get(key);
			for (buff in list.iterator()) 
			{
				buff.dispose();
			}
			list.clear();
			_buffs.remove(key);
		}
		_playerInfo = null;
		_actor = null;
		_buffs = null;
		_damageModify = null;
		_buffs = null;
		super.onDispose();
		trace("onDispose");
	}
	
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onNotify(type, source, userData);
		switch(type) {
			case MsgActor.Injured:
				cmd_Injured(userData);
			case MsgInput.HoldFire:
				cmd_HoldFrie(userData);
			case MsgInput.Melee:
				cmd_Melee(userData);
			case MsgActor.EnterBoard:
				cmd_EnterBoard();
			case MsgActor.Respawn:
				cmd_Respawn();
			case MsgStat.AddSubStatus:
				cmd_AddSubStatus(userData);
			case MsgStat.RemoveSubStatus:
				cmd_RemoveSubStatus(userData);
			case MsgStat.Invincible:
				cmd_Invincible(userData);
			case MsgStat.RegenHp:
				cmd_RegenHp(userData);
			case MsgStat.DoubleScore:
				cmd_DoubleScore(userData);
			case MsgStat.ChangeSpeed:
				//cmd_ChangeSpeed(userData);
			case MsgStat.UpdateMp:
				cmd_UpdateMp(userData);
			case MsgPlayer.ChangeWeaponLevel:
				cmd_ChangeWeaponLevel(userData);
			case MsgPlayer.ConsumeBullet:
				cmd_consumeBullet(userData);
			case MsgPlayer.Reload:
				cmd_reloadClip(userData);
			case MsgPlayer.ChangeWeapon:
				cmd_ChangeWeapon(userData);
		}
	}
	
	private function cmd_ChangeSpeed(userData:Dynamic):Void
	{
		speedAdd = userData[0];
		shootspanAdd = userData[1];
	}
	private function cmd_AddSubStatus(userData:Dynamic):Void
	{
		addSubStatus(userData);
	}
	private function cmd_RemoveSubStatus(userData:Dynamic):Void {
		var buff:Buff = userData;
		//trace("removeBuff: " + buff.kind);
		if (_buffs.exists(buff.kind)) {
			var buffs:List<Buff> = _buffs.get(buff.kind);
			var r = buffs.remove(buff);
			trace("removeBuff: " + buff.kind + " " + r);
			buff.dispose();
		}
	}
	private function cmd_Invincible(userData:Dynamic):Void {
		_invincible = userData;
	}
	private function cmd_RegenHp(userData:Dynamic):Void {
		var modifyHP = hp + userData;
		if (modifyHP > hpMax){
			hp = hpMax;
		}else {
			hp = modifyHP;
		}
		_playerInfo.setProperty(PlayerPropType.HP, hp);
		GameProcess.UIRoot.notify(MsgUIUpdate.UpdateInfo);
	}
	private function cmd_DoubleScore(userData:Dynamic):Void
	{
		_scoreRate = userData;
	}
	private function addSubStatus(userData:Dynamic):Void
	{
		//trace(userData + "id");
		var statInfo:StatInfo = new StatInfo();
		statInfo.buffInfo = BuffManager.instance.getProto(userData.id);
		statInfo.time = userData.time;
		statInfo.stat = this;
		if(userData.hp!=null)
			statInfo.damage = userData.hp;
		
		/**队列记录buff*/
		var overlaps:List<Buff>;
		var buff:Buff;
		if (_buffs.exists(statInfo.buffInfo.kind)) {
			overlaps = _buffs.get(statInfo.buffInfo.kind);
			//trace(overlaps.size() + ":" + statInfo.buffInfo.overlap);
			if (overlaps.length >= statInfo.buffInfo.overlap) {
				if(!overlaps.isEmpty()){
					buff = overlaps.pop();
					buff.dispose();
				}
			}
			overlaps.add(createBuff(statInfo));
		} else {
			overlaps = new List();
			overlaps.add(createBuff(statInfo));
			_buffs.set(statInfo.buffInfo.kind, overlaps);
		}
	}
	private function createBuff(info:StatInfo):Buff
	{
		var buff = new Buff();
		buff.initInfo(info);
		owner.addComponent(buff);
		return buff;
	}
	private function cmd_HoldFrie(userData:Dynamic):Void
	{
		holdFire = userData;
	}
	private function cmd_Melee(userData:Dynamic):Void
	{
		melee = userData;
	}
	private function cmd_Injured(userData:Dynamic):Void
	{
		if (_invincible)
			return;
		if (ActorState.IsDestroyed(_actor.stateID))
			return;
		if (_playerInfo == null) return;
		
		if (hp - userData.damage < 0)
			hp = 0;
		else
			hp = Std.int(hp - userData.damage);
		//trace("hp: "+hp);
		_playerInfo.setProperty(PlayerPropType.HP, hp);
		//不用存储
		GameProcess.UIRoot.notify(MsgUIUpdate.UpdateInfo);
		if (hp <= 0) {
			DC.log("Player IsDestroyed hp: " + hp);
			//trace("notify(MsgActor.Destroying) ");
			//trace("_actor.stateID: "+_actor.stateID);
			notify(MsgActor.Destroying);			
			for (key in _buffs.keys()) 
			{
				var list = _buffs.get(key);
				for (buff in list.iterator()) 
				{
					buff.dispose();
				}
				list.clear();
				_buffs.remove(key);
			}
			//trace(_buffs);
		}
	}
	
	private function cmd_EnterBoard():Void
	{
		//trace("cmd_EnterBoard");
		//hpMax = _playerInfo.getProperty(PlayerPropType.MAX_HP);
		//hp = _playerInfo.getProperty(PlayerPropType.HP);
		//setWeaponBuff();
	}
	
	private function cmd_Respawn():Void
	{
		hp = hpMax;
		mp = mpMax;
		_playerInfo.setProperty(PlayerPropType.HP, hpMax);
		_playerInfo.setProperty(PlayerPropType.MP, mpMax);
		//只有这里收到复活然后通知其他
		trace("cmd_Revive");
		//notify(MsgActor.Reborn);
		notify(MsgPlayer.ItemSkill, 1411);
		_holdFire = false;
		melee = false;
		
		GameProcess.UIRoot.notify(MsgUIUpdate.UpdateInfo);
	}
	private function cmd_ChangeWeaponLevel(userData)
	{
		if (userData.runaway) {
			var buff = findStatusByKey(BuffType.PassiveInvincible);
			if (buff != null)
				if (buff.findOdds()) {//无敌 
					buff.passiveInvincible();
				}
		}
	}
	private function cmd_ChangeWeapon(userData)
	{
		trace("cmd_ChangeWeapon");
		_playerInfo = PlayerUtils.getInfo();
		atk = _playerInfo.getProperty(PlayerPropType.FIGHT);
		weapon = cast(cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.getItemByKeyId(_playerInfo.getProperty(PlayerPropType.WEAPON)));
	}
	private function cmd_UpdateMp(userData)
	{
		//trace(mp + ":::" + userData);
		var modify:Int = Std.parseInt(userData);
		mp += modify;
		if (mp > mpMax){
			mp = mpMax;
		}else{
			_playerInfo.setProperty(PlayerPropType.MP, mp);
			GameProcess.UIRoot.notify(MsgUIUpdate.UpdateInfo);
		}
	}
	
	private function setWeaponBuff()
	{
		var weaponInfo:EquipItemBaseInfo = BagUtils.getEquipingByPart(ItemType.IK2_ARM);
		if (weaponInfo == null) 
			return;
		var weapon:ArmsInfo = cast GoodsProtoManager.instance.getItemById(weaponInfo.itemId,false);
		
		if (weapon.SkillsID == -1)
			return;
		var buffInfo:BuffInfo = BuffManager.instance.getProto(weapon.SkillsID);
		trace("armor buff:" + buffInfo.kind);
		addSubStatus( { "id":buffInfo.Id, "time": -1 } );
	}
	
	private function test()
	{
		addSubStatus( { "id":10701, "time": 5, "hp":0 } );
	}

}