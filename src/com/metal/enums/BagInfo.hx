package com.metal.enums;
import com.metal.config.ItemType;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.ProtoUtils;
import haxe.ds.IntMap;

using com.metal.proto.impl.ItemProto;
/**
 * ...
 * @author 3D
 */
class BagInfo
{
	
	public var parnerId:UInt;//partner_id（uint）伙伴id
	public var bagType:Int;//bag_type（ubyte）背包类型
	public var maxNum:Int;//cell_valid_（ubyte）当前背包的最大容量
	public var useNum:Int;//cell_count（ubyte）当前背包已经使用的格子数
	/**记录备用背包对应位置的物品*/
	public var backupWeaponArr:IntMap<ItemBaseInfo>;
	public var itemArr:Array<ItemBaseInfo>;
	/**通过itemIndex找对应的ItemBaseInfo*/
	public function getItemByKeyId(keyId:Int):ItemBaseInfo
	{
		for (item in itemArr) 
		{
			if (item.vo.keyId == keyId)
				return item;
		}
		return null;
	}         
	/**记录后备武器*/
	public function buildBackupWeaponMap()
	{
		backupWeaponArr = new IntMap();
		for (item in itemArr) 
		{
			if (item.vo.sortInt!=-1) 
			{
				backupWeaponArr.set(item.vo.sortInt, item);
				//trace("sortInt: "+itemArr[i].sortInt+" ,keyid: "+itemArr[i].keyId);
			}			
		}
	}
	/**将weapon放在后备武器栏的第index个位置*/
	public function setBackup(weapon:ItemBaseInfo,index:Int)
	{
		var oldBackup:ItemBaseInfo = backupWeaponArr.get(index);
		if (oldBackup != null) {
			oldBackup.vo.sortInt = -1;
			oldBackup.vo.Equip = false;
			RemoteSqlite.instance.updateProfile(TableType.P_Goods, oldBackup.vo, {ID:oldBackup.ID});
		}
		
		backupWeaponArr.set(index, weapon);
		if(weapon!=null){
			weapon.vo.sortInt = index;
			weapon.vo.Equip = true;
			RemoteSqlite.instance.updateProfile(TableType.P_Goods, weapon.vo, { ID:weapon.ID } );
		}
		//trace("index: "+index);
		//trace("weapon.keyId: "+weapon.keyId);
	}
	public function new() {}
	
	public function getItem(id:Int):ItemBaseInfo
	{
		for (item in itemArr) 
		{
			if (item.ID == id)
				return item;
		}
		return null;
	}
	
	/*背包中拿所有强化材料*/
	public function getUpgradeMaterial(goodsInfo:ItemBaseInfo):Array<ItemBaseInfo>
	{
		var infoArr:Array<ItemBaseInfo> = [];
		for ( item in itemArr)
		{
			var key:Int = item.ID;
			if ((item.Kind == ItemType.IK2_GON_UPGRADE || item.Kind == ItemType.IK2_GON || item.Kind == ItemType.IK2_ARM) && goodsInfo.vo.keyId != item.vo.keyId)
			{
				infoArr.push(item);
			}
		}
		return infoArr;
	}
	
	/**背包所有已穿装备*/
	public function getEquiped():Array<ItemBaseInfo>
	{
		var infoArr:Array<ItemBaseInfo> = [];
		for ( item in itemArr)
		{
			if (item.vo.Equip)
				infoArr.push(item);
		}
		return infoArr;
	}
	
	/*从背包中删除物品*/
	public function removeGoods(goodsList:Array<Int>):Void
	{
		for (Id in goodsList)
		{
			for (item in itemArr)
			{
				if (Id == item.ID)
				{
					itemArr.remove(item);
				}
			}
		}
		RemoteSqlite.instance.deleteProfile(TableType.P_Goods, "ID", goodsList);
		trace("over == " + itemArr.length);
	}
	public function addGoods(goods:Array<Int>):Void
	{		
		trace("addGoods");
		var req = RemoteSqlite.instance.request(TableType.Item, "ID", goods.join(","));
		var save = [], values = [], vo:Dynamic = null;
		var data:Array<ItemBaseInfo> = [];
		var item:ItemBaseInfo;
		for (d in req) 
		{
			item = d;
			data.push(item);
			/**初次获得设置子弹数*/
			if (item.Kind == ItemType.IK2_GON)
				vo = { ID:d.ID, Kind:d.Kind, Bullets:d.OneClip, Clips:d.StartClip };
			else
				vo = { ID:d.ID, Kind:d.Kind, Bullets:0, Clips:0 };
			save.push(vo);
			values.push(d.ID);
			RemoteSqlite.instance.addProfile(TableType.P_Goods, null, vo);
		}
		
		//获取记录vo
		req = RemoteSqlite.instance.requestProfile(TableType.P_Goods, "ID", values.join(","));
		for (item in data) 
		{
			var vo:Dynamic = Lambda.find(req, function(e) { 
				if (e.ID == item.ID)
					return true;
				return false;
			} );
			if(vo!=null)
				item.vo = vo;
		}
		itemArr = itemArr.concat(data);
	}
	public function updateGoods(vo:GoodsVo):Void
	{		
		//trace("updateGoods" + vo);
		var item = getItemByKeyId(vo.keyId);
		item.vo = vo;
		RemoteSqlite.instance.updateProfile(TableType.P_Goods, vo, {keyId:vo.keyId} );
	}
}