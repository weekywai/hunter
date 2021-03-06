package com.metal.player.utils;
import com.metal.config.PlayerPropType;
import com.metal.enums.BagInfo;
import com.metal.enums.GunType;
import com.metal.player.core.PlayerStat;
import com.metal.component.GameSchedual;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.unit.stat.IStat;
import com.metal.unit.weapon.impl.BaseWeapon;
import com.metal.unit.weapon.impl.WeaponFactory;
import de.polygonal.core.sys.SimEntity;
import openfl.errors.Error;

/**
 * 角色工具类
 * @author weeky
 */
class PlayerUtils
{
	/**创建角色武器*/
	public static function createWeapon(entity:SimEntity, type:WeaponType):BaseWeapon
	{
		return WeaponFactory.instance.createWeapon(type);
	}
	
	public static function getPlayerStat():IStat
	{
		return cast getSchedual().playerEntity.getComponent(PlayerStat);
	}
	
	public static function getPlayer():SimEntity
	{
		return getSchedual().playerEntity;
	}
	
	/**获取角色Info*/
	public static function getInfo():PlayerInfo
	{
		return getSchedual().playerInfo;
	}
	public static function getEquipBag():BagInfo
	{
		return getSchedual().equipBagData;
	}
	public static function getUseWeaponId(id:Int=0):Int 
	{
		var weaponId:Int;
		if(id==0){
			var info:PlayerInfo = getSchedual().playerInfo;
			//weaponId = info.getProperty(PlayerPropType.WEAPON);111
			weaponId =cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.getItemByKeyId(info.getProperty(PlayerPropType.WEAPON)).itemId;
		}else {
			weaponId = id;
		}
		//trace("Playerinfo: " + weaponId);
		var subID = GoodsProtoManager.instance.getSubID(weaponId);
		var action = 0;
		switch(subID) {
			case GunType.Gun:
				action = 4;
			case GunType.MachineGun:
				action = 8;
			case GunType.LaserGun:
				action = 12;
			case GunType.ShotGun:
				action = 0;
		}
		//武器ID公式 id = subID * 100 + Id2
		//return action + (weaponId - subID * 100);
		return Math.floor(action/4)+1;
	}
	
	private static function getSchedual():GameSchedual
	{
		return untyped GameProcess.root.getComponent(GameSchedual);
	}
}