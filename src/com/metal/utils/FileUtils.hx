package com.metal.utils;
import com.metal.component.BagpackSystem;
import com.metal.component.GameSchedual;
import com.metal.component.RewardSystem;
import com.metal.component.TaskSystem;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.TableType;
import com.metal.enums.BagInfo;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.ItemProto.GoodsVo;
import com.metal.proto.impl.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ItemProto.ItemBaseInfo;
import com.metal.proto.impl.LiveNessInfo;
import com.metal.proto.impl.MapStarInfo;
import com.metal.proto.impl.NewbieInfo;
import com.metal.proto.impl.NewsInfo;
import com.metal.proto.impl.QuestInfo;
import com.metal.proto.manager.LiveNessManager;
import com.metal.proto.manager.NewsManager;
import com.metal.proto.manager.QuestsManager;
//import crashdumper.hooks.openfl.HookOpenFL;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.IntMap;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

#if openfl_legacy
	import openfl.utils.SystemPath;
#else
	import lime.system.System;
#end

#if (openfl >= "2.0.0")
	import openfl.Lib;
	import openfl.utils.ByteArray;
	import openfl.events.UncaughtErrorEvent;
#else
	import nme.Lib;
	import nme.utils.ByteArray;
	import flash.events.UncaughtErrorEvent;
#end
/**
 * ...储存数据
 * @author hyg
 */
/**任务数据*/
typedef TaskVo = {
	@:optional var Id:Int;
	var Finish:Int;
	var State:Int;
	var Times:Int;
}
/**活动数据*/
typedef ActiveVo = {
	@:optional var Id:Int;
	var Times:Int; 
	var Draw:Int;
}

class FileUtils
{
	
	static private var _path:String;
	static private var _data:Dynamic;
	public static inline var PATH_APPDATA:String = "%APPDATA%";			//The ApplicationStorageDirectory. Highly recommended.
	public static inline var PATH_DOCUMENTS:String = "%DOCUMENTS%";		//The Documents directory.
	public static inline var PATH_USERPROFILE:String = "%USERPROFILE%";	//The User's profile folder
	public static inline var PATH_DESKTOP:String = "%DESKTOP%";			//The User's desktop
	public static inline var PATH_APP:String = "%APP%";					//The Application's own directory
	//static private var _hook:HookOpenFL;
	/**default PATH_APP*/
	public static function getPath(str:String = PATH_APP):String
	{
		//if(_hook == null)
			//_hook = new HookOpenFL();
		//return _hook.getFolderPath(str);
		return getFolderPath(str);
	}
	public static function getFolderPath(str:String):String
	{
		#if (windows || mac || linux || mobile)
			#if (mobile)
				if (str.charAt(0) != "/" && str.charAt(0) != "\\")
				{
					str = "/" + str;
				}
				#if openfl_legacy
				str = SystemPath.applicationStorageDirectory + str;
				#else
				str = System.applicationStorageDirectory + str;
				#end
				
			#else
				#if openfl_legacy
					switch(str)
					{
						case null, "": str = SystemPath.applicationStorageDirectory;
						case PATH_APPDATA: str = SystemPath.applicationStorageDirectory;
						case PATH_DOCUMENTS: str = SystemPath.documentsDirectory;
						case PATH_DESKTOP: str = SystemPath.desktopDirectory;
						case PATH_USERPROFILE: str = SystemPath.userDirectory;
						case PATH_APP: str = SystemPath.applicationDirectory;
					}
				#else
					switch(str)
					{
						case null, "": str = System.applicationStorageDirectory;
						case PATH_APPDATA: str = System.applicationStorageDirectory;
						case PATH_DOCUMENTS: str = System.documentsDirectory;
						case PATH_DESKTOP: str = System.desktopDirectory;
						case PATH_USERPROFILE: str = System.userDirectory;
						case PATH_APP: str = System.applicationDirectory;
					}
				#end
			#end
			/*if (str != "")
			{
				if (str.lastIndexOf("/") != str.length - 1 && str.lastIndexOf("\\") != str.length - 1)
				{
					//if the path is not blank, and the last character is not a slash
					str = str + SystemData.slash();	//add a trailing slash
				}
			}*/
		#end
		return str;
	}
	
	public static var FileExits(get, null):Bool;
	static private function get_FileExits():Bool
	{
		#if sys
		_path = getPath() + "/user/";
		//return true;
		if (!FileSystem.exists(_path))
		{
			FileSystem.createDirectory(_path);
		}
		if (!FileSystem.exists(_path+LoginFileUtils.Id)) {
			saveFile("");
		}
		
		return FileSystem.exists(_path+LoginFileUtils.Id);
		#end
	}
	public function new() {}
	/**
	 * Save data to file
	 * */
	public static function saveFile(data:String):Void
	{
		#if sys
		var filePath:String = _path + LoginFileUtils.Id;
		var f:FileOutput = File.write( filePath, false );
		f.writeString(data);
		f.close();
		#end
	}
	
