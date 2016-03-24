package com.metal.unit.weapon.impl;
import com.metal.component.GameSchedual;
import com.metal.config.PlayerPropType;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.message.MsgPlayer;
import com.metal.player.core.PlayerStat;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.BulletInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.BulletManager;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.view.ViewPlayer;
import com.metal.unit.stat.IStat;
import com.metal.unit.weapon.api.IWeapon;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;

/**
 * ...
 * @author weeky
 */
class BaseWeapon extends Component implements IWeapon
{
	public var weaponID(default, null):Int;
	public var skillInfo(default, null):SkillInfo;
	public var bulletInfo(default, null):BulletInfo;
	
	public var bulletReq(default, null):BulletRequest;
	public var isMelee(default, null):Bool = false;
	public var isShooting(default, null):Bool = false;
	
	public var shootTime(default, null):Float = 0;
	
	public var bulletCount(default, default):Int;
	public var maxBulletCount(default, null):Int;
	public var target(default, null):Bool = false;
	/**开枪效果*/
	private var _gunEffReq:EffectRequest;
	
	private var _actor:MTActor;
	private var _stat:IStat;
	
	private var _avatar:ViewPlayer;
	private var _reborn:Bool = false;
	
	
	public function new() 
	{
		super();
		bulletReq = new BulletRequest();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = cast owner.getComponent(MTActor);
		_stat = cast owner.getComponent(PlayerStat);
		//trace(owner);
		var playerInfo:PlayerInfo = PlayerUtils.getInfo();
		bulletReq.atk = playerInfo.getProperty(PlayerPropType.FIGHT);
		//trace("bulletReq.atk: "+bulletReq.atk);
		bulletReq.attacker = owner;
	}
	public function initInfo(info:SkillInfo) :Void
	{
		if (info == null)
			throw "skillinfo info is null";
		skillInfo = info;
		//trace(skillInfo.BulletID);
		var playerInfo:PlayerInfo = PlayerUtils.getInfo();
		bulletInfo = BulletManager.instance.getInfo(skillInfo.BulletID);
		bulletReq.atk = playerInfo.getProperty(PlayerPropType.FIGHT);
		//trace("bulletReq.atk: "+bulletReq.atk);
		//trace(bulletInfo);
		bulletReq.info = bulletInfo;
		bulletReq.fix = skillInfo.Effect;
		//检测是否有buff
		if (skillInfo.buffId != 0 && skillInfo.buffTarget == 1) {
			bulletReq.buffId = skillInfo.buffId;
			bulletReq.buffTarget = skillInfo.buffTarget;
			bulletReq.buffTime = skillInfo.buffTime;
		}
		
		bulletCount = maxBulletCount = skillInfo.num;
		//每秒60帧
		//shootTime = skillInfo.CDTime * 60;
		//weaponID = PlayerUtils.getInfo().getProperty(PlayerPropType.WEAPON);111
		var weapon =cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.getItemByKeyId(PlayerUtils.getInfo().getProperty(PlayerPropType.WEAPON));
		weaponID = weapon.itemId;
		bulletReq.critPor = weapon.CritPor;
	}
	
	override function onDispose():Void 
	{
		skillInfo = null;
		bulletInfo = null;
		bulletReq = null;
		_actor = null;
		_avatar = null;
		_stat = null;
		super.onDispose();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgActor.Destroying:
				notify_Destroying(userData);
			case MsgPlayer.ShootStart:
				notify_ShootStart(userData);
			case MsgActor.PostLoad:
				notify_PostLoad(userData);
			case MsgInput.DirAttack:
				cmd_DirAttack(userData);
			case MsgActor.Respawn:
				notify_Reborn(userData);			
			//case MsgInput.Aim:
				//cmd_Aim(userData);
		}
	}
	private function cmd_Aim(userData:Dynamic):Void
	{
		target = (userData.target!=null);
		if (target) {//没有攻击者
			bulletReq.targetX = userData.target.x;
			bulletReq.targetY = userData.target.y;
		}
		//notify(MsgActor.Attack, _actor.dir);
	}
	
	private function cmd_DirAttack(userData:Dynamic):Void
	{
		target = (userData.target!=null);
		if (target) {//没有攻击者
			bulletReq.targetX = userData.target.x;
			bulletReq.targetY = userData.target.y;
		}
		//notify(MsgActor.Attack, _actor.dir);
	}
	
	private function notify_PostLoad(userData:Dynamic):Void
	{
		_avatar = userData;
	}
	
	private function notify_ShootStart(userData:Dynamic):Void {
		//trace("notify_ShootStart");
	}
	private function notify_ShootStop(userData:Dynamic):Void
	{
		isShooting = false;
	}
	private function notify_Destroying(userData:Dynamic):Void {
		isShooting = false;
	}
	private function notify_Reborn(userData:Dynamic):Void {
		isShooting = false;
		shootTime = 0;
		_reborn = true;
	}
	/**
	 * 发射子弹带抖动
	 * @param	roffset
	 * @param	len
	 */
	private function ShootDither(roffset:Float = 0, len:Float = 100):Void {
		//var radian:Float = Math.atan2(_actor.AimVY, _actor.AimVX);
		//if (_info.DitherMin < 0) {
			//radian = radian + Math.PI;
		//}
		//var dither:Number = CreateDither();
		//var final:Number = dither + radian;
		//var vx:Number = Math.cos(final);
		//var vy:Number = Math.sin(final);
		//ShootEx(roffset, len, vx, vy, dither * _info.RateDitherH);
	}
	
}