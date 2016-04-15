package com.metal.component ;
import com.metal.config.EquipProp;
import com.metal.config.FilesType;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.BagInfo;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgBoard;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerInfo;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.MapStarInfo;
import com.metal.proto.impl.NewsInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.PlayerModelManager;
import com.metal.scene.GameFactory;
import com.metal.utils.FileUtils;
import com.metal.utils.LoginFileUtils;
import de.polygonal.core.es.Entity;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;
import de.polygonal.core.time.Timebase;
import haxe.ds.IntMap;
import haxe.Serializer;
import haxe.Unserializer;
/**
 * ...
 * @author weeky
 */
class GameSchedual extends Component
{
	private var _newMap:IntMap<NewsInfo>;
	public var newMapInfo(get, null):IntMap<NewsInfo>;
	private function get_newMapInfo():IntMap<NewsInfo> { return _newMap; }
	
	public var playerInfo(default, null):PlayerInfo;
	
	/**技能锁数据*/
	public var skillData(get, null):Array<Int>;
	private function get_skillData() :Array<Int> { 
		return [
			playerInfo.getProperty(PlayerPropType.SKILL2),
			playerInfo.getProperty(PlayerPropType.SKILL3),
			playerInfo.getProperty(PlayerPropType.SKILL4),
			playerInfo.getProperty(PlayerPropType.SKILL5)
		]; }
	
	/**背包数据*/
	private var _bagData:BagInfo;
	public var bagData(get, null):BagInfo;
	private function get_bagData():BagInfo { return _bagData; }
	
	/**装备背包数据**/
	private var _equipBagData:BagInfo;
	public var equipBagData(get, null):BagInfo;
	private function get_equipBagData():BagInfo { return _equipBagData; }
	
	
	private var _factory:GameFactory;
	
