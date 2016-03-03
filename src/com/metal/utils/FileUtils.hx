package com.metal.utils;
import com.metal.component.GameSchedual;
import com.metal.component.RewardComponent;
import com.metal.component.TaskComponent;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.enums.BagInfo;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.LiveNessInfo;
import com.metal.proto.impl.MapStarInfo;
import com.metal.proto.impl.NewbieInfo;
import com.metal.proto.impl.NewsInfo;
import com.metal.proto.impl.QuestInfo;
import com.metal.proto.manager.LiveNessManager;
import com.metal.proto.manager.NewsManager;
import com.metal.proto.manager.TaskManager;
import crashdumper.hooks.openfl.HookOpenFL;
import haxe.ds.IntMap;
import haxe.Serializer;
import haxe.Unserializer;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
/**
 * ...储存数据
 * @author hyg
 */
/**任务数据*/
typedef TaskVo = {
	Finish:Int, 
	state:Int, 
	Count:Int, 
}
/**活动数据*/
typedef ActiveVo = {
	Num:Int, 
	isDraw:Int,
}
/**物品数据*/
typedef GoodsVo = {
	strLv:Int, 
	Upgrade:Int, 
	sortInt:Int,
	itemStr:Int,
	bagType:Int,
}
class FileUtils
{
	
	static private var _path:String;
	static private var _data:Dynamic;
	
	static private var _hook:HookOpenFL;
	/**default PATH_APP*/
	public static function getPath(str:String = HookOpenFL.PATH_APP):String
	{
		if(_hook == null)
			_hook = new HookOpenFL();
		return _hook.getFolderPath(str);
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
		if (fileContent==null || fileContent=="")
			return;
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
				setPlayerInfo(fileType);
			case FilesType.Active:
				setActive(fileType);
			case FilesType.Task:
				setTask(fileType);
			case FilesType.Bag:
				setBagData(fileType);
			case FilesType.EquipBag:
				setEquipBag(fileType);
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
	private static function setPlayerInfo(type:Int):Void
	{
		saveMap(type, PlayerUtils.getInfo());
	}

	/**获取角色信息*/
	static public function getPlayerInfo():PlayerInfo
	{
		if (!FileExits) 
			return null;
		parseData();
		if (_data == null)
			return initPlayer();
		var playInfo:PlayerInfo = FilesType.fileMap.get(FilesType.Player);
		if (playInfo == null) 
			return initPlayer();
		return playInfo;
	}
	/**活跃度*/
	private static function setActive(type:Int):Void
	{
		var activeInfo:IntMap<LiveNessInfo> = cast GameProcess.root.getComponent(RewardComponent).getLiveNesss();
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
		parseData();
		if (_data == null)
			return activeInfo;
		var activeMap:IntMap<ActiveVo> = FilesType.fileMap.get(FilesType.Active);
		if (activeMap == null)
			return activeInfo;
		for (i in activeInfo.keys())
		{
			var active:ActiveVo = activeMap.get(i);
			if (active != null) {
				var liveInfo:LiveNessInfo = activeInfo.get(i);
				liveInfo.Num = active.Num;
				liveInfo.isDraw = active.isDraw;
			 }
		}
		return activeInfo;
	}
	/**消息*/
	private static function setNewsInfo(type:Int):Void
	{
		var newsInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).newMapInfo;
		var newsMap:IntMap<Int> = new IntMap();
		//trace("save news:");
		for (key in newsInfo.keys())
		{
			var info = newsInfo.get(key);
			newsMap.set(key, info.isDraw);
		}
		saveMap(type, newsMap);
	}
	/**获取消息*/
	public static function getNewsInfo():IntMap<NewsInfo>
	{
		var newsMap:IntMap<NewsInfo> = NewsManager.instance.data;
		parseData();
		if (_data == null)
			return newsMap;
		var news:IntMap<Int> = FilesType.fileMap.get(FilesType.News);
		if (news == null)
			return newsMap;
		for (key in newsMap.keys())
		{
			if (news.exists(key)) {
				var info:NewsInfo = newsMap.get(key);
				info.isDraw = news.get(key);
			}
		}
		return newsMap;
	}
	
	/**任务*/
	private static function setTask(type:Int):Void
	{
		trace("setTask");
		var taskInfo = cast(GameProcess.root.getComponent(TaskComponent), TaskComponent).taskMap;
		var taskMap:IntMap<TaskVo> = new IntMap();
		for (key in taskInfo.keys())
		{	
			var task:TaskVo = cast taskInfo.get(key);
			taskMap.set(key, task);
		}
		saveMap(type, taskMap);
	}
	/**获取任务*/
	public static function getTask():IntMap<QuestInfo>
	{
		trace("getTask");
		var taskInfo = TaskManager.instance.Task;
		parseData();
		if (_data == null)
			return taskInfo;
		var taskMap:IntMap<TaskVo> = FilesType.fileMap.get(FilesType.Task);
		if (taskMap == null)
			return taskInfo;
		for (key in taskInfo.keys())
		{
			var task:TaskVo = taskMap.get(key);
			if (task != null) {
				var questInfo:QuestInfo = taskInfo.get(key);
				questInfo.Finish = task.Finish;
				questInfo.state = task.state;
				questInfo.Count = task.Count;
			}
		}
		return taskInfo;
	}
	/**背包*/
	private static function setBagData(type:Int):Void
	{
		var bagInfo:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		//for (i in 0...bagInfo.itemArr.length) 
		//{
			//if (bagInfo.itemArr[i].backupIndex!=-1) 
			//{
				//trace("bagbackupIndex: "+bagInfo.itemArr[i].backupIndex+" ,keyId: "+bagInfo.itemArr[i].keyId);
			//}
		//}
		//trace("Map1: "+bagInfo.backupWeaponArr.get(1).keyId);
		//trace("Map2: "+bagInfo.backupWeaponArr.get(2).keyId);
		//trace("keyId: "+cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.itemArr[0].keyId+",backup: "+cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData.itemArr[0].backupIndex);
		saveMap(type, bagInfo.itemArr);
	}
	/**获取背包数据*/
	public static function getBagData():BagInfo
	{
		parseData();
		if (_data == null)
			return null;
			
		var currArr:Array<ItemBaseInfo> = FilesType.fileMap.get(FilesType.Bag);
		var bagInfo:BagInfo = new BagInfo();
		if (currArr.length > 0) bagInfo.itemArr = currArr;
		
		return bagInfo;
	}
	