	private static function saveMap(type:Int, obj:Dynamic)
	{
		FilesType.fileMap.set(type, obj);
		//if (type == FilesType.Bag)
			//trace(FilesType.fileMap.get(type));
		var strData:String = Serializer.run(FilesType.fileMap);
		//var strData:String = Json.stringify(FilesType.fileMap);
		if(FileExits)
			saveFile(strData);
	}
	public static function parseData():Void
	{
		if (_data != null) 
			return;
		if (!FileExits) 
			return;
			//trace(LoginFileUtils.Id);
		var fileContent = File.getContent(_path +LoginFileUtils.Id);
		if (fileContent == null || fileContent == "")
			return;
			trace(fileContent);
		_data = Unserializer.run(fileContent);
		
		FilesType.fileMap = _data;
		//_data = Json.parse(fileContent);
	}
	
	/**分类存储数据*/
	public static function setFileData(data:Dynamic,fileType:Int):Void
	{
		switch(fileType)
		{
			case FilesType.Player:
				//setPlayerInfo();
			case FilesType.Active:
				setActive(fileType);
			case FilesType.Task:
				setTask(fileType);
			case FilesType.Bag:
				//setBagData(fileType);
			case FilesType.News:
				setNewsInfo(fileType);
			case FilesType.StageStar:
				setMapStarData(fileType);
			case FilesType.Newbie:
				setNewbieData(fileType);
		}
	}
	
	/**所有数据*/
	public static function analyticalData():Void
	{
		for (i in FilesType.fileArr)
		{
			setFileData(null, i);
		}
	}
	/**储存角色信息*/
	private static function setPlayerInfo():Void
	{
		var player = PlayerUtils.getInfo();
		var fields = Reflect.fields(player.data);
		var values:Array<Dynamic> = [];
		for (i in fields) 
		{
			values.push(Reflect.field(player, i));
		}
		RemoteSqlite.instance.addProfile(TableType.P_Info, values);
	}
	
	/**获取角色信息*/
	static public function getPlayerInfo():PlayerInfo
	{
		var request = RemoteSqlite.instance.requestProfile(TableType.P_Info);
		if (request==null){
			return initPlayer();
		}
		trace("has playerinfo");
		var p = new PlayerInfo();	
		p.data = request[0];
		return p;
	}
	/**活跃度*/
	private static function setActive(type:Int):Void
	{
		var activeInfo:IntMap<LiveNessInfo> = cast GameProcess.instance.getComponent(RewardSystem).getLiveNesss();
		var activeMap:IntMap<ActiveVo> = new IntMap();
		for (key in activeInfo.keys())
		{
			var active:ActiveVo = cast activeInfo.get(key);
			activeMap.set(key, active);
		}
		saveMap(type, activeMap);
	}
	/**获取活跃度*/
	public static function getActive():IntMap<LiveNessInfo>
	{
		var activeInfo = LiveNessManager.instance.LiveNess;
		var	req = RemoteSqlite.instance.requestProfile(TableType.P_Active);
		if (req == null)
			return activeInfo;
		var taskMap:IntMap<ActiveVo>;
		for (active in req)
		{
			if (active != null) {
				var questInfo:LiveNessInfo = activeInfo.get(active.Id);
				questInfo.vo = active;
			}
		}
		return activeInfo;
	}
	/**消息*/
	private static function setNewsInfo(type:Int):Void
	{
		/*var newsInfo = cast(GameProcess.instance.getComponent(GameSchedual), GameSchedual).newMapInfo;
		var newsMap:IntMap<Int> = new IntMap();
		//trace("save news:");
		for (key in newsInfo.keys())
		{
			var info = newsInfo.get(key);
			newsMap.set(key, info.isDraw);
		}
		saveMap(type, newsMap);*/
	}
	/**获取消息*/
	public static function getNewsInfo():IntMap<NewsInfo>
	{
		var req = RemoteSqlite.instance.requestProfile(TableType.P_News);
		if (req!=null){
			for (news in req)
			{
				var info:NewsInfo = NewsManager.instance.data.get(news.Id);
				info.isDraw = news.isDraw;
			}
		}
		return NewsManager.instance.data;
	}
	
