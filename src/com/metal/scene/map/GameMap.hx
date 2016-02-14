package com.metal.scene.map;

import com.haxepunk.HXP;
import com.haxepunk.tmx.TmxPropertySet;
import com.metal.component.BattleComponent;
import com.metal.component.GameSchedual;
import com.metal.config.MapLayerType;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.config.UnitModelType;
import com.metal.enums.MapVo;
import com.metal.enums.MonsVo;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.AppearInfo;
import com.metal.proto.impl.MapRoomInfo;
import com.metal.proto.impl.ModelInfo;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.AppearManager;
import com.metal.proto.manager.MapInfoManager;
import com.metal.proto.manager.ModelManager;
import com.metal.proto.manager.MonsterManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.trigger.Trigger;
import com.metal.scene.view.Camera;
import com.metal.unit.AppearUtils;
import com.metal.unit.avatar.MTAvatar;
import com.metal.unit.UnitInfo;
import com.metal.unit.UnitUtils;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.es.Entity;
import de.polygonal.core.sys.SimEntity;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.xml.Fast;
import openfl.errors.Error;
import openfl.geom.Point;
import spinehaxe.atlas.TextureAtlas;
import spinehaxe.SkeletonJson;
import spinepunk.SpinePunk;
/**
 * 场景地图基类
 * @author weeky
 */
class GameMap extends Component
{
	
	public var mapData:MapVo;
	private var _schedual:GameSchedual;
	private var _entities:Array<Dynamic>;
	private var _npc:Array<Dynamic>;
	private var _npcGun:Array<Dynamic>;	
	private var _born:Point;
	private var _trigger:Trigger;
	private var isPlayer:Bool;
	
	public var enemies(default, null):Array<Int>;
	/**记录enemies的出生点*/
	public var enemiesMap:IntMap<Dynamic>;
	/**记录出生点的enemies*/
	public var bornPointMap:ObjectMap<Dynamic,Int>;
	
	
	public var _loadEntities:Array<Dynamic>;
	
	/**各循环组的出生点所配ID*/
	public var loopEntityId:Array<Array<Int>>;
	/**各循环组的出生点*/
	public var loopEntityRecord:Array<Array<Dynamic>>;
	/**各循环组的出生点数*/
	public var loopGroupNum:Array<Int>;
	/**0表示不随机，1随机*/
	public var loopGroupType:Array<Int>;
	
	public var hideEntity:Array<Dynamic>;
		
	public function new() 
	{
		super();
		_born = new Point();
		
	}
	override function onDispose():Void 
	{
		mapData.onDispose();
		mapData = null;
		_born = null;
		_trigger = null;
		_entities = null;
		_loadEntities = null;
		_npc = null;
		_npcGun = null;
		loopEntityId = null;
		loopGroupNum = null;
		loopGroupType = null;
		hideEntity = null;
		loopEntityRecord = null;
		_schedual = null;
		isPlayer = false;
		enemiesMap=null;
		bornPointMap=null;
		super.onDispose();
	}
	
