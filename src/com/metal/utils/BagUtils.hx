package com.metal.utils;
import com.metal.config.FilesType;
import com.metal.config.ItemType;
import com.metal.component.GameSchedual;
import com.metal.message.MsgNet;
import com.metal.proto.impl.EquipItemBaseInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.enums.BagInfo;
import com.metal.config.BagType;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import spinehaxe.JsonUtils;

/**
 * ...
 * @author 3D
 */
class BagUtils
{

	public function new() 
	{
		
	}
	

	public static var typeChinaArr:Array<String>;
	
	/**根据物品小类获取道具类型的中文**/
	public static function getItemTypeForChina(type:Int):String
	{
		if (typeChinaArr == null) {
			//初始化
			typeChinaArr = new Array();
			typeChinaArr = ['枪械', '防具', '宠物', '枪械进阶材料', '枪械强化材料', '宠物进阶材料', '宠物强化材料',
			'钻石','金币','经验','体力','积分','护甲','战斗BUFF'];
		}
		return typeChinaArr[type];
	}
	
	
	/**创建模拟数据**/
	public static function creatTestData():Void
	{
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		var tempId:Int;
		var itemType:Int; 
		var temp:Dynamic;
		if (bag == null) return;
		bag.itemArr = new Array<ItemBaseInfo>();
		for (i in 0...bag.maxNum) {
			tempId = Std.int(Math.random() * 20) + 1;
			itemType = GoodsProtoManager.instance.getItemLittleKind(tempId);
			temp = GoodsProtoManager.instance.getItemProtoByIdAndType(tempId, itemType);
			bag.itemArr.push(temp);
		}
	}
	
	
	/**传入一个小类型
	 * 返回当前背包中此类型的所有物品*/
	public static function getItemArrByType(type:Int):Array<ItemBaseInfo>
	{
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		if (bag == null) return null;
		var arr:Array<ItemBaseInfo> = [];
		for (item in bag.itemArr) {
			
			if (item.Kind == type) {
				arr.push(cast item);
			}
		}
		return arr;
	}
	
	
	/**获取当前背包中所有 装备/材料
	 * 用服务端赋值的类型  跟配置的大类 不一样..
	 * **/
	public static function getItemsOfStyle(type:Int):Array<Dynamic>
	{
		var canEquip:Bool = false;
		switch (type) {
			case BagType.OPENTYPE_STORE:
				canEquip = true;
			case BagType.OPENTYPE_STR:
				canEquip = true;
			case BagType.OPENTYPE_LVUP_EQUIP:
				canEquip = true;
		}
		var arr:Array<Dynamic> = new Array();
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		var equipBag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData;
		if (canEquip) {
			//把所有装备类型抽离出来
			if (equipBag != null) {
				for (item in equipBag.itemArr) {
					if (item.itemType == ItemType.EQUIP_TYPE) {
						arr.push(item);
					}
				}
			}
			if (bag != null) {
				for (item in bag.itemArr) {
					if (item.itemType == ItemType.EQUIP_TYPE) {
						arr.push(item);
					}
				}
			}
		}else {
			//把所有非装备类型抽离出来
			if (equipBag != null) {
				for (item in equipBag.itemArr) {
					if (item.itemType != ItemType.EQUIP_TYPE) {
						arr.push(item);
					}
				}
			}
			if (bag != null) {
				for (item in bag.itemArr) {
					if (item.itemType != ItemType.EQUIP_TYPE) {
						arr.push(item);
					}
				}
			}
		}
		arr.sort(autoSortByIndex);
		return arr;
	}
	
	private static function autoSortByIndex(a:Dynamic,b:Dynamic):Int
	{
		return (a.itemIndex > b.itemIndex)?1:-1;
	}
	
	
	/**检测当前装备是否存在于装备背包**/
	public static function checkEquiped(item:WeaponInfo):Bool {
		var equipBag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData;
		if (equipBag == null) return false;
		for (item2 in equipBag.itemArr) {
			if (item2 == item) {
				return true;
			}
		}
		
		return false;
	}
	
	/**移除背包某个道具**/
	public static function removeBagItem(items:Array<ItemBaseInfo>):Void
	{
		GameProcess.root.notify(MsgNet.UpdateBag, {type:0, data:items});
	}
	
	/**添加道具到背包*/
	public static function addBagItem(items:Array<ItemBaseInfo>):Void
	{
		GameProcess.root.notify(MsgNet.UpdateBag, {type:1, data:items});
	}
	
	
	/**在装备区获取某个部位的装备**/
	public static function getEquipingByPart(kind:Int):EquipItemBaseInfo
	{
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData;
		for (item in bag.itemArr) {
			if (GoodsProtoManager.instance.getItemLittleKind(item.itemId) == kind) {
				return cast item;
			}
		}
		return null;
	}
	
	/**切换装备
	 * item 装备的道具
	 * part 移除的部位
	 * **/
	public static function changeEquip(item:ItemBaseInfo,part:Int):Void
	{
		var tempIndex:Int = item.itemIndex;
		//从背包删除此道具
		removeBagItem([item]);
		
		var temp:EquipItemBaseInfo = getEquipingByPart(part);
		//当前部位已经存在装备
		if (temp != null) {
			temp.itemIndex = tempIndex;
			temp.bagType = BagType.BAG;
			addBagItem([temp]);
		}
	}
	/*判断道具背包是否存在该id物品*/
	public static function isBag(_itemId:Int):Bool
	{
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		for (item in bag.itemArr)
		{
			if (item.itemId == _itemId) return true;
		}
		return false;
	}
	/*根据itemId获取道具背包中的道具*/
	public static function getOneBagInfo(itemId:Int):ItemBaseInfo
	{
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		for (item in bag.itemArr)
		{
			if (item.itemId == itemId) return cast item;
		}
		return null;
	}

	/**获得普通背包容量
	 * **/
	public static function getNormalBagMax():String
	{
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		return "仓库容量:"+Std.string(bag.useNum) + "/" + Std.string(bag.maxNum);
	}
	
	/**解析网络数据包*/
	public static function analyticalPacket(data:Dynamic):Void
	{	
		var result:Int = Std.parseInt(data.result);
		var content:String = data.toString();
		var itemData:String = JsonUtils.parse(content);
		var bagInfo:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		
		var itemArr:Array<ItemBaseInfo> = [];
		for (i in 0...10) {//需要知道添加多少个道具
			var dyna:Dynamic = JsonUtils.getDynamic(itemData, Std.string(i));
			var item:ItemBaseInfo;
			if (result == 1) item = cast Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(dyna.itemId)));
			if (result == 3) item = cast getOneBagInfo(dyna.itemId);
			
			/******************类型错误*******************/
			//item.itemIndex = dyna.itemIndex;
			//if(item.strLv!=null)item.strLv = item.strLv;
			//if(item.strExp!=null)item.strExp = item.strExp;
			//if(item.Upgrade!=null)item.Upgrade = item.Upgrade;  //升星
			//itemArr.push(item);
			//if (result == 1) addItemForNormalBag(cast item);
		}
		//"1"为添加道具 
		if (result == 2)// "2"删除道具 
		{
			removeBagItem(itemArr);
		}
		//"3"道具属性更新道具属性 
	}
}