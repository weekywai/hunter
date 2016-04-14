package com.metal.scene.board.impl;

import com.metal.config.RoomMissionType;
import com.metal.config.SfxManager;
import com.metal.config.UnitModelType;
import com.metal.GameProcess;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgItr;
import com.metal.message.MsgStartup;
import com.metal.message.MsgStat;
import com.metal.message.MsgUIUpdate;
import com.metal.unit.stat.PlayerStat;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.MapInfoManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.support.EffectText;
import com.metal.scene.board.impl.GameMap;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.stat.Buff;
import com.metal.unit.stat.BuffType;
import com.metal.unit.stat.IStat;
import com.metal.unit.stat.UnitStat;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;
import haxe.Timer;
import pgr.dconsole.DC;

/**
 * 战斗解算器
 * @author weeky
 */
class BattleResolver extends Component
{
	public var _gameMap:GameMap;
	
	private var _player:SimEntity;
	public var player(get, null):SimEntity;
	private function get_player():SimEntity { return _player; }
	
	private var _hitTime:Int = 3;
	private var _injureTime:Int = 2;
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_gameMap = owner.getComponent(GameMap);
	}
	
	override function onDispose():Void 
	{
		_gameMap = null;
		super.onDispose();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgItr.BulletHit:
				cmd_BulletHit(userData);
			case MsgItr.Destory:
				cmd_Destory(userData);
			case MsgBoard.AssignPlayer:
				cmd_AssignPlayer(userData);
			case MsgStartup.Finishbattle:
				cmd_Finishbattle(userData);
		}
	}
	private function cmd_Finishbattle(userData:Dynamic):Void {
		_player = null;
	}
	private function cmd_AssignPlayer(userData:Dynamic):Void
	{
		_player = userData;
	}
	
	private function cmd_Destory(userData:Dynamic):Void
	{
		//trace("Destory::"+userData + " len:"+_gameMap.enemies.length);
		if (_gameMap.mapData != null && _gameMap.mapData.runKey) return;
		var key:Int = userData.key;
		var remove = _gameMap.enemies.remove(key);
		if(remove)_gameMap.bornPointMap.set(_gameMap.enemiesMap.get(key),-1);
		//var loopEntity = _gameMap.loopEntityId.remove(userData);
		//if (loopEntity && _gameMap.loopEntityId.length<=0) 
		//{
			//_gameMap.BindLoopEntity();
		//}
		var loopGroup:Array<Int>;
		var groupNum:Array<Int> = _gameMap.loopGroupNum;
		for (i in 0..._gameMap.loopEntityId.length) 
		{
			loopGroup = _gameMap.loopEntityId[i];
			for (j in 0...loopGroup.length) 
			{
				if (loopGroup[j]==key) 
				{
					groupNum[i]--;
					if (groupNum[i]<=0) 
					{
						_gameMap.BindLoopEntity(i);
						trace("loop");
					}
				}
			}
		}
		//trace(_gameMap.enemies.length);
		if (MapInfoManager.instance.getRoomInfo(Std.parseInt(_gameMap.mapData.mapId)).MissionType==RoomMissionType.Kill_All) 
		{
			trace("enemies.length: "+_gameMap.enemies.length);
			if (_gameMap.enemies.length <= 0) {
				SfxManager.playBMG(BGMType.Victory);
				trace("Send Victory"+ " len:"+_gameMap.enemies.length);
				PlayerUtils.getPlayer().notify(MsgActor.Victory);
				GameProcess.root.notify(MsgStartup.BattleClear);
			}
		}
		
		//trace(remove+" : "+_gameMap.enemies.length);
	}
	
	private function cmd_BulletHit(userData:Dynamic):Void
	{
		//trace(userData);
		calculate(userData);
	}
	
	//{战斗中计算
	private function calculate(userData:Dynamic):Void
	{
		var target:SimEntity = userData.target;
		//trace("target " + target);
		if (target==null || target.parent==null)
			return;
		var atk:Int = userData.atk;
		var renderType:Int = userData.renderType;
		
		if (target.parent==null)
			return;
		var fix:Array <Int> = userData.fix;
		
		var targetStat:IStat;
		var targetActor:BaseActor; 

		if (target.name == UnitModelType.Player
		  ||target.name == UnitModelType.Vehicle) {
			targetActor = cast target.getComponent(MTActor);
			targetStat = cast target.getComponent(PlayerStat);	
		}else {
			targetActor = cast target.getComponent(UnitActor);
			targetStat = cast target.getComponent(UnitStat);
		}
		//
		if (Main.config.get("console") == "true") {
			if (target.name == UnitModelType.Player ||target.name == UnitModelType.Vehicle) 
				  return;
		}
		
		if (targetStat == null)
			return;
		var buff:Buff = targetStat.findStatusByKey(BuffType.Invincible);
		if (buff != null) {//无敌
			//trace("Invincible");
			return;
		}
		buff = targetStat.findStatusByKey(BuffType.SkipHurt);
		if (buff != null)
			if (buff.findOdds()) {//免伤
				//target.notify(MsgEffect.EffectStart, "z006");
				//trace("Skip hurt");
				return;
			}
		
		buff = targetStat.findStatusByKey(BuffType.LevelupBullet);
		if (buff != null)
			buff.levelupBullet();//子弹升级
		
		var damage = getDamage(atk, fix);
		if (renderType==EffectRequest.Crit) 
		{
			damage *= 2;
		}
		var hp = targetStat.hp - damage;
		//trace("detory: " + target.id + " hp:" + hp + " targetStat.hp:" + targetStat.hp);
		if (targetStat.hp <= 0) {	
			if (ActorState.IsDestroyed(targetActor.stateID))
				return;
			//DC.log("detory: " + target.id + " hp:" + hp);
			//trace("detory: " + target.id + " hp:" + hp);
		}else {
			if (targetActor.faction == BoardFaction.Boss || targetActor.faction == BoardFaction.Boss1) {
				var hpPercent = hp / targetStat.hpMax * 100;
				GameProcess.NotifyUI(MsgUIUpdate.BossInfoUpdate, { percent:hpPercent, hp:hp } );
			}
			if (userData.buffId > 0) {
				//trace("buff");
				target.notify(MsgStat.AddSubStatus, {"id":userData.buffId, "time":userData.buffTime, "hp":hp} );
			}
			//角色加蓝
			if(target.name != UnitModelType.Player && target.name != UnitModelType.Vehicle){
				_hitTime--;
				if (_hitTime < 1) {
					_hitTime = 3;
					PlayerUtils.getPlayer().notify(MsgStat.UpdateMp, 1);
				}
			}else {
				_injureTime--;
				if (_injureTime < 1){
					_injureTime = 2;
					PlayerUtils.getPlayer().notify(MsgStat.UpdateMp, 1);
				}
			}
			//trace("renderType: "+renderType);
			target.notify(MsgActor.Injured, {damage:damage, renderType:renderType});
		}
	}
	
	/**伤害计算*/
	private function getDamage(fight:Int, fix:Array<Int>):Float
	{
		//一级伤害 = 攻击方.攻击/5
		//trace("atk:"+fight);
		var damage = fight / 3;
		//trace(fight);
		//二级伤害 = 攻击方.伤害修正比 * 一级伤害 +　攻击方.伤害修正值
		var fixRate = 10000;
		var fixParam = 0;
		switch(fix[0]) {
			case 1://加成值
				fixParam = fix[2];
			case 2://加成比
				fixRate = fix[2];
		}
		switch(fix[1]) {
			case 1://攻击
			case 2://生命
			case 3://伤害
		}
		
		damage = fixRate * damage / (10000 * Std.parseFloat(Main.config.get("maxAttack")))  + fixParam;
		
		//trace("damage:"+damage);
		var ran = Math.random() > 0.5?1: -1;
		damage = damage+ damage * (Math.random() * 0.05 * ran);
		return Std.int(damage);
	}
	/**暴击*/
	private function getCriRate(cri:Float):Float {
		//If rand（0,10000）<= 攻击方.暴击几率  	（注释：暴击成功）
		//三级伤害 = 二级伤害 * 攻击方.暴击伤害
		//Else
		//三级伤害 = 二级伤害
		//Math.random() * 10000;
		return 0;
	}
	//}
	
	/***/
	public static function resolveAtk(critPor:Float):Int
	{
		//trace("critPor: "+critPor);
		var crit:Bool = Math.random() * 100 <= critPor;
		return (crit? 1:0);
	}
}