	override public function initComponent(owner:SimEntity):Void 
	{
		super.initComponent(owner);
		_schedual = GameProcess.root.getComponent(GameSchedual);
		_trigger = new Trigger(cast owner);
	}
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgStartup.Reset:
				cmd_reset();
			case MsgStartup.LoadMap:
				cmd_loadMap(userData);
			case MsgBoard.MonsterShow:
				cmd_showMonster(userData);
			case MsgBoard.BossShow:
				cmd_showBoss(userData);
			case MsgBoard.CreateUnit:
				cmd_CreateUnit(userData);
			case MsgBoard.BindHideEntity:
				cmd_BindHideEntity(userData);
		}
		super.onNotify(type, source, userData);
	}
	
	private function cmd_reset():Void
	{
		enemies = [];
		enemiesMap=new IntMap();
		bornPointMap=new ObjectMap();
		_entities = [];
		_loadEntities = [];
		_npc = [];
		_npcGun = [];
		loopEntityId = [];
		loopGroupNum = [];
		loopGroupType = [];
		hideEntity = [];
		loopEntityRecord=[];
		if (mapData != null) {
			//trace("setp cmd_reset");
			mapData.reset();
			mapData = null;
		}
		_trigger.reset();
	}
	
	private function cmd_loadMap(userData:Dynamic):Void
	{
		var battle:BattleComponent = GameProcess.root.getComponent(BattleComponent);
		var mapId =  battle.currentRoomId();
		
		trace("mapId:" + mapId);
		//根据地图id 首先判断类型  根据类型 处理 B类型地图为滚轴处理
		var keyB:Bool = false;
		var tempMapInfo:MapRoomInfo = MapInfoManager.instance.getRoomInfo(Std.parseInt(mapId));
		if (tempMapInfo.RoomType == MapLayerType.MapTypeB) {
			//此类为滚轴处理
			keyB = true;
			trace("keyB = true");
		}
		
		var path:String = ResPath.getMapDataRes(tempMapInfo.MapId);
		
		mapData = new MapVo(path, keyB, tempMapInfo.RoomType);
		mapData.mapId = mapId;
		#if !spriteRenderer
		//解析地图
		for (num in 0...MapVo.nLen) {
			//mapData.getEntityByLayer(num).loadGraphic(MapLayerType.LayerName[num]);
			mapData.getEntityByLayer(num).loadGraphicMapNew(MapLayerType.LayerName[num], 0); 
		}
		#end
		//阻挡层
		//mapData.floorTmx.loadMask("floor", "solid");
		mapData.floorTmx.loadSlopedMask("floor", UnitModelType.Solid);
		mapData.collideLayer.loadObjectMask("collide", UnitModelType.Trap);
		//}
		//天空 在最底 高X1像素 图拉伸处理
		//var bg:Backdrop = new Backdrop("map/Res/sky.png");
		//addchild 地图
		notify(MsgStartup.AssignMap, mapData);
		//对象层处理 B类特殊处理
		//trace("==Events====" + tempMapInfo.Events[0][0]);
		
		//ResourceManager.PreLoad = keyB;
		if (!keyB) {
			isPlayer = true;
			parseData();
		} else {
			isPlayer = false;
			parseInfoData(tempMapInfo);
		}
	}
	private function parseData():Void 
	{
		_entities = [];
		_npc = [];
		enemiesMap=new IntMap();
		bornPointMap=new ObjectMap();
		_npcGun = [];
		loopEntityId = [];
		loopGroupNum = [];
		loopGroupType = [];
		hideEntity = [];
		loopEntityRecord = [];
		var id:Int;
		var loopEntityGroup:Array<Dynamic> = [];
		var loopId:Array<Int> = [];
		for(object in mapData.map.getObjectGroup("monster").objects)
		{
			id = Std.parseInt(object.custom.resolve("id"));
			if (object.name == "1")
			{
				_entities.push(object);
				//enemies.push(id);
				_loadEntities.push({id:id, type:UnitModelType.Unit});
			}
			else if (object.name == "2")
			{
				var info = AppearManager.instance.getProto(id);
				for (i in info.enemies) {
					_loadEntities.push({id:id, type:UnitModelType.Unit});
				}
			}else if (object.name == "3")
			{
				_entities.push(object);
				_loadEntities.push({id:id, type:UnitModelType.Block});
			}
			else if (object.name == "4")
			{
				_npc.push(object);
				_loadEntities.push({id:id, type:UnitModelType.Npc});
			}else if (object.name == "5")
			{
				_npcGun.push(object);
			}else if (object.name == "6")
			{
				loopEntityGroup.push(object);
				loopId.push(id);
				//loopEntity.push(id);
				//_entities.push(object);
				//enemies.push(id);
				_loadEntities.push({id:id, type:UnitModelType.Unit});
			}else if (object.name == "7")
			{
				hideEntity.push(object);
				//loopEntity.push(id);
				//_entities.push(object);
				//enemies.push(id);
				_loadEntities.push({id:id, type:UnitModelType.Unit});
			}
		}
		loopEntityRecord.push(loopEntityGroup);
		loopEntityId.push(loopId);
		loopGroupNum.push(loopId.length);
		loopGroupType.push(0);
		for (object in mapData.map.getObjectGroup("event").objects) 
		{
			var info = AppearManager.instance.getProto(Std.parseInt(object.custom.resolve("id")));
			if (info == null) continue;
			for (i in info.enemies) {
				//enemies.push(i);
				_loadEntities.push({id:i, type:UnitModelType.Unit});
			}
		}
		_loadEntities.push({id:0, type:UnitModelType.Player});
		for (object in mapData.map.getObjectGroup("actor").objects) 
		{
			_born.x = object.x;
			_born.y = object.y;
		}
		loadEntity();
		BindPlayer();
		BindUint();
		BindNPC();
		BindDropItem();
		BindLoopEntity(0);
	}
	private function getPropSet(id:Int,type:String=null):TmxPropertySet 
	{
		var propSet:TmxPropertySet = new TmxPropertySet();
		var strID = "<property name='id' value='" + id + "'/>";
		var strType = (type!=null)?"<property name='type' value='" + type + "'/>":"";
		var fast = new Fast(Xml.parse(strID + strType));
		propSet.extend(fast);
		return propSet;
	}
	
	/**解析事件对象层**/
	private function parseEvenLayer():Void
	{
		for (object in mapData.map.getObjectGroup("event").objects) 
		{
			_trigger.parseEvent(object);
		}
	}
	
	private function parseInfoData(mapInfo:MapRoomInfo):Void
	{
		//解析加载
		for (evt in mapInfo.Events) 
		{
			var group = evt[2].split("&");//第三个字段出场怪物组
			//trace("========" + group);
			for (id in group)
			{
				var info = AppearManager.instance.getProto(Std.parseInt(id));
				for (i in info.enemies) {
					_loadEntities.push({id:i, type:UnitModelType.Unit});
				}
			}
		}
		_loadEntities.push( { id:0, type:UnitModelType.Vehicle } );
		loadEntity();
		
		if(!isPlayer)BindPlayerVehicle(mapInfo.vehicle);
		//添加B段怪物出场检测
		_trigger.setMonsterShow(mapInfo.Events);
		var ary = mapInfo.Events[0];
		ary = ary[2].split("&");
		parseMonster(ary);
	}
	
	/**解析怪物id组**/
	private function parseMonster(arr:Array<String>):Void
	{
		var appearInfo:AppearInfo;
		var entity:SimEntity;
		for (i in arr) 
		{
			appearInfo = AppearManager.instance.getProto(Std.parseInt(i));
			//trace(Std.parseInt(i)+" "+appearInfo);
			
			var appearArr:Array<Array<Point>> = AppearUtils.monsterApear(appearInfo);
			
			var j:Int = 0;
			for (id in appearInfo.enemies)
			{
				//trace("id " + id);
				
				var createPos:Point = appearArr[1][j];// appearInfo.EnAt[j];
				var bornPos:Point = appearArr[0][j];// appearInfo.BornAt[j];
				j++;
				var monsterInfo:MonsterInfo = MonsterManager.instance.getInfo(id);
				entity = createEntity(monsterInfo.ModelType, createPos, id);
				entity.notify(MsgActor.BornPos, bornPos);
				notify(MsgBoard.AssignUnit, entity);
			}
		}
	}
	
	private function loadEntity():Void 
	{
		//return;
		//trace("Load entity:"+_loadEntities.length);
		for (data in _loadEntities)
		{
			var atlas:TextureAtlas = null;
			var json:SkeletonJson = null;
			//特殊判断 是否场景物品 并且是 骨骼类资源
			var res:Int = 0,modelType = UnitModelType.Unit;
			switch(data.type) {
				case UnitModelType.Player:
					res = PlayerUtils.getInfo().res;
					modelType = UnitModelType.Player;
				case UnitModelType.Vehicle:
					res = PlayerUtils.getInfo().vehicle;
				default:
				//case UnitModelType.Unit, UnitModelType.Npc, UnitModelType.Boss, UnitModelType.Elite://, UnitModelType.Block:
					//if(data.type ==UnitModelType.Block)
						//trace(data.id);
					res = MonsterManager.instance.getInfo(data.id).res;
					//trace(res);
			}
			if (res == 0) return;
			var modelInfo:ModelInfo = ModelManager.instance.getProto(res);
			if (data.type == UnitModelType.Unit) {
				//trace(data.id);
				modelInfo.fly = MonsterManager.instance.getInfo(data.id).ModelType;
			}
			
			//trace(ResourceManager.PreLoad+">>"+data.id);
			if(ResourceManager.PreLoad){
				var avater:MTAvatar = HXP.scene.create(MTAvatar, true);
				avater.type = data.type;
				avater.preload(modelInfo);
				avater.active = false;
				avater.visible = false;
				ResourceManager.instance.addEntity(modelInfo.res, avater);
			}else {
				SpinePunk.readSkeletonData("model", ResPath.getModelRoot(modelType, modelInfo.res));
			}
		}
	}
	
	/**boss进场**/
	private function cmd_showBoss(obj:Dynamic):Void
	{
		if (obj == null)
			return;
		var entity:SimEntity;
		var arr:Array<Int> = obj.monsters;//Reflect.getProperty(obj, "monsters");
		var appearInfo = AppearManager.instance.getProto(Std.parseInt(obj.groupId));
		var j:Int = 0;
		SfxManager.getAudio(AudioType.BossEnter).play();
		for (id in arr) 
		{
			var monsterInfo:MonsterInfo = MonsterManager.instance.getInfo(id);
			var createPos:Point = appearInfo.EnAt[j];
			var bornPos:Point = appearInfo.BornAt[j];
			//trace(createPos + "=======" + bornPos);
			j++;
			entity = createEntity(monsterInfo.ModelType, createPos, id);
			entity.notify(MsgActor.BornPos, bornPos); 
			notify(MsgBoard.AssignUnit, entity);
			var faction = BoardFaction.getFaction(monsterInfo.ModelType);
			if (faction == BoardFaction.Boss) {
				notify(MsgPlayer.AddCollide, BoardFaction.getType(faction));
			}
		}
	}
	
	
	/**通知添加新一波怪物**/
	private function cmd_showMonster(obj:Array<MonsVo>):Void
	{	
		//DC.beginProfile("showMonster");
		var entity:SimEntity;
		var j:Int = 0;
		var id:Int = obj[0].gid;
		var appearInfo = AppearManager.instance.getProto(id);
		var appearArr:Array<Array<Point>> = AppearUtils.monsterApear(appearInfo);
		for (vo in obj) 
		{
			if (id != vo.gid)
			{
				appearInfo = AppearManager.instance.getProto(vo.gid);
				appearArr = AppearUtils.monsterApear(appearInfo);
				id = vo.gid;
				j = 0;
			}
			var monsterInfo:MonsterInfo = MonsterManager.instance.getInfo(vo.id);
			//入场方式空值需读取表中出生点
			var createPos:Point = (appearArr!=null)?appearArr[1][j]:appearInfo.EnAt[j];
			var bornPos:Point = (appearArr!=null)?appearArr[0][j]:appearInfo.BornAt[j];
			j++;
			if (createPos == null || bornPos == null)
				throw new Error("createPos:" + appearInfo.EnAt + " bornPos:" + appearInfo.BornAt + ">>>"+j);
			entity = createEntity(monsterInfo.ModelType, createPos, vo.id);
			entity.notify(MsgActor.BornPos, bornPos);
			notify(MsgBoard.AssignUnit, entity);
			if(!mapData.runKey){
				var faction = BoardFaction.getFaction(monsterInfo.ModelType);
				if(faction == BoardFaction.Elite || faction == BoardFaction.Machine){
					notify(MsgPlayer.AddCollide, BoardFaction.getType(faction));
				}
			}
		}
	}

	private function createEntity(modelType:Int,createPos:Point,id:Int):SimEntity 
	{
		var x:Float = createPos.x * HXP.width + HXP.camera.x;
		if (!mapData.runKey) {
			if (x >= mapData.map.fullWidth)
				x = mapData.map.fullWidth-80;
		}
		var y:Float = createPos.y * HXP.height + HXP.camera.y;
		var faction = BoardFaction.getFaction(modelType);
		var unitModel:String;
		switch(faction) {
			case BoardFaction.Boss, BoardFaction.Boss1:
				unitModel = UnitModelType.Boss;
			case BoardFaction.Elite:
				unitModel = UnitModelType.Elite;
			default:
				unitModel = UnitModelType.Unit;
				
		}
		return UnitUtils.createUnit(unitModel, id, faction, x, y);
	}
	
	
	private function cmd_CreateUnit(userData:Dynamic):Void
	{
		var info:UnitInfo = userData;
		var entity:SimEntity = null;
		switch(info.simType) {
			case UnitModelType.DropItem:
				entity = UnitUtils.createDropItem(info.simType, info.id, info.faction, info.x, info.y);
			case UnitModelType.Player, UnitModelType.Vehicle, UnitModelType.Unit:
				entity = UnitUtils.createUnit(info.simType, info.id, info.faction, info.x, info.y);
				//enemies
		}
		if(entity!=null)
			notify(MsgBoard.AssignUnit, entity);
	}
	
	private function BindPlayer():Void
	{
		var player:SimEntity = UnitUtils.createUnit(UnitModelType.Player, 0, BoardFaction.Player, _born.x, _born.y);
		
		//事件层处理
		parseEvenLayer();
		
		notify(MsgBoard.AssignUnit, player);
		//trace("bind player" + owner.parent);
		notifyParent(MsgBoard.AssignPlayer, player);
		//GameProcess.UIRoot.notify(MsgBoard.AssignPlayer, player);
		//trace("AssignPlayer");
		_trigger.setActiveByType("0");
		_trigger.setActiveByType("1");
		_trigger.setActiveByType("2");
		_trigger.setActiveByType("3");
		_trigger.setActiveByType("5");
		_trigger.setActiveByType("6");
		_trigger.setActiveByType("7");
		_trigger.setActiveByType("8");
	}
	

	
	private function BindPlayerVehicle(vehicle:Int):Void
	{
		var centerW = HXP.width * 0.4;
		var centerH = HXP.height * 0.4;
		var player:SimEntity = UnitUtils.createUnit(UnitModelType.Vehicle, vehicle, BoardFaction.Player, centerW, centerH);
		notify(MsgBoard.AssignUnit, player);
		//trace("bind Vehicle");
		notifyParent(MsgBoard.AssignPlayer, player);
		//GameProcess.UIRoot.notify(MsgBoard.AssignPlayer, player);
	}
	
	private function BindUint():Void
	{
		var entity:SimEntity;
		for (obj in _entities) 
		{
			//特殊判断 是否场景物品 并且是 骨骼类资源
			var id = Std.parseInt(obj.custom.resolve("id"));
			var monsterInfo = MonsterManager.instance.getInfo(id);
			var modelInfo:ModelInfo = ModelManager.instance.getProto(monsterInfo.res);
			//trace("modelInfo:"+modelInfo);
			var faction = BoardFaction.getFaction(monsterInfo.ModelType);
			if (faction == BoardFaction.Boss) {
				obj.x = Math.round(HXP.width * 0.75);
				entity = UnitUtils.createUnit(UnitModelType.Boss, id, faction, obj.x, obj.y);
			} else if (faction == BoardFaction.Block) {
				entity = UnitUtils.createUnit(UnitModelType.Block, id, faction, obj.x, obj.y);
			} else {
				entity = UnitUtils.createUnit(UnitModelType.Unit, id, faction, obj.x, obj.y);
			}
			notify(MsgBoard.AssignUnit, entity);
			enemies.push(entity.keyId);
			enemiesMap.set(entity.keyId,obj);
			bornPointMap.set(obj,entity.keyId);
			if (faction == BoardFaction.Boss1 || faction == BoardFaction.Boss) {
				GameProcess.UIRoot.sendMsg(MsgUI.BossPanel, modelInfo.res);
				SfxManager.getAudio(AudioType.BossEnter).play();
				if (faction == BoardFaction.Boss){
					notify(MsgPlayer.AddCollide, BoardFaction.getType(faction));
				}
			}else if (faction == BoardFaction.Block || faction == BoardFaction.Machine) {
				notify(MsgPlayer.AddCollide, BoardFaction.getType(faction));
			}
		}
	}
	/**生成循环刷新的怪物*/
	public function BindLoopEntity(buildIndex:Int)
	{
		var randomId:Array<Int> = [];
		if (loopGroupType[buildIndex]==1) 
		{			
			for (obj in loopEntityRecord[buildIndex]) 
			{
				randomId.push(Std.parseInt(obj.custom.resolve("id")));
			}
		}
		var newIdGroup:Array<Int> = [];
		for (obj in loopEntityRecord[buildIndex]) 
		{
			newIdGroup.push(buildEntity(obj,(randomId.length>0)?randomId:null).keyId);
		}
		loopEntityId[buildIndex] = newIdGroup;
		loopGroupNum[buildIndex] = newIdGroup.length;
	}
	/**生成屏幕范围内隐藏类怪物*/
	public function cmd_BindHideEntity(userdata:Dynamic)
	{
		var loop:Bool;
		var random:Bool;
		if (userdata!=null) 
		{
			loop = (userdata.loop != null)?userdata.loop:false;		
			random = (userdata.random != null)?userdata.random:false;			
		}else 
		{
			loop = false;
			random = false;
		}
		
		var entityGroup:Array<Dynamic>= [];
		var newIdGroup:Array<Int> = [];
		var randomId:Array<Int> = [];
		for (obj in hideEntity) 
		{
			if (Camera.isInCamera(obj.x, obj.y,HXP.halfWidth) && (bornPointMap.get(obj) == null || bornPointMap.get(obj) ==-1)) {
				entityGroup.push(obj);	
			}
		}
		if (random) 
		{			
			for (obj in entityGroup) 
			{
				randomId.push(Std.parseInt(obj.custom.resolve("id")));
			}
		}
		for (obj in entityGroup) {
			newIdGroup.push(buildEntity(obj, (randomId.length>0)?randomId:null).keyId);
		}
		if (loop) 
		{			
			loopEntityRecord.push(entityGroup);
			loopEntityId.push(newIdGroup);
			loopGroupNum.push(entityGroup.length);
			loopGroupType.push((random == false)?0:1);
		}		
	}
	
	public function buildEntity(obj:Dynamic,randomId:Array<Int>=null):Dynamic
	{
		var entity:SimEntity;
		var id:Int;
		//特殊判断 是否场景物品 并且是 骨骼类资源
		if (randomId==null) 
		{
			id = Std.parseInt(obj.custom.resolve("id"));
		}else 
		{
			//trace("randomId.length: "+randomId.length);
			id = randomId[Math.floor(Math.random() * randomId.length)];
		}
		
		var monsterInfo = MonsterManager.instance.getInfo(id);
		var modelInfo:ModelInfo = ModelManager.instance.getProto(monsterInfo.res);
		//trace("modelInfo:"+modelInfo);
		var faction = BoardFaction.getFaction(monsterInfo.ModelType);
		if (faction == BoardFaction.Boss) {
			obj.x = Math.round(HXP.width * 0.75);
			entity = UnitUtils.createUnit(UnitModelType.Boss, id, faction, obj.x, obj.y);
		} else if (faction == BoardFaction.Block) {
			entity = UnitUtils.createUnit(UnitModelType.Block, id, faction, obj.x, obj.y);
		} else {
			entity = UnitUtils.createUnit(UnitModelType.Unit, id, faction, obj.x, obj.y);
		}
		notify(MsgBoard.AssignUnit, entity);
		enemies.push(entity.keyId);
		enemiesMap.set(entity.keyId,obj);
		bornPointMap.set(obj,entity.keyId);
		
		if (faction == BoardFaction.Boss1 || faction == BoardFaction.Boss) {
			GameProcess.UIRoot.sendMsg(MsgUI.BossPanel, modelInfo.res);
			SfxManager.getAudio(AudioType.BossEnter).play();
			if (faction == BoardFaction.Boss){
				notify(MsgPlayer.AddCollide, BoardFaction.getType(faction));
			}
		}else if (faction == BoardFaction.Block || faction == BoardFaction.Machine) {
			notify(MsgPlayer.AddCollide, BoardFaction.getType(faction));
		}
		return entity;
	}
	private function BindNPC():Void
	{
		var entity:SimEntity;
		for (obj in _npc)
		{
			entity = UnitUtils.createNPC(UnitModelType.Npc, Std.parseInt(obj.custom.resolve("id")), BoardFaction.Npc, obj.x, obj.y);
			notify(MsgBoard.AssignUnit, entity);
		}
	}
	private function BindDropItem():Void
	{
		var unit:UnitInfo;
		for (obj in _npcGun)
		{
			unit= new UnitInfo();
			unit.faction = BoardFaction.Item;
			unit.simType = UnitModelType.DropItem;
			switch (Std.parseInt(obj.custom.resolve("id"))) 
			{
				case 404:
					unit.id = 10607;
				case 405:
					unit.id = 10608;
				case 406:
					unit.id = 10609;
				case 407:
					unit.id = 10610;					
			}
			
			//unit.id = item.ItemId;
			unit.x = obj.x;
			unit.y = obj.y;
			notifyParent(MsgBoard.CreateUnit, unit);	
		}
	}
	
}
