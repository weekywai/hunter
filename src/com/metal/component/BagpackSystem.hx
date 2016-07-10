package com.metal.component;

import com.metal.config.ItemType;
import com.metal.config.PlayerPropType.PlayerProp;
import com.metal.config.SfxManager;
import com.metal.config.TableType;
import com.metal.enums.BagInfo;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.network.RemoteSqlite;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ItemProto.EquipInfo;
import com.metal.proto.impl.ItemProto.GoodsVo;
import com.metal.proto.impl.ItemProto.ItemBaseInfo;
import com.metal.proto.impl.PlayerInfo;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;

/**
 * ...
 * @author weeky
 */
class BagpackSystem extends Component
{
	/**背包数据*/
	private var _bagData:BagInfo;
	public var bagData(get, null):BagInfo;
	private function get_bagData():BagInfo { return _bagData; }
	
	var _playerInfo:PlayerInfo;
	public var playerInfo(get, null):PlayerInfo;
	function get_playerInfo():PlayerInfo
	{
		if (_playerInfo == null)	{
			_playerInfo = PlayerUtils.getInfo();
		}
		return _playerInfo;
	}
	
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
			case MsgNet.UpdateBag:
				cmd_UpdateBag(userData);
			case MsgPlayer.UpdateInitFileData:
				cmd_UpdateInitFileData();
			case MsgNet.BuyOneClip:
				cmd_BuyOneClip(userData);
			case MsgNet.BuyFullClip:
				cmd_BuyFullClip(userData);
		}
		super.onUpdate(type, source, userData);
	}
	
	private function cmd_UpdateBag(userData:Dynamic)
	{
		switch(userData.type) {
			case 0: _bagData.removeGoods(userData.data);
			case 1: _bagData.addGoods(userData.data);
			case 2:	updateEquip(userData);
		}
	}
	private function updateEquip(userData:Dynamic)
	{
		var equip:GoodsVo = userData.data;
		var keyId:Int=0, propType:PlayerProp =null;
		if (equip.Kind == ItemType.IK2_GON) {
			if(equip.keyId!=playerInfo.data.WEAPON)
				keyId = playerInfo.data.WEAPON;
			propType = PlayerProp.WEAPON;
		}else if (equip.Kind == ItemType.IK2_ARM) {
			if(equip.keyId!=playerInfo.data.ARMOR)
				keyId = playerInfo.data.ARMOR;
			propType = PlayerProp.ARMOR;
		}
		
		var item = bagData.getItemByKeyId(keyId);
		if (item != null){
			item.vo.Equip = false;
			_bagData.updateGoods(item.vo); 	//RemoteSqlite.instance.updateProfile(TableType.P_Goods, { Equip:0 }, { keyId:playerInfo.data.WEAPON } );
		}
		equip.Equip = true;
		_bagData.updateGoods(equip); 	//RemoteSqlite.instance.updateProfile(TableType.P_Goods, { Equip:1 }, { keyId:equip.keyId } );
		notify(MsgNet.UpdateInfo, { type:propType, data:bagData.getItemByKeyId(equip.keyId) } );
		GameProcess.NotifyUI(MsgUIUpdate.Warehouse, equip.ID);
	}
	
	//{****************背包*****************************
	/**初始化背包及装备*/
	public function initBag():Void
	{
		var request = RemoteSqlite.instance.requestProfile(TableType.P_Goods);
		//trace("initBag::"+request);
		var itemArr = [];
		var itemIdArr:Array<Int>;
		if (request==null)
		{
			itemIdArr = [101, 201, 301, 401, 501, 10011, 10012, 10013, 10014, 10015, 10016, 10007, 10008, 10009, 10010];
			var req = RemoteSqlite.instance.request(TableType.Item, "ID", itemIdArr.join(","));
			
			Lambda.find(req, function (e) { 
				for (i in itemIdArr) 
				{
					if (e.ID == i){
						var item:ItemBaseInfo = e;
						//当前武器
						if (e.ID == 401 || e.ID == 501)
							item.vo = { ID:e.ID, Kind:e.Kind, strLv:0, strExp:0, Upgrade:0, Equip:true, Bullets:0, Clips:0, sortInt:-1 };
						else
							item.vo = { ID:e.ID, Kind:e.Kind, strLv:0, strExp:0, Upgrade:0, Equip:false, Bullets:0, Clips:0, sortInt:-1 };
						itemArr.push(item);
					}
				}
				return false;
			} );
			
			//记录武器
			for (item in itemArr)
			{				
				if (item.Kind == ItemType.IK2_ARM) {
					playerInfo.data.ARMOR = item.keyId;
				}
				else if (item.Kind == ItemType.IK2_GON)
				{
					playerInfo.data.WEAPON = item.keyId;
				}
				//添加入数据库
				RemoteSqlite.instance.addProfile(TableType.P_Goods, null, item.vo);
			}
		}else {
			var values:String = "";
			for (i in 0...request.length) 
			{
				if (i != request.length - 1)
					values += request[i].ID + ",";
				else
					values += request[i].ID;
			}
			var req = RemoteSqlite.instance.request(TableType.Item, "ID", values);
			for (r in req) 
			{
				var item:ItemBaseInfo = r;
				for (j in request) 
				{
					if(j.ID==item.ID){
						item.vo = j;
						//trace(item.vo.Equip);
						itemArr.push(item);
					}
				}
			}
		}
		_bagData = new BagInfo();
		_bagData.itemArr = itemArr;
		_bagData.buildBackupWeaponMap();
	}
	
	private function cmd_UpdateInitFileData():Void
	{
		if (_isInitData)
			return;
		initBag();
		//trace(playerInfo.data.WEAPON);
		var equip = bagData.getItemByKeyId(playerInfo.data.WEAPON);
		notify(MsgNet.UpdateInfo, { type:PlayerProp.WEAPON, data:equip } );
		equip = bagData.getItemByKeyId(playerInfo.data.ARMOR);
		notify(MsgNet.UpdateInfo, { type:PlayerProp.ARMOR, data:equip } );
		
		
		//if (FileUtils.FileExits) FileUtils.analyticalData();
		
		GameProcess.NotifyUI(MsgUIUpdate.UpdateModel, null);
		var sNum:Int = playerInfo.data.SOUNDS;
		var bNum:Int = playerInfo.data.BGM;
		SfxManager.StopBGM = (bNum == 1)?true:false;
		SfxManager.StopSound = (sNum == 1)?true:false;
		_isInitData = true;
	}
	/**userdata.weapon=WeaponInfo,userdata.txt=Text*/
	private function cmd_BuyOneClip(userData:Dynamic)
	{
		//trace("cmd_BuyOneClip");
		var weapon:EquipInfo = userData;
		var gold = playerInfo.data.GOLD;
		
		if (weapon.vo.Clips == weapon.MaxBackupBullet && weapon.vo.Bullets == weapon.OneClip) return;
		if (gold >= weapon.ClipCost) 
		{	
			var msg:String = "";
			if (weapon.vo.Bullets + weapon.vo.Clips >=  weapon.MaxBackupBullet) 
			{
				weapon.vo.Clips = weapon.MaxBackupBullet;
				msg = "已达子弹上限";
			}else 
			{
				weapon.vo.Clips += weapon.vo.Bullets;
				msg = "购买成功";
			}				
			weapon.vo.Bullets = weapon.OneClip;
			RemoteSqlite.instance.updateProfile(TableType.P_Goods, weapon.vo, { ID:weapon.ID } );
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
		var weapon:EquipInfo = userData.weapon;
		var gold = playerInfo.data.GOLD;
		if (weapon.vo.Clips == weapon.MaxBackupBullet && weapon.vo.Bullets == weapon.OneClip) return;
		var cost:Int = Math.floor((weapon.ClipCost / weapon.OneClip) * (weapon.MaxBackupBullet + weapon.OneClip - weapon.vo.Clips - weapon.vo.Bullets));
		if (gold>=cost) 
		{
			weapon.vo.Clips = weapon.MaxBackupBullet;
			weapon.vo.Bullets = weapon.OneClip;
			RemoteSqlite.instance.updateProfile(TableType.P_Goods, weapon.vo, { ID:weapon.ID } );
			//通知UI更新
			if(userData.text!=null) userData.text.text = "子弹数 " + userData.weapon.vo.Bullets + "/" + userData.weapon.vo.Clips;
			if (userData.noTip == null) GameProcess.SendUIMsg(MsgUI.Tips, { msg:"购买成功", type:TipsType.tipPopup} );
		}
		notify(MsgPlayer.UpdateMoney, -cost);
	}
}