package com.metal.utils;
import com.metal.component.BagpackSystem;
import com.metal.component.GameSchedual;
import com.metal.config.BagType;
import com.metal.config.ItemType;
import com.metal.enums.BagInfo;
import com.metal.message.MsgNet;
import com.metal.proto.manager.GoodsProtoManager;
import haxe.Serializer;
import haxe.Unserializer;
import spinehaxe.JsonUtils;

using com.metal.proto.impl.ItemProto;
/**
 * ...
 * @author 3D
 */
class BagUtils
{

	public function new() 
	{
		
	}
	
	private static var _bag:BagInfo;
	public static var bag(get, null):BagInfo;
	private static function get_bag():BagInfo
	{
		if (_bag == null)
			_bag = GameProcess.instance.getComponent(BagpackSystem).bagData;
		return _bag;
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
		var tempId:Int;
		var itemType:Int; 
		var temp:Dynamic;
		if (_bag == null) return;
		_bag.itemArr = new Array<ItemBaseInfo>();
		for (i in 0...bag.maxNum) {
			tempId = Std.int(Math.random() * 20) + 1;
			temp = GoodsProtoManager.instance.getItemById(tempId);
			_bag.itemArr.push(temp);
		}
	}
		
	/**传入一个小类型
	 * 返回当前背包中此类型的所有物品*/
	public static function getItemArrByType(type:Int):Array<ItemBaseInfo>
	{
		var arr:Array<ItemBaseInfo> = [];
		for (item in _bag.itemArr) {
			
			if (item.Kind == type) {
				arr.push(cast item);
			}
		}
		return arr;
	}
	
	
	private static function autoSortByIndex(a:Dynamic,b:Dynamic):Int
	{
		return (a.itemIndex > b.itemIndex)?1:-1;
	}
	
	/**在装备区获取某个部位的装备**/
	public static function getEquipingByPart(kind:Int):EquipInfo
	{
		for (item in _bag.itemArr) {
			if (GoodsProtoManager.instance.getItemLittleKind(item.ID) == kind) {
				return cast item;
			}
		}
		return null;
	}
	
	/*判断道具背包是否存在该id物品*/
	public static function isBag(_itemId:Int):Bool
	{
		if (getOneBagInfo(_itemId) == null)
			return false;
		else
			return true;
	}
	/*根据itemId获取道具背包中的道具*/
	public static function getOneBagInfo(itemId:Int):ItemBaseInfo
	{
		for (item in _bag.itemArr)
		{
			if (item.ID == itemId) return item;
		}
		return null;
	}

	/**获得普通背包容量
	 * **/
	public static function getNormalBagMax():String
	{
		return "仓库容量:"+Std.string(_bag.useNum) + "/" + Std.string(_bag.maxNum);
	}
	
}