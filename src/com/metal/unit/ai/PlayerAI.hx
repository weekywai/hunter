package com.metal.unit.ai;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.metal.config.UnitModelType;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.message.MsgStartup;
import com.metal.unit.stat.PlayerStat;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.view.ViewActor;
import com.metal.unit.ai.type.AiFactory;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import de.polygonal.core.event.IObservable;
import openfl.geom.Point;


/**
 * 角色ai
 * @author li
 */
class PlayerAI extends BaseAiControl
{
	private var _playerRoot:BevNode;
	private var _playerInputData:MonsterInputData;
	private var _playerOutputData:MonsterOutputData;
	
	private var _model:ViewActor;
	private var _stat:PlayerStat;
	private static var _aimAreaAdjustX = 150;//瞄准区域以_model.x为基准，沿_model前方推移值
	private static var _maxElevation = 1;//人物基准点与怪物基准点连线的斜率，=1时为45度

	public function new(id:Int) 
	{
		super();
		_playerRoot = AiFactory.instance.createAI(0);
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = owner.getComponent(MTActor);
		_stat = owner.getComponent(PlayerStat);
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
		_playerInputData.Victory = true; //through animation
		_stop = true;
		//trace("victory");
		GameProcess.root.notify(MsgStartup.PauseCountDown, true);
	}
	
	private function findClose(ary:Array<Entity>):Entity
	{
		var collideE:Entity = null;
		var p:Point =  _model.getGunPoint("muzzle_1");
		for (e in ary)
		{
			if (e != null && e.visible) {
				if (HXP.scene.collideLine(UnitModelType.Solid, Std.int(p.x), Std.int(p.y), Math.round(e.x), Math.round(e.y - e.halfHeight), 32)!=null) {
					continue;
				}
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
		
		findAimPoint();
		
		notify(MsgInput.Aim, {melee:_playerInputData.AttackMelee, target:_playerInputData.TargetPoint});
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
	private function findAimPoint()
	{
		timeCount++;
		//每10帧寻找一次瞄准点
		if (timeCount>=10) 
		{
			timeCount = 0;
			_playerInputData.SelfPoint.x = _actor.x;
			_playerInputData.SelfPoint.y = _actor.y;
			_playerInputData.AttackMelee = false;
			targetCollideList= [];
			collideE = null;
			if (_owner.name == UnitModelType.Vehicle) {//不需要方向屏幕查找
				for (modelType in _collideList) {
					HXP.scene.collideRectInto(modelType, HXP.camera.x, HXP.camera.y, HXP.width, HXP.height, targetCollideList);
				}
			}else{
				//方向屏幕查找
				if (_actor.dir == Direction.RIGHT) {			
					for (modelType in _collideList) {
						HXP.scene.collideRectInto(modelType, _model.x+_aimAreaAdjustX, HXP.camera.y, HXP.halfWidth, HXP.height, targetCollideList);
					}
				} else {
					for (modelType in _collideList) {
						HXP.scene.collideRectInto(modelType, _model.x -HXP.halfWidth-_aimAreaAdjustX, HXP.camera.y, HXP.halfWidth, HXP.height, targetCollideList);
					}		
				}
			}
			collideE = findClose(targetCollideList);
		}	
		
		if (collideE != null && collideE.visible) {				
			if (collideE.y <_actor.y-_actor.halfHeight && collideE.y- collideE.height>_actor.y-_actor.halfHeight) 
			{
				_playerInputData.TargetPoint = null;
			}else 
			{
				_playerInputData.TargetPoint = new Point(collideE.x, collideE.y - collideE.halfHeight);
			}
		}else {
			collideE = null;
			_playerInputData.TargetPoint = null;
		}
		//}
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