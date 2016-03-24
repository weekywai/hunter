package com.metal.scene;

import com.metal.component.BattleSystem;
import com.metal.component.GameSchedual;
import com.metal.config.UnitModelType;
import com.metal.player.core.PlayerStat;
import com.metal.player.utils.PlayerInfo;
import com.metal.proto.impl.ActorPropertyInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.ModelInfo;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.ActorPropertyManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.ModelManager;
import com.metal.proto.manager.MonsterManager;
import com.metal.proto.manager.SkillManager;
import com.metal.unit.actor.control.PlayerControl;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.actor.view.ViewBoss;
import com.metal.unit.actor.view.ViewDropItem;
import com.metal.unit.actor.view.ViewElite;
import com.metal.unit.actor.view.ViewItem;
import com.metal.unit.actor.view.ViewMachine;
import com.metal.unit.actor.view.ViewMonster;
import com.metal.unit.actor.view.ViewNPC;
import com.metal.unit.actor.view.ViewPlayer;
import com.metal.unit.actor.view.ViewRoobet;
import com.metal.unit.actor.view.ViewTank;
import com.metal.unit.actor.view.ViewVehicle;
import com.metal.unit.actor.view.boss.ViewBoss1;
import com.metal.unit.actor.view.boss.ViewBoss2;
import com.metal.unit.actor.view.boss.ViewBoss3;
import com.metal.unit.actor.view.boss.ViewBoss4;
import com.metal.unit.actor.view.boss.ViewBoss5;
import com.metal.unit.ai.MonsterAI;
import com.metal.unit.ai.PlayerAI;
import com.metal.unit.stat.UnitStat;
import com.metal.unit.weapon.impl.WeaponController;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class GameFactory extends Component
{
	private var _playerManager:GameSchedual;
	
	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_playerManager = owner.getComponent(GameSchedual);
	}
	
	public function createSimEntity(type:String, id:Int):SimEntity {
		switch (type) {
			case UnitModelType.Unit, UnitModelType.Boss, UnitModelType.Elite, UnitModelType.Block:
				return createMonster(type, id);
			case UnitModelType.DropItem:
				return createItemUnit(type, id);
			case UnitModelType.Npc:
				return createNpc(type, id);
			//case UnitModelType.DropItem:
				//return CreateDropItem(type, id);
			case UnitModelType.Player,UnitModelType.Vehicle:
				return createPlayerUnit(type, id);
			default:
				throw ("Can not create entity : " + type);
				return null;
		}
		
	}
	
	private function createPlayerUnit(type:String, id:Int):SimEntity 
	{
		var entity:SimEntity = cerateEntity(type);
		var player:PlayerInfo = _playerManager.playerInfo;
		entity.addComponent(new MTActor());
		entity.addComponent(new PlayerControl());
		entity.addComponent(new PlayerAI(0));
		entity.addComponent(new PlayerStat());
		//entity.addComponent(new WeaponController());
		var view:Dynamic = null;
		if(type == UnitModelType.Vehicle){
			player.vehicle = id;
			createView(entity, 10);
		}else {
			createView(entity, 9);
		}
		//last add recieve update first
		entity.addComponent(new WeaponController());
		return entity;
	}
	
	private function createMonster(type:String, id:Int):SimEntity 
	{
		var entity:SimEntity = cerateEntity(type);
		//trace(MonsterManager.instance.getInfo(id)+" : "+id);
		//id = 204;
		var monster:MonsterInfo = MonsterManager.instance.getInfo(id);
		//trace(monster.ID+" monster :"+ monster.FixedType);
		//通过关卡计算怪物ATK HP
		var battle:BattleSystem = GameProcess.root.getComponent(BattleSystem);
		
		var model:ModelInfo = ModelManager.instance.getProto(monster.res);
		//检测闯关或副本 获取需要根据角色等级
		var level:Int = (battle.currentStage().DuplicateType == 9)?battle.TotalKillBoss():battle.currentStage().Id;
		//trace(level);
		var actor:ActorPropertyInfo = ActorPropertyManager.instance.getProto(level);
		monster.MaxHp = Math.round(actor.DPS * model.rate1);
		monster.Atk = Math.round(actor.HP / model.rate2) * 20;
		//trace(id + ">>" + monster.MaxHp + ">>" + monster.Atk);
		
		entity.addProperty(monster);
		if (type != UnitModelType.Block) {
			var skill:SkillInfo = SkillManager.instance.getInfo(monster.SkillId);
			entity.addProperty(skill);
			entity.addComponent(new MonsterAI(id));
		}
		//trace("modelType " + modelType);
		createView(entity, monster.ModelType);
		entity.addComponent(new UnitActor());
		entity.addComponent(new UnitStat());
		return entity;
	}
	/**
	 * drop item
	 * @param	type
	 * @param	id
	 * @return
	 */
	private function createItemUnit(type:String, id:Int):SimEntity 
	{
		var entity:SimEntity = cerateEntity(type);
		var item = GoodsProtoManager.instance.getItemById(id);
		if(item==null)
			trace(id+""+GoodsProtoManager.instance.getItemById(id));
		entity.addProperty(cast(item, ItemBaseInfo));
		createView(entity, 0);
		entity.addComponent(new UnitActor());
		return entity;
	}
	
	private function createNpc(type:String, id:Int):SimEntity 
	{
		var entity:SimEntity = cerateEntity(type);
		entity.addProperty(MonsterManager.instance.getInfo(id));
		createView(entity, 8);
		entity.addComponent(new UnitActor());
		return entity;
	}
	private function cerateEntity(type:String):SimEntity 
	{
		var entity:SimEntity = new SimEntity(type, false);
		entity.drawable = true;
		return entity;
	}
	
	private function createView(entity:SimEntity, modelType:Int):Void
	{
		var view:Dynamic = null;
		
		switch(modelType) {
			case 0: view = new ViewDropItem();//掉落物品
			
			case 1: view = new ViewMonster();
			case 2: view = new ViewRoobet();
			case 3: view = new ViewTank();//坦克  精英
			case 4: view = new ViewMachine();
			case 5: view = new ViewItem();
			case 6: view = new ViewBoss();//四脚蜘蛛  精英
			case 7: view = new ViewElite();//机械  精英
			
			case 8: view = new ViewNPC();//NPC 宝箱
			case 9: view = new ViewPlayer(); //普通主角
			case 10: view = new ViewVehicle();//骑乘主角
			
			
			case 11: view = new ViewBoss1();//武装飞机boss
			case 12: view = new ViewBoss2();//双脚boss
			case 13: view = new ViewBoss3();//站桩boss
			case 14: view = new ViewBoss4();//直升飞机boss
			case 15: view = new ViewBoss5();//有轮boss
			//case 9: entity.addComponent(new ViewBoss2());
		}
		entity.attach(view);
		view.init(entity);
	}
}