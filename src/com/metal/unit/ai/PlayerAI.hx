package com.metal.unit.ai;
import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.metal.config.UnitModelType;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.message.MsgStartup;
import com.metal.player.core.PlayerStat;
import com.metal.scene.board.api.BoardFaction;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.ai.type.AiFactory;
import com.metal.unit.avatar.AbstractAvatar;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.stat.IStat;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.time.Timebase;
import openfl.display.Sprite;
import openfl.geom.Point;
import haxe.Timer;
import motion.Actuate;


/**
 * 角色ai
 * @author li
 */
class PlayerAI extends BaseAiControl
{
	private var _id:Int;
	private var _playerRoot:BevNode;
	private var _playerInputData:MonsterInputData;
	private var _playerOutputData:MonsterOutputData;
	
	private var _model:Entity;
	private var _stat:PlayerStat;
	//private var _holdFire:Bool;
	private static var _aimAreaAdjustX = 150;//瞄准区域以_model.x为基准，沿_model前方推移值
	private static var _maxElevation = 1;//人物基准点与怪物基准点连线的斜率，=1时为45度

	public function new(id:Int) 
	{
		super();
		_id = id;
		_playerRoot = AiFactory.instance.createAI(0);
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = owner.getComponent(MTActor);
		_stat = owner.getComponent(PlayerStat);
		//_holdFire = false;
	}
	
