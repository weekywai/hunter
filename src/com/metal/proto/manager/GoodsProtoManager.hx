package com.metal.proto.manager;
import com.metal.component.GameSchedual;
import com.metal.config.ItemType;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.DiamondGoodInfo;
import com.metal.proto.impl.EnergyGoodInfo;
import com.metal.proto.impl.ExpGoodInfo;
import com.metal.proto.impl.FashionInfo;
import com.metal.proto.impl.GoldGoodInfo;
import com.metal.proto.impl.GonUpGroupInfo;
import com.metal.proto.impl.GonUpLevelInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.PointGoodInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.utils.FileUtils;
import de.polygonal.core.math.Limits;
import haxe.ds.IntMap;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.xml.Fast;
//import com.metal.proto.impl.ArmsInfo;
//import com.metal.proto.impl.DiamondGoodInfo;
//import com.metal.proto.impl.EnergyGoodInfo;
//import com.metal.proto.impl.ExpGoodInfo;
//import com.metal.proto.impl.FashionInfo;
//import com.metal.proto.impl.GoldGoodInfo;
//import com.metal.proto.impl.PetGoodsInfo;
//import com.metal.proto.impl.PetUpGroupInfo;
//import com.metal.proto.impl.PetUpLevelInfo;
//import com.metal.proto.impl.PointGoodInfo;

/**
 * 物品管理
 * @author weeky
 */
class GoodsProtoManager
{
	public static var instance(default, null):GoodsProtoManager = new GoodsProtoManager();
	
	//小类字典
	private var _protoWeapon:IntMap<WeaponInfo>;//7枪械
	private var _protoFashion:IntMap<FashionInfo>;//8服装
	//private var _protoPet:IntMap<PetGoodsInfo>;//9宠物
	private var _protoGonGroup:IntMap<GonUpGroupInfo>;//10
	private var _protoGonLv:IntMap<GonUpLevelInfo>;//11
	//private var _protoPetGroup:IntMap<PetUpGroupInfo>;//12
	//private var _protoPetLv:IntMap<PetUpLevelInfo>;//13
	private var _protoDiamond:IntMap<DiamondGoodInfo>;//14
	private var _protoGold:IntMap<GoldGoodInfo>;//15
	private var _protoExp:IntMap<ExpGoodInfo>;//16
	private var _protoEnergy:IntMap<EnergyGoodInfo>;//17
	private var _protoPoint:IntMap<PointGoodInfo>;//18
	private var _protoArm:IntMap<ArmsInfo>;//13护甲
	private var _protoBuff:IntMap<ItemBaseInfo>;//19---14buff
	private var _protoProps:IntMap<ItemBaseInfo>;//15----钥匙
	
	
	//id-小类型 字典
	private var _protoType:IntMap<Int>;
	//所有物品
	private var _protoAll:IntMap<ItemBaseInfo>;
	
	public function new() 
	{
		_protoType = new IntMap<Int>();
		
		_protoAll = new IntMap<ItemBaseInfo>();
		
		
		//------------------小类容器
		_protoWeapon = new IntMap();//7
		_protoFashion = new IntMap();//8
		_protoGonGroup = new IntMap();//10
		_protoGonLv = new IntMap();//11
		//_protoPetGroup = new IntMap();//12
		//_protoPetLv = new IntMap();//13
		_protoDiamond = new IntMap();///14/
		_protoGold = new IntMap();//15
		_protoExp = new IntMap();//16
		_protoEnergy = new IntMap();//17
		_protoPoint = new IntMap();//18
		_protoArm = new IntMap();
		_protoBuff = new IntMap();
		_protoProps = new IntMap();
		
		keyIdMap = new IntMap();
		emptyKeyId = 0;
	}
	

	
	/**通过物品id和类型 获得对应的物品类**/
	public function getItemProtoByIdAndType(id:Int,type:Int):ItemBaseInfo
	{
		switch(type) {
			case ItemType.IK2_GON:
				return getWeaponProto(id);
			case ItemType.IK2_FASHION:
				return getFashionProto(id);
			//case ItemType.IK2_PET:
				//return getPETProto(id);
			case ItemType.IK2_GON_PROMOTED:
				return getGonGroupProto(id);
			case ItemType.IK2_GON_UPGRADE:
				return getGonLvProto(id);
			//case ItemType.IK2_PET_PROMOTED:
				//return getPetGroupProto(id);
			//case ItemType.IK2_PET_UPGRADE:
				//return getPetLvProto(id);
			//case ItemType.IK2_DIAMOND:
				//return getDiamondProto(id);
			case ItemType.IK2_GOLD:
				return getGoldProto(id);
			case ItemType.IK2_EXP:
				return getExpProto(id);
			case ItemType.IK2_ENERGY:
				return getEnergyProto(id);
			case ItemType.IK2_POINT:
				return getPointProto(id);
			case ItemType.IK2_ARM:
				return getArm(id);
			case ItemType.IK2_BUFF:
				return getBuff(id);
			case ItemType.IK2_PROPS:
				return getProps(id);
		}
		return null;
	}
	
	
	
