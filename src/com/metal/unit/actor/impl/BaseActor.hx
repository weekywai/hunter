package com.metal.unit.actor.impl;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.math.Vector;
import com.metal.config.UnitModelType;
import com.metal.fsm.FState;
import com.metal.fsm.FStateMachine;
import com.metal.message.MsgActor;
import com.metal.message.MsgStat;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.board.impl.GameBoardItem;
import com.metal.scene.map.GameMap;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.avatar.MTAvatar;
import com.metal.unit.stat.IStat;
import de.polygonal.core.es.EntityUtil;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.MsgCore;
import openfl.geom.Point;
import pgr.dconsole.DC;
using com.metal.enums.Direction;
/**
 * 基础角色
 * @author weeky
 */
using com.metal.unit.actor.api.ActorState.ActionType;
class BaseActor extends GameBoardItem implements IActor
{
	/**扔炸弹的节点*/
	public var throwBomb:Bool;
	/**重力*/
	public var _gravity(default, default):Float = 0;
	
	/**阻力*/
	private var _friction:Point;
	/**跳高速度*/
	private var _maxSpeed:Point;
	private var _slopeHeight:Int = 1;
	/**行走速度*/
	private var _moveSpeed:Float = 1;
	private var _jumped:Int;
	private var _jumpHeight:Float;
	/**加速*/
	public var acceleration:Point;
	/** 移动速度 */
	public var velocity:Point;
	
	private var _doublejump:Bool;
	
	private var _collides:Array<String> = [UnitModelType.Solid, UnitModelType.Block];
	private var _model:Entity;
	
	private var _fsm:FStateMachine;
	private var _state:FState;
	public var stateTime:Float;
	
	public var isNeedLeftFlip:Bool;
	public var isNeedRightFlip:Bool;
	public var isAttack:Bool;
	public var isRunMap:Bool;
	public var onWall:Bool;
	
	//{interface
	private var _bindPlayerID:Int = -1;
	public var bindPlayerID(get, null):Int;
	private function get_bindPlayerID():Int { return _bindPlayerID; }
	public var stateID(get, null):Int;
	private function get_stateID():Int { return _state.id; }
	public function canTransition(targetStateID:Int):Bool {
		return _state.canTransition(targetStateID);
	}
	public function transition(targetID:Int):Void {
		_state = _fsm.transition(_state, targetID, this);
	}
	
	private var _dir:Direction = NONE;
	public var dir(get, set):Direction;
	private function get_dir():Direction{ return _dir; }
	private function set_dir(value:Direction):Direction {
		_dir = value;
		if (value == Direction.LEFT)
		{
			if (!isNeedLeftFlip)
				return _dir;
			cast(_model, MTAvatar).flip = true;
		}
		else if (value == Direction.RIGHT)
		{
			if (!isNeedRightFlip)
				return _dir;
			cast(_model, MTAvatar).flip = false;
		}
		return _dir; 
	}
	public var radarRange(get, null):Int;
	private function get_radarRange():Int{ return 0; }
	public function getProperty(key:String):String { return null; }
	//}
	
	
	public function onCamera():Bool
	{
		if (_model != null)
			return _model.onCamera;
		return false;
	}
	
	
	private var _stat:IStat;
	
	override function get_halfHeight():Float { 
		if (_model == null) return 0;
		return _model.halfHeight; }
	override function get_halfWidth():Float { 
		if (_model == null) return 0;
		return _model.halfWidth; }
	
