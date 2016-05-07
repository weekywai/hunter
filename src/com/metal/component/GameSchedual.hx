package com.metal.component ;
import com.metal.config.EquipProp;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.config.TableType;
import com.metal.enums.BagInfo;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.network.RemoteSqlite;
import com.metal.proto.ProtoUtils;
import com.metal.proto.impl.MapStarInfo;
import com.metal.proto.impl.NewsInfo;
import com.metal.proto.impl.PlayerInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.PlayerModelManager;
import com.metal.scene.GameFactory;
import com.metal.utils.FileUtils;
import com.metal.utils.LoginFileUtils;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;
import de.polygonal.core.time.Timebase;
import haxe.ds.IntMap;

using com.metal.proto.impl.ItemProto;
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
			playerInfo.data.SKILL2,
			playerInfo.data.SKILL3,
			playerInfo.data.SKILL4,
			playerInfo.data.SKILL5		
			]; 
	}
	
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
		cmd_playerInfo(null);
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			//case MsgNet.AssignAccount:
				//cmd_playerInfo(userData);
			case MsgNet.UpdateInfo:
				cmd_updateInfo(userData);
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
		}
		super.onUpdate(type, source, userData);
	}
	
	private function cmd_GameInit():Void
	{
		var hpMax = playerInfo.data.MAX_HP;
		playerInfo.data.HP = hpMax;
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
		trace("init playerInfo:" +playerInfo);
		setNewBie();
	}
	
	/**更新角色属性 并存储*/
	private function cmd_updateInfo(userData:Dynamic)
	{
		//发送更新属性消息
		if (userData != null) {
			switch (userData.type) {
				case PlayerProp.WEAPON:
					var weapon:EquipInfo = ProtoUtils.castType(userData.data);
					var weaponLv = EquipProp.Strengthen(weapon, weapon.vo.strLv);
					var base = PlayerModelManager.instance.getInfo(playerInfo.data.ROLEID);
					var fightNum:Int =  Std.int(weapon.Att * weaponLv.Attack / 10000) + base.Att;
					//trace("fightNum: "+fightNum);
					playerInfo.data.FIGHT = fightNum;
					if (playerInfo.data.WEAPON != weapon.keyId)
						RemoteSqlite.instance.updateProfile(TableType.P_Goods, {Equip:0}, {ID:playerInfo.data.WEAPON} );
					playerInfo.data.WEAPON = weapon.vo.keyId;
					RemoteSqlite.instance.updateProfile(TableType.P_Goods, {Equip:1}, {ID:weapon.ID} );
				case PlayerProp.ARMOR:
					var armor:EquipInfo = ProtoUtils.castType(userData.data);
					var armorLv = EquipProp.Strengthen(armor, armor.vo.strLv);
					var base = PlayerModelManager.instance.getInfo(playerInfo.data.ROLEID);
					var equipHP:Int = Std.int(armor.Hp * armorLv.HPvalue / 10000) + base.HP;
					playerInfo.data.HP = equipHP;
					playerInfo.data.MAX_HP = equipHP;
					if (playerInfo.data.ARMOR != armor.keyId)
						RemoteSqlite.instance.updateProfile(TableType.P_Goods, {Equip:0}, {ID:playerInfo.data.ARMOR} );
					playerInfo.data.ARMOR = armor.vo.keyId;
					RemoteSqlite.instance.updateProfile(TableType.P_Goods, {Equip:1}, {ID:armor.ID} );
				default:
					if (userData.type == PlayerProp.ROLEID){
						playerInfo.data.ROLEID = userData.data;
						var base = PlayerModelManager.instance.getInfo(playerInfo.data.ROLEID);
						var bag:BagInfo = owner.getComponent(BagpackSystem).bagData;
						var weapon = ProtoUtils.castType(bag.getItem(playerInfo.data.WEAPON));
						var weaponLv = EquipProp.Strengthen(weapon, weapon.vo.strLv);
						var fightNum:Int =  Std.int(weapon.Att * weaponLv.Attack / 10000) + base.Att;
						playerInfo.data.FIGHT = fightNum;
						var armor:EquipInfo = ProtoUtils.castType(bag.getItem(playerInfo.data.ARMOR));
						var armorLv = EquipProp.Strengthen(armor, armor.vo.strLv);
						var equipHP:Int = Std.int(armor.Hp * armorLv.HPvalue / 10000) + base.HP;
						playerInfo.data.HP = equipHP;
						playerInfo.data.MAX_HP = equipHP;
					}
					saveInfo(userData);
			}
			
		}
		//更新界面
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo);
	}
	
	private function cmd_updataReward(userData:Dynamic)
	{
		trace("cmd_updataReward");
		var gold = playerInfo.data.GOLD;
		if ((gold + userData) < 0) {
			GameProcess.SendUIMsg(MsgUI.Tips, { msg:"金币不足请购买金币", type:TipsType.tipPopup} );
			return;
		}
		//发送更新奖励消息
		var money = playerInfo.data.GOLD + userData;
		playerInfo.data.GOLD = money;
		RemoteSqlite.instance.updateProfile(TableType.P_Info, {GOLD:playerInfo.data.GOLD});
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo);		
	}
	private function cmd_updataGem(userData:Dynamic)
	{
		var gem = playerInfo.data.GEM;
		if((gem + userData)<0){
			GameProcess.SendUIMsg(MsgUI.Tips, { msg:"钻石不足请充值", type:TipsType.tipPopup} );
			return;
		}
		//发送更新钻石消息
		var gem = playerInfo.data.GEM + userData;
		playerInfo.data.GEM = gem;
		RemoteSqlite.instance.updateProfile(TableType.P_Info, {GEM:playerInfo.data.GEM});
		GameProcess.NotifyUI(MsgUIUpdate.UpdateInfo);
		trace("cmd_updataGem");
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
				playerInfo.data.SKILL2 = 1011;
				RemoteSqlite.instance.updateProfile(TableType.P_Info, {SKILL2:playerInfo.data.SKILL2});
			case 3:
				playerInfo.data.SKILL3 = 1411;
				RemoteSqlite.instance.updateProfile(TableType.P_Info, {SKILL3:playerInfo.data.SKILL3});
			case 4:
				playerInfo.data.SKILL4 = 1611;
				RemoteSqlite.instance.updateProfile(TableType.P_Info, {SKILL4:playerInfo.data.SKILL4});
			case 5:
				playerInfo.data.SKILL5 = 1511;
				RemoteSqlite.instance.updateProfile(TableType.P_Info, {SKILL5:playerInfo.data.SKILL5});
		}
	}
	
	private function cmd_UpdateBgm(userData:Dynamic)
	{
		if (userData)
		{
			playerInfo.data.BGM = 1;
		}else
		{
			playerInfo.data.BGM = 0;
		}
		SfxManager.StopBGM = userData;
		RemoteSqlite.instance.updateProfile(TableType.P_Info, {BGM:playerInfo.data.BGM});
	}
	
	private function cmd_UpdateSound(userData:Dynamic)
	{
		if (userData)
		{
			playerInfo.data.SOUNDS = 1;
		}else
		{
			playerInfo.data.SOUNDS = 0;
		}
		SfxManager.StopSound = userData;
		RemoteSqlite.instance.updateProfile(TableType.P_Info, {SOUNDS:playerInfo.data.SOUNDS});
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
			var req = RemoteSqlite.instance.requestProfile(TableType.P_Map, "ID", userData.mapId);
			if (req != null)
				RemoteSqlite.instance.updateProfile(TableType.P_Map, { StarCount:userData.starNum }, { ID:userData.mapId } );
			else
				RemoteSqlite.instance.addProfile(TableType.P_Map, userData);
		}
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
		saveInfo(userData);
	}
	
	private function cmd_UpdateInitFileData():Void
	{
		if (_isInitData)
			return;
		initMapStar();
		_newMap = FileUtils.getNewsInfo();
		//if (FileUtils.FileExits) FileUtils.analyticalData();
		var sNum:Int = playerInfo.data.SOUNDS;
		var bNum:Int = playerInfo.data.BGM;
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
	private function saveInfo(data:Dynamic)
	{
		Reflect.setField(playerInfo.data, Std.string(data.type), data.data);
		var o = { };
		Reflect.setProperty(o, Std.string(data.type), data.data);
		RemoteSqlite.instance.updateProfile(TableType.P_Info, o);
	}
	public function setNewBie()
	{
		//return newbieList = [1];
		//if(LoginFileUtils.Id!="null")
		newbieList = LoginFileUtils.getNewBie();//记录已打开过的新手界面
		trace("before_newbieList="+newbieList);
	}
}