	/**关卡星级*/
	private static function setMapStarData(type:Int):Void
	{		
		//trace("setMapStarData");
		saveMap(type, MapStarInfo.instance.dataMap);
	}
	/**关卡星级*/
	public static function getMapStarData():IntMap<Int>
	{
		parseData();
		if (_data == null)
			return null;
		var currArr:IntMap<Int> = FilesType.fileMap.get(FilesType.StageStar);		
		if (currArr != null ) MapStarInfo.instance.dataMap = currArr;
		//trace("MapStarInfo.instance.dataMap: "+MapStarInfo.instance.dataMap);
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
	
	/**装备背包*/
	private static function setEquipBag(type:Int):Void
	{
		var equipBag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData;
		saveMap(type, equipBag.itemArr);
	}
	/**获取装备背包数据*/
	public static function getEquipBag():BagInfo
	{
		parseData();
		if (_data == null)
			return null;
		var currArr:Array<ItemBaseInfo> = FilesType.fileMap.get(FilesType.EquipBag);
		var equipBag:BagInfo = new BagInfo();
		equipBag.itemArr = currArr;
		return equipBag;
	}
	
	
	/*设置单个背包数据属性*/
	private static function setItemData(_itemInfo:Dynamic,dyna:Dynamic):Void
	{
		if (dyna != null)
		{
			_itemInfo.itemType = dyna.itemType;//save_type（ubyte）物品类型（大类）
			/**物品小类*/
			_itemInfo.Kind = dyna.Kind;
			_itemInfo.itemId = dyna.itemId;//item_id_（int）物品id
			_itemInfo.itemName = dyna.itemName;//物品名
			_itemInfo.itemIndex = dyna.itemIndex;//index_（ubyte）物品索引
			_itemInfo.itemNum = dyna.itemNum;//item_num_（uint）物品数量
			_itemInfo.itemState = dyna.itemState;//item_bind_（ubyte）物品绑定状态
			_itemInfo.PickUp = dyna.PickUp;//是否被拾取
			/**初始品质*/
			_itemInfo.InitialQuality = dyna.InitialQuality;
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
		var playerInfo = new PlayerInfo();
		playerInfo.Id = 1;
		playerInfo.Name = "me";
		playerInfo.setProperty(PlayerPropType.ROLEID, 1001);
		playerInfo.setProperty(PlayerPropType.POWER, 100);
		playerInfo.setProperty(PlayerPropType.LV, 1);
		playerInfo.setProperty(PlayerPropType.SEX, 1);
		playerInfo.setProperty(PlayerPropType.EXP, 1);
		playerInfo.setProperty(PlayerPropType.GEM, 100);
		playerInfo.setProperty(PlayerPropType.BOUNDGEM, 0);
		playerInfo.setProperty(PlayerPropType.GOLD, 0);
		playerInfo.setProperty(PlayerPropType.VIP, 1);
		playerInfo.setProperty(PlayerPropType.DAY, 0);
		playerInfo.setProperty(PlayerPropType.MP, 100);
		playerInfo.setProperty(PlayerPropType.MAX_MP, 100);
		playerInfo.setProperty(PlayerPropType.HP, 300);
		playerInfo.setProperty(PlayerPropType.MAX_HP, 300);
		playerInfo.setProperty(PlayerPropType.FIGHT, 100);
		//playerInfo.setProperty(PlayerPropType.WEAPON, 401);//101 203 303 403
		//playerInfo.setProperty(PlayerPropType.ARMOR, 501);//403 503 603 703
		playerInfo.setProperty(PlayerPropType.SKILL1, 911);
		playerInfo.setProperty(PlayerPropType.SKILL2, 0);
		playerInfo.setProperty(PlayerPropType.SKILL3, 0);
		playerInfo.setProperty(PlayerPropType.SKILL4, 0);
		playerInfo.setProperty(PlayerPropType.SKILL5, 0);
		playerInfo.setProperty(PlayerPropType.SOUNDS, 1);
		playerInfo.setProperty(PlayerPropType.BGM, 1);
		playerInfo.setProperty(PlayerPropType.THROUGH, 0);
		playerInfo.setProperty(PlayerPropType.HUNT, 0);
		return playerInfo;
	}
	/**初始化装备背包*/
	/*public function initEquipBag():BagInfo
	{
		var equipBag:BagInfo = new BagInfo();
		var items:Array<Int> = [401, 501];
		playerInfo.setProperty(PlayerPropType.WEAPON, items[0]);//101 203 303 403
		playerInfo.setProperty(PlayerPropType.ARMOR, items[1]);//403 503 603 703
		
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
			if (item.Kind == ItemType.IK2_ARM) playerInfo.setProperty(PlayerPropType.ARMOR, item.itemId);
			else playerInfo.setProperty(PlayerPropType.WEAPON, item.itemId);
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