	public function new() 
	{
		super();
		_fsm = ActorFsmLib.instance.getActorFsm();
		velocity = new Point();
		_friction = new Point(0.5, 0.5);
		_maxSpeed = new Point(8, 16);
		acceleration = new Point();
		_jumpHeight = 16;
		stateTime = 0;
		_doublejump = false;
		x = HXP.width / 2;
		isNeedLeftFlip = true;
		isNeedRightFlip = true;
		isAttack = false;
		onWall = false;
	}
	
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgCore.PROCESS:
				cmd_PostBoot(userData);
			case MsgActor.PostLoad:
				cmd_PostLoad(userData);
			case MsgActor.EnterBoard:
				Notify_EnterBoard(userData);
			case MsgActor.Enter:
				Notify_Enter(userData);
			case MsgActor.Stand:
				Notify_Stand(userData);
			case MsgActor.Move:
				Notify_Move(userData);
			case MsgActor.Jump:
				Notify_Jump(userData);
			case MsgActor.Skill:
				Notify_Skill(userData);
			case MsgActor.Attack:
				Notify_Attack(userData);
			case MsgActor.ThrowBomb:
				Notify_ThrowBomb(userData);
			case MsgActor.Melee:
				Notify_Melee(userData);
			case MsgActor.Injured:
				Notify_Injured(userData);
			case MsgActor.Patrol:
				Notify_Patrol(userData);
			case MsgActor.Escape:
				Notify_Escape(userData);
			case MsgActor.Destroying:
				Notify_Destroying(userData);
			case MsgActor.Destroy:
				Notify_Destroy(userData);
			case MsgActor.Soul:
				Notify_Soul(userData);
			case MsgActor.Respawn:
				//trace("Respawn");
				Notify_Respawn(userData);
			case MsgActor.Reborn:
				trace("reborn");
				Notify_Respawn(userData);
			case MsgActor.Victory:
				Notify_Victory(userData);
			case MsgActor.PosForceUpdate:
				Notify_PosForceUpdate(userData);
			case MsgStat.ChangeSpeed:
				notify_ChangeSpeed(userData);
		}
		super.onNotify(type, source, userData);
	}
	override function onDispose():Void 
	{
		_state = _fsm.transition(_state, ActorState.Destroyed, this);
		_fsm = null;
		_state = null;
		_stat = null;
		_friction = null;
		velocity = null;
		acceleration = null;
		_model = null;
		isNeedLeftFlip = false;
		isNeedRightFlip = false;
		_jumped = 0;
		super.onDispose();
	}
	private function cmd_PostBoot(userData:Dynamic):Void {
		//必须设置一种状态
		transition(ActorState.Stand);
	}
	private function cmd_PostLoad(userData:Dynamic):Void
	{
		_model = userData;
		var avatar = cast(_model, MTAvatar);
		if(avatar!=null)
			avatar.setCallback(onComplete);
		
	}
	
	public var isGrounded (default, default):Bool;

	override public function onTick(timeDelta:Float) 
	{
		if (!isInBoard())
			return;
		if (isDisposed) return;
		if (_model == null) return;
		if (stateID == ActorState.Destroyed)
			return;
		// 更新状态逻辑
		if (_state != null)
			_state.update(this);
		stateTime += timeDelta;
		onState();
		
		gravity();
		
		maxspeed(false, true);
		if (velocity.y < 0 && stateID != ActorState.Jump && stateID != ActorState.DoubleJump) { gravity(); gravity(); }
		
		if (isGrounded && velocity.x == 0) {
			//trace("stand");	
			//transition(ActorState.Stand);
		}
		motion();
		acceleration.x = 0;
		super.onTick(timeDelta);
	}
		
	public function onState()
	{
		if (ActorState.IsDestroyed(stateID))
			return;
		//if (Math.abs(velocity.x) > _maxSpeed.x) {
			friction(true, false);
		//}
		isGrounded = false;
		if (_model.collideTypes(_collides, x, y + 1) != null) 
		//if (_model.collide(UnitModelType.Solid, x, y + 1) != null) 
		{
			isGrounded = true;
		}
		
		//if (isGrounded) 
		//{
			//if (_jumped > 0) {
				//_jumped = 0;
				//trace("isGrounded,_jumped = 0");
				//transition(ActorState.Stand);
			//}else if (stateID != ActorState.Jump && stateID != ActorState.Attack && velocity.x == 0) {	
				//transition(ActorState.Stand);
			//}
			//
		//}
		if (isGrounded) 
		{		
			if (velocity.y > 0) {				
				if (stateID == ActorState.Jump || stateID == ActorState.DoubleJump) {
					transition(ActorState.Stand);
					//trace("transition(ActorState.Stand)");
				}
				//trace("isGrounded,_jumped = 0");
				if (stateID == ActorState.Move && velocity.x == 0 && acceleration.x == 0) {	
					transition(ActorState.Stand);
					//trace("transition(ActorState.Stand)");
				}
			}			
		}
	}
	function gravity():Void 
	{
		//increase velocity/speed based on gravity
		velocity.y += _gravity;
	}
	function friction(x:Bool = true, y:Bool = true):Void 
	{
		//if we should use friction, horizontally
		if (x)
		{
			//speed > 0, then slow down
			if (velocity.x > 0) {
				velocity.x -= _friction.x;
				//if we go below 0, stop.
				if (velocity.x < 0) { velocity.x = 0; }
			}
			//speed < 0, then "speed up" (in a sense)
			if (velocity.x < 0) {
				velocity.x += _friction.x;
				//if we go above 0, stop.
				if (velocity.x > 0) { velocity.x = 0; }
			}
		}
	}
	
	function maxspeed(x:Bool = true, y:Bool = true):Void
	{
		if (x)
		{
			if (Math.abs(velocity.x) > _maxSpeed.x)
			{
				velocity.x = _maxSpeed.x * HXP.sign(velocity.x);
			}
		}
			
		if (y)
		{
			if (Math.abs(velocity.y) > _maxSpeed.y)
			{
				//trace("maxspeed:" + velocity.y);
				velocity.y = _maxSpeed.y * HXP.sign(velocity.y);
				
			}
		}
	}
	function motion(mx:Bool = true, my:Bool = true):Void {
		
		//if we should move horizontally
		if ( mx )
		{
			//make us move, and stop us on collision
			if (!motionx(_model, velocity.x)) {
				velocity.x = 0;
			}
			//increase velocity/speed
			velocity.x += acceleration.x;
		}
		
		//if we should move vertically
		if ( my )
		{
			//make us move, and stop us on collision
			if (!motiony(_model, velocity.y)) { velocity.y = 0; }
			
			//increase velocity/speed
			velocity.y += acceleration.y;
		}
		
	}
	/**
	 * Moves the set entity horizontal at a given speed, checking for collisions and slopes
	 * @param	e	The entity you want to move
	 * @param	spdx	The speed at which the entity should move
	 * @return	True (didn't hit a solid) or false (hit a solid)
	 */
	function motionx(e:Entity, spdx:Float):Bool
	{
		//check each pixel before moving it
		for (i in 0...Std.int(Math.abs(spdx)))
		{
			//if we've moved
			var moved:Bool = false;
			var below:Bool = true;
			
			if (e.collideTypes(_collides, x, y + 1) == null) {
				below = false;
			}
			
			//run through how high a slope we can move up
			for (s in 0...(_slopeHeight + 1))
			{
				//if we don't hit a solid in the direction we're moving, move....
				if (e.collideTypes(_collides, x + HXP.sign(spdx), y - s) == null) 
				{
					//increase/decrease positions
					//if the player is in the way, simply don't move (but don't count it as stopping)
					if (e.collideTypes(_collides, x + HXP.sign(spdx), y - s) == null) {
						x += HXP.sign(spdx);
					}
					
					//move up the slope
					y -= s;
					
					//we've moved
					moved = true;
					//stop checking for slope (so we don't fly up into the air....)
					break;
				}
				
			}
			
			//if we are now in the air, but just above a platform, move us down.
			if (below && e.collideTypes(_collides, x, y + 1) == null) {
				y += 1;
			}
			
			//if we haven't moved, set our speed to 0
			if (!moved) {
				return false;
			}
			
		}
		
		//hit nothing!
		return true;
	}

	/**
	 * Moves the set entity vertical at a given speed, checking for collisions
	 * @param	e	The entity you want to move
	 * @param	spdy	The speed at which the entity should move
	 * @return	True (didn't hit a solid) or false (hit a solid)
	 */
	function motiony(e:Entity, spdy:Float):Bool
	{
		//trace(spdy);
		//for each pixel that we will move...
		for (i in 0...Std.int(Math.abs(spdy)))
		{
			//if we DON'T collide with solid
			if (e.collideTypes(_collides, x, y + HXP.sign(spdy)) == null) { 
				//if we don't run into a player, them move us
				//if (e.collide(UnitModelType.Solid, x, y + HXP.sign(spdy)) == null) {
					y += HXP.sign(spdy);
				//}
			} else {
				//trace("hit");
				return false; 
			}
		}
		return true;
	}
	
	private function onComplete(i:Int,name:Dynamic):Void 
	{
		//判断攻击状态结束
		if (name == Std.string(ActionType.attack_1) 
		|| name == Std.string(ActionType.throwBomb_1)) {
			//if(!attack)
				transition(ActorState.Stand);
		}
		//trace(name);
		if (name == Std.string(ActionType.dead_1)) {
			//trace("destory");
			notify(MsgActor.Destroy);
		}
	}
