package com.metal.enums;
import com.metal.config.ItemType;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.GonUpLevelInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import haxe.ds.IntMap;

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
	public var itemArr:Array<ItemBaseInfo>;//
	//public var itemMap:IntMap<ItemBaseInfo>;//itemMap.get(itemIndex)=ItemBaseInfo
	/**通过itemIndex找对应的ItemBaseInfo*/
	public function getItemByKeyId(keyId:Int):ItemBaseInfo
	{
		//for (item in itemArr) 
		//{
			//if (item.itemIndex == itemIndex)
				//return item;
		//}
		//return null;
		for (item in itemArr) 
		{
			if (item.keyId == keyId)
				return item;
		}
		return null;
	}         
	/**记录后备武器*/
	public function buildBackupWeaponMap()
	{
		backupWeaponArr = new IntMap();
		for (i in 0...itemArr.length) 
		{
			if (itemArr[i].backupIndex!=-1) 
			{
				backupWeaponArr.set(itemArr[i].backupIndex, itemArr[i]);
				//trace("backupIndex: "+itemArr[i].backupIndex+" ,keyid: "+itemArr[i].keyId);
			}			
		}
	}
	/**将weapon放在后备武器栏的第index个位置*/
	public function setBackup(weapon:ItemBaseInfo,index:Int)
	{
		var oldBackup:ItemBaseInfo = backupWeaponArr.get(index);
		if (oldBackup!=null) oldBackup.backupIndex = -1;
		backupWeaponArr.set(index, weapon);
		if (weapon != null) {
			weapon.backupIndex = index;	
			//trace("index: "+index);
			//trace("weapon.keyId: "+weapon.keyId);
		}
	}
	public function new() 
	{
		
	}
	public function getItem(id:Int):ItemBaseInfo
	{
		for (item in itemArr) 
		{
			if (item.itemId == id)
				return item;
		}
		return null;
	}
	/**背包排序  sortInt从小到大*/
	public function sort():Void
	{
		for (i in 0...itemArr.length)
		{
			itemArr[i].itemIndex = i + 1;
			
			
			/***进化材料的SubId不知哪改为0    如果SubId不更改，则可省去下面的判断直接用SubId作为排序条件***/
			if (itemArr[i].SubId == 0)
			{
				itemArr[i].sortInt = 101;
			
			}
			else
			{
				itemArr[i].sortInt = itemArr[i].SubId;
			}	
		}
		itemArr.sort(autoSortByIndex);
		//for (i in 0...itemArr.length) 
		//{
			//for (j in (i+1)...itemArr.length) 
			//{
				//if (itemArr[i].keyId==itemArr[j].keyId) 
				//{
					//trace("same object in itemArr!!!!");
					//trace("i: "+i);
					//trace("j: "+j);
					//trace("itemArr[i].itemId: "+itemArr[i].keyId);
					////trace("itemArr[j].itemId: "+itemArr[j].itemId);
				//}
			//}
		//}
	}
	
	private function autoSortByIndex(a:Dynamic,b:Dynamic):Int
	{
		//#if !neko
			if (a.sortInt == b.sortInt)
				return 0;
			if (a.sortInt > b.sortInt)
				return 1;
			else
				return -1;
	}
	
	/*背包中拿所有强化材料*/
	public function getUpgradeMaterial(goodsInfo:ItemBaseInfo):Array<ItemBaseInfo>
	{
		var infoArr:Array<ItemBaseInfo> = [];
		for ( i in 0...itemArr.length)
		{
			var key:Int = itemArr[i].itemId;
			var oneData = itemArr[i];
			if ((Std.is(oneData, GonUpLevelInfo) || Std.is(oneData, WeaponInfo) || Std.is(oneData, ArmsInfo)) && goodsInfo.keyId != oneData.keyId)
			{
				infoArr.push(cast oneData);
			}
		}
		return infoArr;
	}
	/*从背包中删除物品*/
	public function removeGoods(goods:Array<ItemBaseInfo>):Void
	{
		for (j in 0...goods.length)
		{
			var itemId = goods[j].itemId;
			var index = goods[j].itemIndex;
			var keyId = goods[j].keyId;
			var currArr:Array<ItemBaseInfo> = [];
			for (i in 0...itemArr.length)
			{
				if (itemId == itemArr[i].itemId && keyId == itemArr[i].keyId)
				{
					itemArr[i].itemIndex = 0;
					
				}else
				{
					currArr.push(itemArr[i]);
				}
			}
			itemArr = currArr;
		}
		trace("over == " + itemArr.length);
	}
	public function addGoods(goods:Array<ItemBaseInfo>):Void
	{		
		//trace("addGoods");
		/**初次获得设置子弹数*/
		for (i in 0...goods.length) 
		{
			if (goods[i].Kind==ItemType.IK2_GON && goods[i].firstGet) 
			{
				goods[i].setStartBullet();
				trace("set StartClip");
			}
		}
		itemArr = itemArr.concat(goods);
		sort();
	}
}