	/**通过id拿到物品,默认创建新物品*/
	public function getItemById(id:Int,createNewItem:Bool=true):ItemBaseInfo
	{
		var itemType:Int = this.getItemLittleKind(id);
		if (createNewItem) 
		{
			return getNewItem(id,itemType);
		}else 
		{
			return this.getItemProtoByIdAndType(id, itemType);
		}
	}
	/**将物品序列化再反序列化后获得一个新物品*/
	private function getNewItem(id:Int,itemType:Int):ItemBaseInfo
	{
		var temp:ItemBaseInfo = Unserializer.run(Serializer.run(this.getItemProtoByIdAndType(id, itemType)));		
		temp.keyId = findEmptyKeyId();
		keyIdMap.set(temp.keyId, temp);
		//trace("maxKeyId: "+temp.keyId);
		return temp;
	}
	var keyIdMap:IntMap<ItemBaseInfo>;
	var emptyKeyId:Int;
	/**建立以keyId为索引的ItemMap*/
	public function buildKeyIdMap()
	{
		var bagItemArr =cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData.itemArr;
		for (i in 0...bagItemArr.length) 
		{
			if (keyIdMap.get(bagItemArr[i].keyId)==null)
			{
				keyIdMap.set(bagItemArr[i].keyId, bagItemArr[i]);
				if (bagItemArr[i].keyId > emptyKeyId) emptyKeyId = bagItemArr[i].keyId;
			}else 
			{
				//trace("same keyId"+bagItemArr[i].keyId);
			}			
		}
		bagItemArr = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.itemArr;
		for (i in 0...bagItemArr.length) 
		{
			if (keyIdMap.get(bagItemArr[i].keyId)==null)
			{
				keyIdMap.set(bagItemArr[i].keyId, bagItemArr[i]);
				if (bagItemArr[i].keyId > emptyKeyId) emptyKeyId = bagItemArr[i].keyId;
			}else 
			{
				trace("same keyId"+bagItemArr[i].keyId);
			}			
		}
	}
	/**找空的主键值*/
	private function findEmptyKeyId():Int
	{
		while (keyIdMap.get(emptyKeyId)!=null) 
		{
			emptyKeyId++;
			if (emptyKeyId>=Limits.INT32_MAX-1) 
			{
				emptyKeyId = 0;
				trace("emptyKeyId > intMax");
			}
		}
		return emptyKeyId;
	}
	/**获得物品的小类*/
	public function getItemLittleKind(key:Int):Int
	{
		return _protoType.get(key);
	}
	
	
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		var propItem:Fast, id:Int, kind:Int;
		for (propItem in source.nodes.propItem) {
			id = Std.parseInt(propItem.node.ID.innerData);
			kind = Std.parseInt(propItem.node.ItemKind2.innerData);//小类
			//id对应类型
			_protoType.set(id, kind);
			var allInfo:ItemBaseInfo = new ItemBaseInfo();
			allInfo.readXml(propItem);
			_protoAll.set(allInfo.itemId, allInfo);
			var info:Dynamic;
			switch (kind) {
				case ItemType.IK2_GON://枪械7
					info = new WeaponInfo();
					info.readXml(propItem);
					_protoWeapon.set(id, info);
				case ItemType.IK2_FASHION://服装8
					info = new FashionInfo();
					info.readXml(propItem);
					_protoFashion.set(id, info);
				//case ItemType.IK2_PET://宠物9
					//info = new PetGoodsInfo();
					//info.readXml(propItem);
					//_protoPet.set(id, info);
				case ItemType.IK2_GON_PROMOTED://枪械进阶材料10
					info = new GonUpGroupInfo();
					info.readXml(propItem);
					_protoGonGroup.set(id, info);
				case ItemType.IK2_GON_UPGRADE://枪械强化材料11
					info = new GonUpLevelInfo();
					info.readXml(propItem);
					_protoGonLv.set(id, info);
				//case ItemType.IK2_PET_PROMOTED://宠物进阶材料12
					//info = new PetUpGroupInfo();
					//info.readXml(propItem);
					//_protoPetGroup.set(id, info);
				//case ItemType.IK2_PET_UPGRADE://宠物强化材料13
					//info = new PetUpLevelInfo();
					//info.readXml(propItem);
					//_protoPetLv.set(id, info);
				case ItemType.IK2_DIAMOND://钻石14
					info = new DiamondGoodInfo();
					info.readXml(propItem);
					_protoDiamond.set(id, info);
				case ItemType.IK2_GOLD://金币15
					info = new GoldGoodInfo();
					info.readXml(propItem);
					_protoGold.set(id, info);
				case ItemType.IK2_EXP://经验16
					info = new ExpGoodInfo();
					info.readXml(propItem);
					_protoExp.set(id, info);
				case ItemType.IK2_ENERGY://体力17
					info = new EnergyGoodInfo();
					info.readXml(propItem);
					_protoEnergy.set(id, info);
				case ItemType.IK2_POINT://积分18
					info = new PointGoodInfo();
					info.readXml(propItem);
					_protoPoint.set(id, info);
				case ItemType.IK2_ARM://护甲13
					info = new ArmsInfo();
					info.readXml(propItem);
					_protoArm.set(id, info);	
				case ItemType.IK2_BUFF://buff
					info = new ItemBaseInfo();
					info.readXml(propItem);
					_protoBuff.set(id, info);
				case ItemType.IK2_PROPS://副本钥匙
					info = new ItemBaseInfo();
					info.readXml(propItem);
					_protoProps.set(id, info);
			}
		}
	}
	
	
	/**武器7*/
	private function getWeaponProto(key:Int):WeaponInfo
	{
		return _protoWeapon.get(key);
	}
	/**服装8*/
	private function getFashionProto(key:Int):FashionInfo
	{
		return _protoFashion.get(key);
	}
	
	/**宠物材料9*/
	//private function getPETProto(key:Int):PetGoodsInfo
	//{
		//return _protoPet.get(key);
	//}
	/**武器进阶材料10*/
	private function getGonGroupProto(key:Int):GonUpGroupInfo
	{
		return _protoGonGroup.get(key);
	}
	
	/**武器升级材料11*/
	private function getGonLvProto(key:Int):GonUpLevelInfo
	{
		return _protoGonLv.get(key);
	}
	
	/**宠物进阶材料12*/
	//private function getPetGroupProto(key:Int):PetUpGroupInfo
	//{
		//return _protoPetGroup.get(key);
	//}
	
	/**宠物升级材料13*/
	//private function getPetLvProto(key:Int):PetUpLevelInfo
	//{
		//return _protoPetLv.get(key);
	//}
	
	/**钻石*/
	private function getDiamondProto(key:Int):DiamondGoodInfo
	{
		return _protoDiamond.get(key);
	}
	
	/**金币*/
	private function getGoldProto(key:Int):GoldGoodInfo
	{
		return _protoGold.get(key);
	}
	
	/**经验*/
	private function getExpProto(key:Int):ExpGoodInfo
	{
		return _protoExp.get(key);
	}
	
	/**体力*/
	private function getEnergyProto(key:Int):EnergyGoodInfo
	{
		return _protoEnergy.get(key);
	}
	
	/**积分*/
	private function getPointProto(key:Int):PointGoodInfo
	{
		return _protoPoint.get(key);
	}
	
	/**buff**/
	public function getBuff(key:Int):ItemBaseInfo
	{
		return _protoBuff.get(key);
	}
	/**钥匙**/
	public function getProps(key:Int):ItemBaseInfo
	{
		return _protoProps.get(key);
	}
	
	/**护甲**/
	public function getArm(key:Int):ArmsInfo
	{
		return _protoArm.get(key);
	}
	
	//设置初始值
	private function EnsureWeapon(key:Int):WeaponInfo {
		var weapon:WeaponInfo = _protoWeapon.get(key);
		if (weapon == null) {
			weapon = new WeaponInfo();
			weapon.initDefaultValues();
			_protoWeapon.remove(key);
			_protoWeapon.set(key, weapon);
		} 
		return weapon;
	}
	
	/**获取所有物品样本*/
	public function getAll():IntMap<ItemBaseInfo>
	{
		return _protoAll;
	}
	
	/**获取道具的品质资源路劲**/
	public  function getColorSrc(id:Int,num:Int=1):String
	{
		var src:String ="";
		switch(num)
		{
			case 1:
				src = "icon/quality/" + getItemById(id).InitialQuality + ".png";
			case 0:
				src = "icon/quality/" + getItemById(id).InitialQuality + "_1" + ".png";
			case 2:
				src = "icon/quality/" + getItemById(id).InitialQuality + "_2" + ".png";//大 外框
			case 3:
				src = "icon/quality/" + getItemById(id).InitialQuality + "_3" + ".png";//大 内背景
		}
		return src;
	}
	
	
	/**获取道具的图标资源路劲***/
	public function getIconSrc(id:Int):String
	{
		var src:String ;
		src = "icon/" + getItemById(id).ResId + ".png";
		return src;
	}
	/**获取子id*/
	public function getSubID(id:Int):Int 
	{
		return getItemById(id).SubId;
	}
	
	
}