//{Notify 
	override function Notify_InitFaction(userData:Dynamic):Void 
	{
		super.Notify_InitFaction(userData);
		_bindPlayerID = userData.id;
		switch(faction) {
			case BoardFaction.Player,BoardFaction.Block, BoardFaction.Enemy, BoardFaction.Npc, BoardFaction.Vehicle, BoardFaction.Boss, BoardFaction.Elite, BoardFaction.Machine:
				_gravity = 0.6;
			case BoardFaction.Item:
				if (!isRunMap)
					_gravity = 0.6;
		}
	}
	private function Notify_Stand(userData:Dynamic):Void 
	{
		if (faction == BoardFaction.FlyEnemy || faction == BoardFaction.Boss1)
		{
			transition(ActorState.Stand);
		}
		else
		{
			if (isGrounded){
				transition(ActorState.Stand);
			}
		}
		//trace("Notify_Stand" + acceleration);
		acceleration.x = 0;
		velocity.setTo(0, 0);
	}
	
	private function Notify_Move(userData:Dynamic):Void 
	{
		if (stateID != ActorState.Jump && stateID != ActorState.Skill)
			transition(ActorState.Move);
		acceleration.x = 0;
		dir = userData;
		if (dir == LEFT && velocity.x > -_maxSpeed.x)
			acceleration.x = -_moveSpeed;
		else if(dir == RIGHT && velocity.x < _maxSpeed.x)
			acceleration.x = _moveSpeed;
		//trace("Notify_Move" + acceleration +" dir:"+ dir);
	}
	private function Notify_EnterBoard(userData:Dynamic):Void 
	{
		isRunMap = EntityUtil.findBoardComponent(GameMap).mapData.runKey;
	}
	private function Notify_Enter(userData:Dynamic):Void 
	{
		transition(ActorState.Enter);
		acceleration.x = 0;
		dir = userData;
		if (dir == LEFT)
			acceleration.x = -_moveSpeed;
		else if(dir == RIGHT)
			acceleration.x = _moveSpeed;
			trace("Enter" + acceleration +" dir:"+ dir);
	}
	
	private function Notify_Skill(userData:Dynamic):Void 
	{
		transition(ActorState.Skill);
		acceleration.x = 0;
		//trace("Skill" + acceleration );
	}
	
	private function Notify_Attack(userData:Dynamic):Void 
	{
		dir = userData;
		isAttack = true;
	}
	
	private function Notify_Melee(userData:Dynamic):Void 
	{
		if (stateID == ActorState.Melee) return;
		//dir = userData;
		//isAttack = true;
		//trace("Notify_Melee");
		transition(ActorState.Melee);
	}
	
	private function Notify_ThrowBomb(userData:Dynamic):Void 
	{
		if (stateID == ActorState.ThrowBomb) return;
		//isAttack = true;
		//trace("Notify_Melee");
		transition(ActorState.ThrowBomb);
	}
	
	private function Notify_Escape(userData:Dynamic):Void
	{
		//trace("Notify_Escape");
		if (x < HXP.width + HXP.camera.x)
			Notify_Move(LEFT);
		else
			Notify_Move(RIGHT);
	}
	
	private function Notify_Patrol(userData:Dynamic):Void { }
	private function Notify_Injured(userData:Dynamic):Void { }
	private function Notify_Respawn(userData:Dynamic):Void {
		//trace("Notify_Respawn");
		transition(ActorState.Revive);
		//_model.type  = owner.name;
	}
	private function notify_ChangeSpeed(userData:Dynamic):Void { }
	private function Notify_Destroying(userData:Dynamic):Void
	{
		
		if (stateID == ActorState.Destroying || stateID == ActorState.Destroyed) 			
			return;
		//trace("Destroying");
		//trace("_actor.stateID: "+stateID);
		transition(ActorState.Destroying);
		//trace("_actor.stateID after transition: "+stateID);
		acceleration.x = 0;
		velocity.x = 0;
		//trace("Destroying" + acceleration );
		//_model.type = "";
	}
	private function Notify_Destroy(userData:Dynamic):Void
	{
		//transition(ActorState.Destroyed);
		notify(MsgActor.ExitBoard);
	}
	private function Notify_Soul(userData:Dynamic):Void {}
	private function Notify_Jump(userData:Dynamic):Void 
	{
		//trace("Notify_Jump"+isGrounded);
		if (_jumped>0)
			_jumped++;
			transition(ActorState.Jump);
	}
	private function Notify_Victory(userData:Dynamic):Void 
	{		
		transition(ActorState.Victory);
		//trace("Notify_Victory: "+stateID);
		acceleration.x = 0;
	}
	private function Notify_PosForceUpdate(userData:Dynamic):Void 
	{
		if (x > userData.x)
			dir = LEFT;
		else if (x < userData.x)
			dir = RIGHT;
		x = userData.x;
		y = userData.y;
	}
//}
}