	/**任务*/
	private static function setTask(type:Int):Void
	{
		trace("setTask");
		/*var taskInfo = GameProcess.instance.getComponent(TaskSystem).taskMap;
		var taskMap:IntMap<TaskVo> = new IntMap();
		for (key in taskInfo.keys())
		{	
			var task:TaskVo = taskInfo.get(key).vo;
			taskMap.set(key, task);
		}
		RemoteSqlite.instance.updateProfile(TableType.P_Task,);*/
		//saveMap(type, taskMap);
	}
	/**获取任务*/
	public static function getTask():IntMap<QuestInfo>
	{
		trace("getTask");
		var taskInfo = QuestsManager.instance.Task;
		var	taskArr = RemoteSqlite.instance.requestProfile(TableType.P_Task);
		if (taskArr == null)
			return taskInfo;
		var taskMap:IntMap<TaskVo>;
		for (task in taskArr)
		{
			if (task != null) {
				var questInfo:QuestInfo = taskInfo.get(task.Id);
				questInfo.vo = task;
			}
		}
		return taskInfo;
	}
	/**背包*/
	private static function setBagData(type:Int):Void
	{
		var bagInfo:BagInfo = GameProcess.instance.getComponent(BagpackSystem).bagData;
		//for (i in 0...bagInfo.itemArr.length) 
		//{
			//if (bagInfo.itemArr[i].backupIndex!=-1) 
			//{
				//trace("bagbackupIndex: "+bagInfo.itemArr[i].backupIndex+" ,keyId: "+bagInfo.itemArr[i].keyId);
			//}
		//}
		//trace("Map1: "+bagInfo.backupWeaponArr.get(1).keyId);
		//trace("Map2: "+bagInfo.backupWeaponArr.get(2).keyId);
		//trace("keyId: "+cast(GameProcess.instance.getComponent(GameSchedual), GameSchedual).equipBagData.itemArr[0].keyId+",backup: "+cast(GameProcess.instance.getComponent(GameSchedual), GameSchedual).equipBagData.itemArr[0].backupIndex);
		saveMap(type, bagInfo.itemArr);
	}
	/**获取背包数据*/
	public static function getBagData():BagInfo
	{
		var requst = RemoteSqlite.instance.requestProfile(TableType.P_Goods);
		if (requst==null) {
			return null;
		}
		
		//var base = RemoteSqlite.instance.request(TableType.Item,);
		var item:GoodsVo;
		var currArr:Array<GoodsVo> = [];
		for (i in requst) {
			item = i;
			currArr.push(item);
		}
		var bagInfo:BagInfo = new BagInfo();
		//bagInfo.itemArr = currArr;
		return bagInfo;
	}
	
	/**关卡星级*/
	private static function setMapStarData(type:Int):Void
	{		
		//trace("setMapStarData");
		//saveMap(type, MapStarInfo.instance.dataMap);
	}
	/**关卡星级*/
	public static function getMapStarData():IntMap<Int>
	{
		var	req = RemoteSqlite.instance.requestProfile(TableType.P_Map);
		if (req != null){
			for (i in req) 
			{
				MapStarInfo.instance.dataMap.set(i.Id, i.StarCount);
			}
		}
		return MapStarInfo.instance.dataMap;
	}
	
	/**新手指引记录*/
	private static function setNewbieData(type:Int):Void
	{		
		//trace("setNewbieData");
		saveMap(type, NewbieInfo.instance.dataArr);
	}
	/**新手指引记录*/
	public static function getNewbieData():Array<Int>
	{		
		parseData();
		if (_data == null)
			return null;
		var currArr:Array<Int> = FilesType.fileMap.get(FilesType.Newbie);		
		if (currArr != null ) NewbieInfo.instance.dataArr = currArr;
		//trace("getNewbieData"+NewbieInfo.instance.dataArr);
		return NewbieInfo.instance.dataArr;
	}
	
