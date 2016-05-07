package com.metal.proto.impl;
import haxe.ds.StringMap;

/**
 * @author weeky
 */
typedef ItemBaseInfo =
{
	var ItemType:Int;//save_type（ubyte）物品类型（大类）
	/**物品小类*/
	var Kind:Int;
	var ID:Int;//item_id_（int）物品id
	var Name:String;//物品名
	var itemIndex:Int;//index_（ubyte）物品索引
	var itemNum:Int;//item_num_（Int）物品数量
	var itemState:Int;//item_bind_（ubyte）物品绑定状态
	var PickUp:Int;//是否被拾取
	/**进阶最大值*/
	//var InitialQuality:Int;
	/**初始等级*/
	var InitialLevel:Int;
	/**图表资源名称*/
	var ResId:String;
	/**描述*/
	var Description:String;
	/**描述*/
	var Detail:String;
	//特性
	var Characteristic:String;
	var SubId:Int;//取武器技能与强化等级的字段
	/**包含经验*/
	var StrengthenExp:Int;
	/**外观资源名称*/
	var SwfId:String;
	/**首次获得*/
	@:optional var firstGet:Bool;
	/**主键*/
	@:optional var keyId:Int;
	/**属性*/
	var Property:Int;
	/**进阶后的物品ID*/
	var LevelUpItemID:Int;
	var SellDiamond:Int;
	/**进阶最大值*/
	var Color:Int;
	
	@:optional var vo:GoodsVo;
}

/**使用物品数据*/
typedef GoodsVo = {
	var ID:Int;
	var Kind:Int;
	//@:optional var ItemType:Int;
	/**强化经验**/
	@:optional var strExp:Int;//=0
	/**强化等级**/
	@:optional var strLv:Int;//=0
	@:optional var Upgrade:Int; 
	@:optional var Equip:Bool;
	@:optional var Bullets:Int;
	@:optional var Clips:Int;
	/**唯一主键*/
	@:optional var keyId:Int;
	/**处于备用枪背包的第几个位置*/
	var sortInt:Int;//-1
}

typedef GoodsCommon = {
	> ItemBaseInfo,
	/**最大重叠数*/
	@:optional var PackMax:Int;
	/**穿戴等级*/
	@:optional var NeedLevel:Int;
	/**最高强化等级*/
	@:optional var MaxStrengthenLevel:Int;
	/**附加技能ID*/
	@:optional var SkillsID:Int;
	
	//@:optional var strLv:Int;
	/**强化经验**/
	//@:optional var strExp:Int;
}

typedef EquipInfo =
{
	> GoodsCommon,
	//攻击
	@:optional var Att:Int;
	//生命
	@:optional var Hp:Int;
	@:optional var itemStr:Int;
	/**装备类型**/
	@:optional var EquipType:Int;
	/**单个弹夹的子弹数*/
	@:optional var OneClip:Int;
	/**起始的备用子弹数*/
	@:optional var StartClip:Int;
	/**弹夹价格*/
	@:optional var ClipCost:Int;
	/**后备子弹总数*/
	@:optional var MaxBackupBullet:Int;
	/**暴击率*/
	@:optional var CritPor:Int;
}

typedef FashionInfo = EquipInfo;
typedef PetGoodsInfo = EquipInfo;

typedef GoldGoodInfo = GoodsCommon;
typedef DiamondGoodInfo = GoodsCommon;
typedef EnergyGoodInfo = GoodsCommon;
typedef ExpGoodInfo = GoodsCommon;
typedef GonUpGroupInfo = GoodsCommon;
typedef GonUpLevelInfo = GoodsCommon;
typedef PetUpGroupInfo = GoodsCommon;
typedef PetUpLevelInfo = GoodsCommon;
typedef PointGoodInfo = GoodsCommon;

class ItemProto
{
	private var _proto:StringMap<Dynamic>;
	public function new()
	{
		//Std.string(GoldGoodInfo);
	}
	public static function initGoodsVo():Dynamic
	{
		return { ID:0, ItemType:0, strLv:0, strExp:0, Upgrade:0, Equip:0, Bullets:0, keyId:0, sortInt:0, backupIndex: -1 };
	}
	
	
}