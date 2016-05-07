package com.metal.unit.weapon.impl;

import com.metal.component.GameSchedual;
import com.metal.config.MsgType.GameMsgType;
import com.metal.config.PlayerPropType;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI2;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ItemProto.EquipInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.SkillManager;
import com.metal.unit.stat.BuffType;
import com.metal.unit.stat.IStat;
import com.metal.unit.weapon.api.AttackTypeList;
import com.metal.unit.weapon.impl.WeaponFactory.WeaponType;
import com.metal.unit.weapon.skill.BaseSkill;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.MsgCore;
import haxe.ds.IntMap;

/**
 * ...
 * @author weeky
 */
class WeaponController extends Component
{
	private var _weaponUsing:Map<WeaponType, BaseWeapon>;
	private var _skillBuff:IntMap<BaseWeapon>;
	
	/**武器等级*/
	public var bulletLevel(default, null):Int = 1;
	private var _curBulletLv:Int = 1;
	private var _curWeaponId:Int;
	
	public function new() 
	{
		super();
		_weaponUsing = new Map();
		_skillBuff = new IntMap();
	}
	
	override function onDispose():Void 
	{
		for (weapon in _weaponUsing.iterator()) 
		{
			(cast weapon).dispose();
		}
		for (weapon in _skillBuff.iterator()) 
		{
			(cast weapon).dispose();
		}
		_weaponUsing = null;
		super.onDispose();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		//_curWeaponId = PlayerUtils.getInfo().getProperty(PlayerProp.WEAPON);111
		_curWeaponId = PlayerUtils.getInfo().data.WEAPON;
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgCore.PROCESS:
				cmd_PostBoot();
			case MsgPlayer.Attack:
				cmd_Attack(userData);
			case MsgPlayer.ChangeWeapon:
				cmd_ChangeWeapon(userData);
			case MsgPlayer.ChangeWeaponLevel:
				cmd_ChangeWeaponLevel(userData);
			case MsgPlayer.ChangeSkill:
				cmd_ChangeSkill(userData);
			case MsgPlayer.ItemSkill:
				cmd_ItemSkill(userData);
		}
	}
	private function cmd_PostBoot():Void
	{
		//trace("cmd_PostBoot");
		var skillInfo = getSkill();
		var playerInfo = PlayerUtils.getInfo();
		createWeapon(WeaponType.Shoot, skillInfo);
		createWeapon(WeaponType.Melee, skillInfo);
		createWeapon(WeaponType.Grenade, SkillManager.instance.getInfo(playerInfo.data.SKILL1));
		var skill2 = playerInfo.data.SKILL2;
		if (skill2 != 0) {
			createWeapon(WeaponType.Clear, SkillManager.instance.getInfo(skill2));
		}
		//trace("weaponcontrol");
	}
	private  function cmd_Attack(userData:Dynamic):Void
	{
		
		var weapon:BaseWeapon = _weaponUsing.get(userData.type);
		if (!weapon.isShooting) {
			weapon.onUpdate(MsgPlayer.ShootStart, owner, null);
		}
	}
	private function cmd_ChangeWeapon(userData:Dynamic):Void
	{
		var weapon:BaseWeapon = _weaponUsing.get(userData.type);
		if(userData.id != null)
			_curWeaponId = userData.id;
		else
			_curWeaponId = PlayerUtils.getInfo().data.WEAPON;
			//_curWeaponId = PlayerUtils.getInfo().getProperty(PlayerProp.WEAPON);111
		weapon.initInfo(getSkill());
	}
	private function cmd_ChangeWeaponLevel(userData:Dynamic):Void
	{
		var stat:IStat = PlayerUtils.getPlayerStat();
		if (stat.findStatusByKey(BuffType.Runaway) != null)
			return;
			if(!userData.runaway)
				bulletLevel = userData.lv;
		_curBulletLv = userData.lv;
		var weapon:BaseWeapon = _weaponUsing.get(WeaponType.Shoot);
		weapon.initInfo(getSkill());
	}
	private function cmd_ChangeSkill(userData:Dynamic):Void
	{
		changeSkill(userData);
	}
	private function cmd_ItemSkill(userData:Dynamic):Void
	{
		changeSkill(userData, true);
	}
	
	private function changeSkill(userData:Dynamic, isItem:Bool =false)
	{
		var skill:SkillInfo = SkillManager.instance.getInfo(userData);
		if (skill == null)
			throw "Skill id: " + userData + " is null";
		if(!isItem){
			var mp = PlayerUtils.getInfo().data.MP - skill.Consume;
			if (mp < 0) {
				trace("changeSkill");	
				GameProcess.SendUIMsg(MsgUI2.ScreenMessage, GameMsgType.SkillFreeze);
				GameProcess.SendUIMsg(MsgUI2.SkillCD, {time:0, id:userData});
				return;
			}
		}
		var weaponType:WeaponType;
		var weapon:BaseWeapon = null;
		//trace(userData+">>"+skill.AttackType);
		switch(skill.AttackType) {
			case AttackTypeList.BulletLevelUp:
				weaponType = WeaponType.UpgradeBullet;
			case AttackTypeList.Regen:
				weaponType = WeaponType.Regen;
			case AttackTypeList.Grenade:
				weaponType = WeaponType.Grenade;
			case AttackTypeList.CLear:
				weaponType = WeaponType.Clear;
			default:
				weaponType = WeaponType.AddBuff;
		}
		if (weaponType == WeaponType.AddBuff) {
			weapon = _skillBuff.get(userData);
			if(weapon==null)
				weapon = createWeapon(weaponType, skill);
			if (weapon.isShooting)
				return;
			//trace(userData);
		}else {
			weapon = _weaponUsing.get(weaponType);
			if (weapon == null) {
				weapon = createWeapon(weaponType, skill);
			}else {
				weapon.initInfo(skill);
			}
		}
		//trace(userData+">>"+isItem);
		if(Main.config.get("console")=="true"){
			cast(weapon, BaseSkill).isItem = true;
			GameProcess.SendUIMsg(MsgUI2.SkillCD, {time:0, id:userData});
		}else {
			cast(weapon, BaseSkill).isItem = isItem;
		}
		weapon.onUpdate(MsgPlayer.ShootStart, owner, null);
	}
	
	private function createWeapon(type:WeaponType, info:SkillInfo, isBuff:Bool = false):BaseWeapon
	{
		var weapon:BaseWeapon = PlayerUtils.createWeapon(owner, type);
		weapon.initInfo(info);
		if(!isBuff){
			_weaponUsing.set(type, weapon);
		}else {
			_skillBuff.set(info.Id, weapon);
		}
		owner.addComponent(weapon);
		return weapon;
	}
	
	public function getWeapon(type:WeaponType):BaseWeapon
	{
		return _weaponUsing.get(type);
	}
	
	private function getSkill():SkillInfo
	{
		//if(weaponId==-1)
			//weaponId = PlayerUtils.getInfo().getProperty(PlayerProp.WEAPON);
		//身上的装备
		var weapon:EquipInfo = cast GoodsProtoManager.instance.getItemById(_curWeaponId,false);
		//var weapon:WeaponInfo = cast GoodsProtoManager.instance.getItemById(101);
		var skillID:Int = weapon.SubId * 100 + weapon.Color * 10 + _curBulletLv;
		var skill:SkillInfo = SkillManager.instance.getInfo(skillID);
		return skill;
	}
}