	/*设置单个背包数据属性*/
	private static function setItemData(_itemInfo:Dynamic,dyna:Dynamic):Void
	{
		if (dyna != null)
		{
			_itemInfo.ItemType = dyna.ItemType;//save_type（ubyte）物品类型（大类）
			/**物品小类*/
			_itemInfo.Kind = dyna.Kind;
			_itemInfo.ID = dyna.ID;//item_id_（int）物品id
			_itemInfo.itemName = dyna.itemName;//物品名
			_itemInfo.itemIndex = dyna.itemIndex;//index_（ubyte）物品索引
			_itemInfo.itemNum = dyna.itemNum;//item_num_（uint）物品数量
			_itemInfo.itemState = dyna.itemState;//item_bind_（ubyte）物品绑定状态
			_itemInfo.PickUp = dyna.PickUp;//是否被拾取
			/**初始品质*/
			_itemInfo.Color = dyna.InitialQuality;
			/**初始等级*/
			_itemInfo.InitialLevel = dyna.InitialLevel;
			/**图表资源名称*/
			_itemInfo.ResId = dyna.ResId;
			/**描述*/
			_itemInfo.Description = dyna.Description;
			/**描述*/
			_itemInfo.Detail = dyna.Detail;
			//特性
			_itemInfo.Characteristic = dyna.Characteristic;
			
			_itemInfo.SubId = dyna.SubId;//取武器技能与强化等级的字段
			/**包含经验*/
			_itemInfo.StrengthenExp = dyna.StrengthenExp;
			/**背包类型**/
			_itemInfo.bagType = dyna.bagType;
			
			if (_itemInfo.strLv != null) _itemInfo.strLv = dyna.strLv;
			if(_itemInfo.strExp!=null)_itemInfo.strExp = dyna.strExp;
			if(_itemInfo.NeedLevel!=null)_itemInfo.NeedLevel = dyna.NeedLevel;
			if(_itemInfo.Att!=null)_itemInfo.Att = dyna.Att;
			if(_itemInfo.Hp!=null)_itemInfo.Hp = dyna.Hp;
			if(_itemInfo.LevelUpItemID!=null)_itemInfo.LevelUpItemID = dyna.LevelUpItemID;
			if(_itemInfo.MaxStrengthenLevel!=null)_itemInfo.MaxStrengthenLevel = dyna.MaxStrengthenLevel;
			if(_itemInfo.equipType!=null)_itemInfo.equipType = dyna.equipType;
			if(_itemInfo.Upgrade!=null)_itemInfo.Upgrade = dyna.Upgrade;
		}
	}
	private static function initPlayer():PlayerInfo
	{
		var playerInfo:PlayerInfo = new PlayerInfo();
		playerInfo.data = { Id:1,
							NAME:"me",
							ROLEID:1001,
							POWER:100,
							LV:1,
							EXP:1,
							GEM:100,
							GOLD:0,
							VIP:1,
							DAY:0,
							MP:100,
							MAX_MP:100,
							HP:300,
							MAX_HP:300,
							FIGHT:100,
							CRITICAL_LEVEL:100,
							SKILL1:911,
							SKILL2:0,
							SKILL3:0,
							SKILL4:0,
							SKILL5:0,
							THROUGH:0,
							HUNT:0,
							NOWTIME:Date.now().toString(),
							WEAPON:0,
							ARMOR:0,
							SOUNDS:1,
							BGM:1,
							NEWBIE:""
		}
		return playerInfo;
	}
	/**初始化装备背包*/
	/*public function initEquipBag():BagInfo
	{
		var equipBag:BagInfo = new BagInfo();
		var items:Array<Int> = [401, 501];
		playerInfo.setProperty(PlayerProp.WEAPON, items[0]);//101 203 303 403
		playerInfo.setProperty(PlayerProp.ARMOR, items[1]);//403 503 603 703
		
		equipBag.itemArr = new Array<ItemBaseInfo>();
		equipBag.parnerId = 0;
		equipBag.bagType = 1;
		equipBag.maxNum =  20;
		equipBag.useNum =  itemIdArr.length;
		trace(playerInfo);
		for (i in 0...items.length)
		{
			var item:ItemBaseInfo = Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(items[i])));
			item.itemIndex = 1000+i; // 区分装备
			equipBag.itemArr.push(item);
			if (item.Kind == ItemType.IK2_ARM) playerInfo.setProperty(PlayerProp.ARMOR, item.ID);
			else playerInfo.setProperty(PlayerProp.WEAPON, item.ID);
		}
		trace("initEquipBag::" + equipBag);
		return equipBag;
	}*/
	/**初始化背包*/
	/*public function initBag():BagInfo
	{
		var bag:BagInfo =  new BagInfo();;
		var items:Array<Int> = [401, 501, 10011, 10012, 10013, 10014, 10015, 10016, 10007, 10008, 10009, 10010];
		bag.itemArr = new Array<ItemBaseInfo>();
		bag.parnerId = 0;
		bag.bagType = 1;
		bag.maxNum =  20;
		bag.useNum =  items.length;
		for (i in 0...items.length)
		{
			var goodsInfo:ItemBaseInfo = Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(items[i])));
			goodsInfo.itemIndex = i + 1;//背包道具序号
			bag.itemArr.push(goodsInfo);
		}
		trace("initBag::" + bag);
		return bag;
	}*/
}