	/**新手帮助记录*/
	public var newbieList:Array<Int> ;
	private var _isInitData:Bool = false;
	
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgNet.AssignAccount:
				cmd_playerInfo(userData);
			case MsgNet.UpdateInfo:
				cmd_updateInfo(userData);
			case MsgNet.UpdateBag:
				cmd_UpdateBag(userData);
			case MsgNet.UpdateResources:
				cmd_updateResource(userData);
			case MsgStartup.GameInit:
				//cmd_GameInit();
			case MsgNet.OpenStage: //更新开启副本
				cmd_OpenStage(userData);
			case MsgPlayer.UpdateMoney:
				cmd_updataReward(userData);
			case MsgPlayer.UpdateGem:
				cmd_updataGem(userData);
			case MsgPlayer.UpdateSkill:
				cmd_UpdateSkill(userData);
			case MsgPlayer.UpdateBGM:
				cmd_UpdateBgm(userData);
			case MsgPlayer.UpdateSounds:
				cmd_UpdateSound(userData);
			case MsgPlayer.UpdateInitFileData:
				cmd_UpdateInitFileData();
			case MsgView.NewBie:
				cmd_NewBie(userData);
			case MsgPlayer.UpdateInfo:
				cmd_updatePlayerInfo(userData);
			case MsgStartup.UpdateStar:
				cmd_updateMapStar(userData);
			case MsgNet.BuyOneClip:
				cmd_BuyOneClip(userData);
			case MsgNet.BuyFullClip:
				cmd_BuyFullClip(userData);
		}
		super.onUpdate(type, source, userData);
	}
	
	private function cmd_GameInit():Void
	{
		var hpMax = playerInfo.getProperty(PlayerPropType.MAX_HP);
		playerInfo.setProperty(PlayerPropType.HP, hpMax);
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo); 
		trace("cmd_GameInit");
	}
	
	private function cmd_PostBoot():Void { }
	private function cmd_OpenStage(userData:Dynamic):Void { }
	private function cmd_playerInfo(userData:Dynamic)
	{
		
		//发送进入游戏获取到角色信息消息
		//GameProcess.NotifyUI(MsgUIUpdate.UpdateUI);
		playerInfo = FileUtils.getPlayerInfo();
		trace("init playerInfo:" +playerInfo + " RoleId:" + playerInfo.RoleId);
		setNewBie();
	}
	
	/**更新角色属性 并存储*/
	private function cmd_updateInfo(userData:Dynamic)
	{
		//发送更新属性消息
		if (userData != null) {
			switch (userData.type) {
				case PlayerPropType.WEAPON:
					var weapon:WeaponInfo = cast userData.data;
					var weaponLv = EquipProp.Strengthen(weapon, weapon.strLv);
					var base = PlayerModelManager.instance.getInfo(playerInfo.getProperty(PlayerPropType.ROLEID));
					var fightNum:Int =  Std.int(weapon.Att * weaponLv.Attack / 10000) + base.Att;
					//trace("fightNum: "+fightNum);
					playerInfo.setProperty(PlayerPropType.FIGHT, fightNum);
					//playerInfo.setProperty(PlayerPropType.WEAPON, weapon.itemId);111
					if(weapon.itemIndex<1000)weapon.itemIndex += 1000;					
					playerInfo.setProperty(PlayerPropType.WEAPON, weapon.keyId);					
					_equipBagData.itemArr[0] = cast weapon;
					FileUtils.setFileData(null, FilesType.EquipBag);
				case PlayerPropType.ARMOR:
					var armor:ArmsInfo = cast userData.data;
					var armorLv = EquipProp.Strengthen(armor, armor.strLv);
					var base = PlayerModelManager.instance.getInfo(playerInfo.getProperty(PlayerPropType.ROLEID));
					var equipHP:Int = Std.int(armor.Hp * armorLv.HPvalue / 10000)+base.HP;
					playerInfo.setProperty(PlayerPropType.HP, equipHP);
					playerInfo.setProperty(PlayerPropType.MAX_HP, equipHP);
					//playerInfo.setProperty(PlayerPropType.ARMOR, armor.itemId);
					playerInfo.setProperty(PlayerPropType.ARMOR, armor.keyId);
					if(armor.itemIndex<1000)armor.itemIndex += 1000;
					_equipBagData.itemArr[1] = cast armor;
					FileUtils.setFileData(null, FilesType.EquipBag);
				default:
					if (userData.type == PlayerPropType.ROLEID){
						playerInfo.RoleId = userData.data;
						var base = PlayerModelManager.instance.getInfo(playerInfo.RoleId);
						var weapon:WeaponInfo = cast _equipBagData.itemArr[0];
						var weaponLv = EquipProp.Strengthen(weapon, weapon.strLv);
						var fightNum:Int =  Std.int(weapon.Att * weaponLv.Attack / 10000) + base.Att;
						playerInfo.setProperty(PlayerPropType.FIGHT, fightNum);
						var armor:ArmsInfo = cast _equipBagData.itemArr[1];
						var armorLv = EquipProp.Strengthen(armor, armor.strLv);
						var equipHP:Int = Std.int(armor.Hp * armorLv.HPvalue / 10000) + base.HP;
						playerInfo.setProperty(PlayerPropType.HP, equipHP);
						playerInfo.setProperty(PlayerPropType.MAX_HP, equipHP);
					}
					playerInfo.setProperty(userData.type, userData.data);
			}
			FileUtils.setFileData(null, FilesType.Player);
		}
		//更新界面
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo);
		//GameProcess.NotifyUI(MsgUIUpdate.UpdateModel, userData);
	}
	
	private function cmd_UpdateBag(userData:Dynamic)
	{
		//trace(userData.data);
		switch(userData.type) {
			case 0: _bagData.removeGoods(userData.data);
			case 1: _bagData.addGoods(userData.data);
		}
		FileUtils.setFileData(null, FilesType.Bag);
	}
	
	private function cmd_updataReward(userData:Dynamic)
	{
		trace("cmd_updataReward");
		var gold = playerInfo.getProperty(PlayerPropType.GOLD);
		if ((gold + userData) < 0) {
			GameProcess.SendUIMsg(MsgUI.Tips, { msg:"金币不足请购买金币", type:TipsType.tipPopup} );
			return;
		}
		//发送更新奖励消息
		var money = playerInfo.getProperty(PlayerPropType.GOLD) + userData;
		playerInfo.setProperty(PlayerPropType.GOLD, money);
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo);		
	}
	private function cmd_updataGem(userData:Dynamic)
	{
		var gem = playerInfo.getProperty(PlayerPropType.GEM);
		if((gem + userData)<0){
			GameProcess.SendUIMsg(MsgUI.Tips, { msg:"钻石不足请充值", type:TipsType.tipPopup} );
			return;
		}
		//发送更新钻石消息
		var gem = playerInfo.getProperty(PlayerPropType.GEM) + userData;
		playerInfo.setProperty(PlayerPropType.GEM, gem);
		FileUtils.setFileData(null, FilesType.Player);
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo);
		trace("cmd_updataGem");
	}
	/**userdata.weapon=WeaponInfo,userdata.txt=Text*/
	private function cmd_BuyOneClip(userData:Dynamic)
	{
		//trace("cmd_BuyOneClip");
		var weapon:WeaponInfo = userData;
		var gold = playerInfo.getProperty(PlayerPropType.GOLD);
		
		if (weapon.currentBackupBullet == weapon.MaxBackupBullet && weapon.currentBullet == weapon.OneClip) return;
		if (gold >= weapon.ClipCost) 
		{	
			var msg:String = "";
			if (weapon.currentBullet + weapon.currentBackupBullet >=  weapon.MaxBackupBullet) 
			{
				weapon.currentBackupBullet = weapon.MaxBackupBullet;
				msg = "已达子弹上限";
			}else 
			{
				weapon.currentBackupBullet += weapon.currentBullet;
				msg = "购买成功";
			}				
			weapon.currentBullet = weapon.OneClip;
			
			FileUtils.setFileData(null, FilesType.Bag);
			FileUtils.setFileData(null, FilesType.EquipBag);
			//通知UI更新
			GameProcess.NotifyUI(MsgUIUpdate.Warehouse, weapon);
			GameProcess.SendUIMsg(MsgUI.Tips, { msg:msg, type:TipsType.tipPopup} );
		}		
		notify(MsgPlayer.UpdateMoney, -weapon.ClipCost);		
	}
	/**userdata.weapon=WeaponInfo,userdata.txt=Text*/
	private function cmd_BuyFullClip(userData:Dynamic)
	{
		//trace("cmd_BuyFullClip");
		var weapon:WeaponInfo = userData.weapon;
		var gold = playerInfo.getProperty(PlayerPropType.GOLD);
		if (weapon.currentBackupBullet == weapon.MaxBackupBullet && weapon.currentBullet == weapon.OneClip) return;
		var cost:Int = Math.floor((weapon.ClipCost / weapon.OneClip) * (weapon.MaxBackupBullet + weapon.OneClip - weapon.currentBackupBullet - weapon.currentBullet));
		if (gold>=cost) 
		{
			weapon.currentBackupBullet = weapon.MaxBackupBullet;
			weapon.currentBullet = weapon.OneClip;
			FileUtils.setFileData(null, FilesType.Bag);
			FileUtils.setFileData(null, FilesType.EquipBag);
			//通知UI更新
			if(userData.text!=null) userData.text.text = "子弹数 " + userData.weapon.currentBullet + "/" + userData.weapon.currentBackupBullet;
			if (userData.noTip == null) GameProcess.SendUIMsg(MsgUI.Tips, { msg:"购买成功", type:TipsType.tipPopup} );
		}
		notify(MsgPlayer.UpdateMoney, -cost);
	}
	private function cmd_updateResource(userData:Dynamic)
	{
		//发送更新资源消息
		GameProcess.NotifyUI(MsgUIUpdate.UpdateResources);
	}
	
	
	private function cmd_UpdateSkill(userData:Dynamic)
	{
		switch(userData) {
			case 2:
				playerInfo.setProperty(PlayerPropType.SKILL2, 1011);
			case 3:
				playerInfo.setProperty(PlayerPropType.SKILL3, 1411);
			case 4:
				playerInfo.setProperty(PlayerPropType.SKILL4, 1611);
			case 5:
				playerInfo.setProperty(PlayerPropType.SKILL5, 1511);
		}
		FileUtils.setFileData(playerInfo, FilesType.Player);
	}
	
	private function cmd_UpdateBgm(userData:Dynamic)
	{
		if (userData)
		{
			playerInfo.setProperty(PlayerPropType.BGM, 1);
		}else
		{
			playerInfo.setProperty(PlayerPropType.BGM, 0);
		}
		SfxManager.StopBGM = userData;
		FileUtils.setFileData(playerInfo, FilesType.Player);
	}
	
	private function cmd_UpdateSound(userData:Dynamic)
	{
		if (userData)
		{
			playerInfo.setProperty(PlayerPropType.SOUNDS, 1);
		}else
		{
			playerInfo.setProperty(PlayerPropType.SOUNDS, 0);
		}
		SfxManager.StopSound = userData;
		FileUtils.setFileData(playerInfo, FilesType.Player);
	}
	
	//{****************背包*****************************
	/**根据背包类型初始化背包**/
	public function setBagData(bag:BagInfo,type:Int):Void {
		
		for (i in 0...bag.itemArr.length) 
		{
			//trace("bag.itemArr: "+bag.itemArr[i].Kind);
			bag.itemArr[i].setStartBullet();
		}
		if (type == ItemType.EQUIP_TYPE) {			
			_equipBagData = bag;
			//FileUtils.setFileData(_equipBagData, FilesType.equipBag);
		}else {
			_bagData = bag;
			_bagData.sort();
		}
		
	}
	/**初始化关卡星级记录*/
	public function initMapStar():Void
	{
		//trace("initMapStar");
		var dataMap:IntMap<Int> = FileUtils.getMapStarData();		
		if (dataMap!=null) 
		{
			MapStarInfo.instance.dataMap = dataMap;
		}
	}
	/**更新地图星级*/
	private function cmd_updateMapStar(userData:Dynamic)
	{
		trace("cmd_updateMapStar: "+userData);
		if (userData!=null) 
		{
			MapStarInfo.instance.setMapStar(userData.mapId, userData.starNum);
		}else 
		{
			trace(userData==null);
		}		
		FileUtils.setFileData(MapStarInfo.instance.dataMap, FilesType.StageStar);
	}
	/**初始化装备背包*/
	public function initEquipBagData():Void
	{
		var equipBag:BagInfo = FileUtils.getEquipBag();
		trace("initEquipBag::"+equipBag);
		if (equipBag == null) {
			trace("equipBag == null");
			var itemIdArr:Array<Int> = [401, 501];
			//playerInfo.setProperty(PlayerPropType.WEAPON, itemIdArr[0]);//101 203 303 403
			//playerInfo.setProperty(PlayerPropType.ARMOR, itemIdArr[1]);//403 503 603 703
			equipBag = new BagInfo();
			equipBag.itemArr = new Array<ItemBaseInfo>();
			equipBag.parnerId = 0;
			equipBag.bagType = 1;
			equipBag.maxNum =  20;
			equipBag.useNum =  itemIdArr.length;
			//trace(playerInfo);
			for (i in 0...itemIdArr.length)
			{
				var item:ItemBaseInfo = Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(itemIdArr[i])));
				item.itemIndex = 1000+i; // 区分装备				
				if (item.Kind == ItemType.IK2_ARM) {
					//playerInfo.setProperty(PlayerPropType.ARMOR, item.itemId);
					playerInfo.setProperty(PlayerPropType.ARMOR, item.keyId);
				}
				else {
					//playerInfo.setProperty(PlayerPropType.WEAPON, item.itemId);111
					item.setStartBullet();
					playerInfo.setProperty(PlayerPropType.WEAPON, item.keyId);
					//trace("currentBullet: "+item.currentBullet);
					//trace("OneClip: "+item.OneClip);
					//trace("currentBackupBullet: "+item.currentBackupBullet);
					//trace("StartClip: "+item.StartClip);
				}				
				equipBag.itemArr.push(item);
			}
		}
		setBagData(equipBag, ItemType.EQUIP_TYPE);
	}
	/**初始化背包*/
	public function initBag():Void
	{
		var bag:BagInfo = FileUtils.getBagData();
		//trace("initBag::"+bag);
		if(bag==null){
			//var itemIdArr:Array<Int> = [101, 201, 301, 401, 501, 10011, 10012, 10013, 10014, 10015, 10016, 10007, 10008, 10009, 10010];
			var itemIdArr:Array<Int> = [10011, 10012, 10013, 10014, 10015, 10016, 10007, 10008, 10009, 10010];
			bag = new BagInfo();
			bag.itemArr = new Array<ItemBaseInfo>();
			bag.parnerId = 0;
			bag.bagType = 1;
			bag.maxNum =  20;
			bag.useNum =  itemIdArr.length;
			for (i in 0...itemIdArr.length)
			{
				var goodsInfo:ItemBaseInfo = Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(itemIdArr[i])));
				goodsInfo.itemIndex = i + 1;//背包道具序号
				//if (itemIdArr[i] == 401 || itemIdArr[i] == 501)
					//goodsInfo.itemIndex = i + 1;//背包道具序号
				bag.itemArr.push(goodsInfo);
			}
		}
		setBagData(bag, ItemType.NORMAL_TYPE);
		bag.buildBackupWeaponMap();
	}
	//}
	/*更新角色属性*/
	public function createSimEntity(type:String, id:Int):SimEntity {
		if (_factory == null)
			_factory = owner.getComponent(GameFactory);
		var entity = _factory.createSimEntity(type, id);
		entity.init();
		return entity;
	}
	private function cmd_updatePlayerInfo(userData:Dynamic):Void
	{
		playerInfo.setProperty(userData.type, userData.data);
	}
	/**测试生成新物品的效率*/
	private function testUnserializer()
	{
		var starttime = Timebase.stamp();
		var testcase:ItemBaseInfo;
		for (i in 0...1000) 
		{
			testcase=GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.WEAPON),true);
		}
		var overTime = Timebase.stamp();
		trace("Unserializertime: " + (overTime-starttime));
		starttime = Timebase.stamp();
		for (i in 0...1000) 
		{
			testcase=GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.WEAPON));
		}
		overTime = Timebase.stamp();
		trace("no Unserializertime: "+(overTime-starttime));
	}
	private function cmd_UpdateInitFileData():Void
	{
		if (_isInitData)
			return;
		initBag();
		initEquipBagData();
		initMapStar();
		GoodsProtoManager.instance.buildKeyIdMap();
		//var equip = GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.WEAPON));111
		var equip = _equipBagData.getItemByKeyId(playerInfo.getProperty(PlayerPropType.WEAPON));
		cmd_updateInfo( { type:PlayerPropType.WEAPON, data:equip } );
		//equip = GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.ARMOR));
		equip = _equipBagData.getItemByKeyId(playerInfo.getProperty(PlayerPropType.ARMOR));
		cmd_updateInfo( { type:PlayerPropType.ARMOR, data:equip } );
		_newMap = FileUtils.getNewsInfo();
		if (FileUtils.FileExits) FileUtils.analyticalData();
		
		//var userData:WeaponInfo = cast GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.WEAPON));
		//var fighrtNum:Int = Std.int(userData.Att*ForgeManager.instance.getProtpForge(userData.equipType * 1000 + userData.strLv).Attack/10000);
		//playerInfo.setProperty(PlayerPropType.FIGHT, fighrtNum);

		//var armsData:ArmsInfo =  cast GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.ARMOR));
		//var HpNum:Int = Std.int(armsData.Hp * ForgeManager.instance.getProtpForge(armsData.equipType * 1000 + armsData.strLv).HPvalue / 10000)+500;
		//playerInfo.setProperty(PlayerPropType.HP, HpNum);
		//playerInfo.setProperty(PlayerPropType.MAX_HP, HpNum);
		
		GameProcess.NotifyUI(MsgUIUpdate.UpdateModel, null);
		//notify(MsgMission.Init);
		//trace(playerInfo.getProperty(PlayerPropType.SOUNDS));
		var sNum:Int = Std.int(playerInfo.getProperty(PlayerPropType.SOUNDS));
		var bNum:Int = playerInfo.getProperty(PlayerPropType.BGM);
		SfxManager.StopBGM = (bNum == 1)?true:false;
		SfxManager.StopSound = (sNum == 1)?true:false;
		_isInitData = true;
	}
	/**新手引导*/
	private function cmd_NewBie(userData:Dynamic):Void
	{
		//return;
		/**是否已打开*/
		if(LoginFileUtils.Id!="null")
			if (!Lambda.has(newbieList, userData)) {
				GameProcess.SendUIMsg(MsgUI2.GameNoviceCourse, userData);
				newbieList.push(userData);
				LoginFileUtils.saveNewBie(newbieList);
			}
	}
	
	public function setNewBie()
	{
		//return newbieList = [1];
		//if(LoginFileUtils.Id!="null")
		newbieList = LoginFileUtils.getNewBie();//记录已打开过的新手界面
		trace("before_newbieList="+newbieList);
	}
}