	override public function initData():Void 
	{
		super.initData();
		_playerInputData = new MonsterInputData();
		_playerOutputData = new MonsterOutputData();
		_playerInputData.SelfPoint = new Point();
		_playerInputData.AttackingRadius = 0.6;
		_playerInputData.BaseAttackTime = 0;
		_playerInputData.BaseIdleTime = 0;
		_playerInputData.isEscape = 2;
		_playerInputData.Victory = false;
	}

	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgActor.PostLoad:
				cmd_PostLoad(userData);
			case MsgActor.Respawn:
				cmd_Revive(userData);
			case MsgActor.Victory:
				cmd_Victory(userData);
			//case MsgInput.HoldFire:
				//cmd_HoldFire(userData);
		}
	}
	
	
	private function cmd_PostLoad(userData:Dynamic):Void
	{
		_model = userData;
	}
	
	private function cmd_Revive(userData:Dynamic):Void
	{
		trace("AI Respawn");
		_stop = false;
	}
	
	private function cmd_Victory(userData:Dynamic):Void
	{
		_stop = true;
		//trace("victory");
		GameProcess.root.notify(MsgStartup.PauseCountDown,true);
		Actuate.tween(this, 2.5, { } ).onComplete(function() { _playerInputData.Victory = true; _stop = false; } );
	}
	/*
	private function cmd_HoldFire(userData:Dynamic):Void
	{
		_holdFire = userData;
		//_stop = !userData;
		//setAttackStatus(_holdFire);
	}
	*/
	override function cmd_SetInputEnable(userData):Void 
	{
		super.cmd_SetInputEnable(userData);
	}
	private function findClose(ary:Array<Entity>):Entity
	{
		var collideE:Entity = null;
		for (e in ary)
		{
			if (e != null && e.visible) {
				if (collideE == null) {
					collideE = e;
				} else {
					if (_model.distanceFrom(e) < _model.distanceFrom(collideE))
						collideE = e;
				}
			}
		}
		return collideE;
	}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		if (_stop) return;
		//trace(_model);
		if (_model == null)
			return;
		/*
		//if (_stat.holdFire) {
			_playerInputData.SelfPoint = new Point(_actor.x, _actor.y);
			_playerInputData.AttackMelee = false;
			var collideList = [];
			var collideE:Entity = null;
			var tempE:Entity = null;
			for (modelType in _collideList) 
			{
				collideList = [];
				
				//HXP.scene.collideCircleInto(modelType, _model.x, _model.y, HXP.width*0.6, collideList);
				if(_actor.dir==Direction.RIGHT){
					HXP.scene.collideRectInto(modelType, _model.x, 0, HXP.width * 0.6, HXP.height, collideList);
				}else {
					HXP.scene.collideRectInto(modelType, _model.x -HXP.width * 0.6, 0, HXP.width * 0.6, HXP.height, collideList);
				}
				if (collideList.length > 0)
					tempE = findClose(collideList);
				else
					tempE = null;
				//var tempE = HXP.scene.nearestToRect(modelType, _model.x-HXP.halfWidth, _model.y-HXP.halfHeight,_model.x+HXP.halfWidth, _model.y+HXP.halfHeight);
				//var tempE = HXP.scene.nearestToEntity(modelType, _model, true);
				if (tempE != null && tempE.visible) {
					if (collideE == null) {
						collideE = tempE;
					} else {
						if (_model.distanceFrom(tempE) < _model.distanceFrom(collideE))
							collideE = tempE;
					}
				}
			}
			if (collideE != null && (!collideE.visible || !collideE.active))
				collideE = null;
			if (collideE == null) {//最后才判断攻击场景物体
				//collideE = HXP.scene.nearestToRect(UnitModelType.Block, _model.x-HXP.halfWidth, _model.y-HXP.halfHeight,_model.x+HXP.halfWidth, _model.y+HXP.halfHeight);
				//collideE = HXP.scene.nearestToEntity(UnitModelType.Block, _model, true);
				if(_actor.dir==Direction.RIGHT){
					collideE = HXP.scene.collideRect(UnitModelType.Block, _model.x, 0, HXP.width * 0.6, HXP.height);
				}else {
					collideE = HXP.scene.collideRect(UnitModelType.Block, _model.x -HXP.width * 0.6, 0, HXP.width * 0.6, HXP.height);
				}
			}
			if (collideE != null && collideE.visible) {	
				//判断攻击范围
				if (collideE.type != UnitModelType.Block && collideE.type != UnitModelType.Boss) {
					//trace(Type.typeof(collideE));
					var actor:UnitActor = (cast(collideE, AbstractAvatar).owner.getComponent(UnitActor));
					//近身变刀设置
					//if(actor.faction != BoardFaction.Elite && actor.faction != BoardFaction.Machine)	
						//if (_model.distanceFrom(collideE) <= 100)
							//_playerInputData.AttackMelee = true;
				}
				_playerInputData.TargetPoint = new Point(collideE.x, collideE.y - collideE.halfHeight);
				//notify(MsgInput.DirAttack, {melee:_playerInputData.AttackMelee, target:_playerInputData.TargetPoint});
			}
			else
			{
				_playerInputData.TargetPoint = null;
				//notify(MsgInput.DirAttack, {melee:_playerInputData.AttackMelee});
			}
		//}
		*/
		
		findAimPoint();
		
		notify(MsgInput.Aim, {melee:_playerInputData.AttackMelee, target:_playerInputData.TargetPoint});
		//if (_stat.holdFire)
		//{
			//notify(MsgInput.DirAttack, {melee:_playerInputData.AttackMelee, target:_playerInputData.TargetPoint});
		//}
		//ai
		if (_playerRoot.evaluate(_playerInputData))
		{
			_playerRoot.tick(_playerInputData, _playerOutputData);
		}
		render(_playerOutputData);
	}
	//找瞄准点
	private var _collideList = [UnitModelType.Boss, UnitModelType.Unit, UnitModelType.Elite];
	//计数器
	private var timeCount:Int = 0;
	/**瞄准目标*/
	private var collideE:Entity = null;
	
	var targetCollideList:Array<Entity>;
	var tempE:Entity;
	var removeList:Array<Entity>;
	private function findAimPoint()
	{
		timeCount++;
		//每10帧寻找一次瞄准点
		if (timeCount>=10) 
		{
			//var starttime = Timebase.stamp();
			//var overTime = Timebase.stamp();
			timeCount = 0;
			_playerInputData.SelfPoint.x = _actor.x;
			_playerInputData.SelfPoint.y = _actor.y;
			_playerInputData.AttackMelee = false;
			targetCollideList= [];
			//var collideE:Entity = null;
			collideE = null;
			tempE = null;
			
			if (_actor.dir == Direction.RIGHT) {			
				for (modelType in _collideList) {
					HXP.scene.collideRectInto(modelType, _model.x+_aimAreaAdjustX, 0, HXP.halfWidth, HXP.height, targetCollideList);
				}
			}else {
				for (modelType in _collideList) {
					HXP.scene.collideRectInto(modelType, _model.x -HXP.halfWidth-_aimAreaAdjustX, 0, HXP.halfWidth, HXP.height, targetCollideList);
				}		
			}
			//trace("collideList: "+collideList.length);
			removeList = [];
			for (collide1 in targetCollideList) 
			{
				//线段碰撞检测间隔为20
				if (!(collide1 != null && collide1.visible) || HXP.scene.collideLine(UnitModelType.Solid, Math.round(_model.x), Math.round(_model.y - _model.halfHeight), Math.round(collide1.x), Math.round(collide1.y - collide1.halfHeight),20)!=null) {
					removeList.push(collide1);
				}
			}
			for (removeObj in removeList) 
			{
				targetCollideList.remove(removeObj);
			}
			
			if (targetCollideList.length > 0) {
				tempE = findClose(targetCollideList);
			}else {	
				tempE = null;
			}
			
			collideE = tempE;
				
			if (collideE != null && (!collideE.visible || !collideE.active))
				collideE = null;
			if (collideE == null) {//最后才判断攻击场景物体
				if(_actor.dir==Direction.RIGHT){
					collideE = HXP.scene.collideRect(UnitModelType.Block, _model.x+_aimAreaAdjustX, 0, HXP.halfWidth, HXP.height);
				}else {
					collideE = HXP.scene.collideRect(UnitModelType.Block, _model.x -HXP.halfWidth-_aimAreaAdjustX, 0, HXP.halfWidth, HXP.height);
				}
			}
			//overTime = Timebase.stamp();
			//trace("Unserializertime: " + (overTime-starttime));
		}	
		
		if (collideE != null && collideE.visible) {				
			if (collideE.y <_actor.y-_actor.halfHeight && collideE.y- collideE.height>_actor.y-_actor.halfHeight) 
			{
				_playerInputData.TargetPoint = null;
				//trace("");
			}else 
			{
				_playerInputData.TargetPoint = new Point(collideE.x, collideE.y - collideE.halfHeight);
			}
			//trace("_playerInputData.TargetPoint: "+_playerInputData.TargetPoint);
		}else{
			_playerInputData.TargetPoint = null;
		}
	}
	private function render(playerOutput:MonsterOutputData):Void 
	{
		//trace("monsterOutput.CurrentStatus " + playerOutput.CurrentStatus);
		switch(playerOutput.CurrentStatus) {
			case AIStatus.Attack:
				//if (monsterOutput.isBaseAttack) //如果是攻击间隔则返回
					//return;
				//notify(MsgInput.DirAttack, {melee:_playerInputData.AttackMelee, target:_playerInputData.TargetPoint});
			case AIStatus.Idle:
			case AIStatus.Escape:
				Input_Escape(null);
		}
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
		Actuate.stop(this);
		_id = 0;
		_stat = null;
		_playerRoot = null;
		_playerInputData.SelfPoint = null;
		_playerInputData = null;		
		_playerOutputData = null;
		_model = null;
	}
	
	private function setAttackStatus(value:Bool):Void
	{
		_playerInputData.isOnAttackStatus = value;
	}
	
	
}