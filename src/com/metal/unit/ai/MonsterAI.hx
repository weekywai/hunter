package com.metal.unit.ai;
import com.haxepunk.HXP;
import com.metal.component.GameSchedual;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.SkillManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.ai.type.AiFactory;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.data.MonsterInputData;
import com.metal.unit.bevtree.data.MonsterOutputData;
import com.metal.unit.stat.IStat;
import com.metal.unit.stat.UnitStat;
import de.polygonal.core.event.IObservable;
import openfl.geom.Point;

/**
 * ...
 * @author li
 */
class MonsterAI extends BaseAiControl
{
	private var _player:MTActor;
	private var _selfActor:UnitActor;
	private var _selfStat:IStat;
	private var _id:Int;
	private var _monsterRoot:BevNode;
	private var _monsterInfo:MonsterInfo;
	private var _monsterInputData:MonsterInputData;
	private var _monsterOutData:MonsterOutputData;
	private var _time:Float = 0;
	private var _bornPos:Point;

	public function new(id:Int) 
	{
		super();
	
		_id = id;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_monsterInfo = owner.getProperty(MonsterInfo);
		//trace(_id + ">>" + _monsterInfo.AiType);
		_monsterRoot = AiFactory.instance.createAI(_monsterInfo.AiType);
		_actor = owner.getComponent(UnitActor);
		
	}
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgActor.AttackStatus:
				cmd_AttackStatus(userData);
		}
	}
	override function cmd_enterBoard():Void 
	{
		var gs:GameSchedual = GameProcess.root.getComponent(GameSchedual);
		_player = gs.playerEntity.getComponent(MTActor);
		_selfStat = owner.getComponent(UnitStat);
		_selfActor = owner.getComponent(UnitActor);
		super.cmd_enterBoard();
	}
	
	override public function initData():Void 
	{
		super.initData();
		_monsterInputData = new MonsterInputData();
		_monsterOutData = new MonsterOutputData();
		_monsterOutData.isEnter = false;
		_monsterInputData.AttackingRadius = _monsterInfo.AttackRadius;
		_monsterInputData.MaxAppearTimes = _monsterInfo.ResidenceTime;
		_monsterInputData.MaxAttackTimes = _monsterInfo.AtkNum;
		_monsterInputData.MaxHp = _monsterInfo.MaxHp;
		_monsterInputData.WarningRadius = _monsterInfo.AlertRadius;
		_monsterInputData.isPatrol = _monsterInfo.BehaviorType;
		
		_monsterInputData.TargetPoint = new Point(_player.x, _player.y);
		_monsterInputData.SelfPoint = new Point(_actor.x, _actor.y);
		/*
		if(_monsterInfo.FixedType == 0)
		{
			//var pos:Point = _monsterInfo.BornAt;
			var pos:Point = _bornPos;
			var x:Float = pos.x * HXP.width + HXP.camera.x;
			var y:Float = pos.y * HXP.height + HXP.camera.y;
			_monsterInputData.BornPoint = new Point(x, y);
		}
		*/
		if (_bornPos != null)
		{
			var x:Float = _bornPos.x * HXP.width + HXP.camera.x;
			var y:Float = _bornPos.y * HXP.height + HXP.camera.y;
			_monsterInputData.BornPoint = new Point(x, y);
		}
		var skill:SkillInfo = SkillManager.instance.getInfo(_monsterInfo.SkillId);
		_monsterInputData.BaseAttackTime = skill.CDTime * 60;
		_monsterInputData.BaseIdleTime = _monsterInfo.PublicCD * 60;
		_monsterInputData.BaseMoveTime = 1 * 60;
	}
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		//trace(_stop);
		if (_stop) return;
		_monsterInputData.TargetPoint.x = _player.x;
		_monsterInputData.TargetPoint.y = _player.y;
		_monsterInputData.SelfPoint.x = _actor.x;
		_monsterInputData.SelfPoint.y = _actor.y;
		//_monsterInputData.BornPoint = new Point(500,500);
		_monsterInputData.CurrentHP = _selfStat.hp;//_monsterInputData.MaxHp;
		//ai
		if (_monsterRoot.evaluate(_monsterInputData))
		{
			var tick = _monsterRoot.tick(_monsterInputData, _monsterOutData);
		}
		render(_monsterOutData);
	}
	
	private function render(monsterOutput:MonsterOutputData):Void 
	{
		//trace("monsterOutput.CurrentStatus " + monsterOutput.CurrentStatus);
		switch(monsterOutput.CurrentStatus) {
			case AIStatus.Dead:
				
			case AIStatus.Attack:
				//return;
				if (monsterOutput.isBaseAttack) //如果是攻击间隔则返回
					return;
					
				if(monsterOutput.flipX)
					Input_Attack(Direction.LEFT);	
				else
					Input_Attack(Direction.RIGHT);	
			case AIStatus.Escape:
				Input_Escape(null);
			case AIStatus.Follow:
				if(monsterOutput.flipX)
					Input_Move(Direction.LEFT);
				else
					Input_Move(Direction.RIGHT);
			case AIStatus.Move:
				if (monsterOutput.flipX)
					Input_Move(Direction.LEFT);
				else
					Input_Move(Direction.RIGHT);
			case AIStatus.Idle:
				Input_Stand(_actor.dir);
			case AIStatus.Patrol:
				//Input_Patrol();
				Input_Stand(_actor.dir);
			case AIStatus.Skill:
				Input_Skill(monsterOutput.SkillType);
			case AIStatus.Enter:
				//trace(monsterOutput.flipX+"--"+_selfActor.faction);
				if (_selfActor.faction == BoardFaction.Boss || _selfActor.faction == BoardFaction.Boss1) {
					if (monsterOutput.flipX == null) {
						Input_Enter(null);
						return;
					}
					
					if(monsterOutput.flipX)
						Input_Enter(Direction.LEFT);
					else
						Input_Enter(Direction.RIGHT);
				}else
				{
					if (monsterOutput.flipX == null)
						return;
					if(monsterOutput.flipX)
						Input_Move(Direction.LEFT);
					else
						Input_Move(Direction.RIGHT);
				}
				/*
				if (_selfActor.faction == BoardFaction.Boss) {
					if (monsterOutput.flipX == null) {
						Input_Enter(null);
						return;
					}
					
					if(monsterOutput.flipX)
						Input_Enter(Direction.LEFT);
					else
						Input_Enter(Direction.RIGHT);
				}else {
					if (monsterOutput.flipX == null)
						return;
					if(monsterOutput.flipX)
						Input_Move(Direction.LEFT);
					else
						Input_Move(Direction.RIGHT);
				}
				*/
				if(_monsterOutData.isEnter)
					_player.notify(MsgInput.SetInputEnable, true);
		}
	}
	
	override function cmd_BornPos(userData:Dynamic):Void 
	{
		super.cmd_BornPos(userData);
		_bornPos = cast(userData, Point);
		//trace(_bornPos);
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
		_id = 0;
		_monsterRoot = null;
		_monsterInfo = null;
		_monsterInputData = null;
		_monsterOutData = null;
		_player = null;
		_selfStat = null;
	}
	
	function cmd_AttackStatus(value:Dynamic):Void
	{
		//trace("setAttackStatus: "+value);
		_monsterInputData.isOnAttackStatus = value;
	}
	
	public function setIsPatrol(value:Int):Void
	{
		_monsterInputData.isPatrol = value;
	}
	
}