package com.metal.unit.actor.impl;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.metal.component.BattleSystem;
import com.metal.config.ItemType;
import com.metal.config.UnitModelType;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgItr;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUtils;
import com.metal.player.core.PlayerStat;
import com.metal.proto.impl.BattlePrepareInfo;
import com.metal.proto.impl.GoldGoodInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.manager.BattlePrepareManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.avatar.MTAvatar;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.SimEntity;
import motion.Actuate;
import pgr.dconsole.DC;
/**
 * ...
 * @author weeky
 */
class MTActor extends BaseActor
{
	public var isVictory:Bool;
	public var respawnTotal:Int;
	public function new() 
	{
		super();
		isVictory = false;
		respawnTotal = 0;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_stat = owner.getComponent(PlayerStat);
		transition(ActorState.Jump);	
		_jumped = 1;
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
	}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		if (ActorState.IsDestroyed(stateID))
			return;
		if (isVictory)
			return;
		var e = _model.collide(UnitModelType.DropItem, x , y);
		if (e != null) 
			pickItem(e);
		e = _model.collide(UnitModelType.Npc, x , y);
		if (e != null) 
			collideNPC(e);
		//e = _model.collide("boss", x, y);
		//trace("collide Boss: " + e);
	}
	override function Notify_Attack(userData:Dynamic):Void 
	{
		//trace("stateID: " + stateID);
		if (stateID == ActorState.Melee || stateID == ActorState.ThrowBomb) return;
		dir = userData;
		//isAttack = true;
	}
	override function Notify_Melee(userData:Dynamic):Void 
	{
		//trace("stateID: " + stateID);
		if (stateID == ActorState.Melee || stateID == ActorState.ThrowBomb) return;
		//trace("stateIDMelee: " +stateID);
		//dir = userData;
		//isAttack = true;
		trace("Notify_Melee");
		transition(ActorState.Melee);
	}
	override function Notify_ThrowBomb(userData:Dynamic):Void 
	{
		trace("Notify_ThrowBomb");
		//trace("stateID: " + stateID);
		if (stateID == ActorState.Melee || stateID == ActorState.ThrowBomb) return;
		transition(ActorState.ThrowBomb);
	}
	override function Notify_Jump(userData:Dynamic):Void 
	{
		if (stateID == ActorState.Melee ||stateID ==ActorState.ThrowBomb) return;
		_jumped++;
		//trace("Notify_Jump"+isGrounded);	
		if (_jumped>2) return;
		if (isGrounded && _jumped == 1) {
			transition(ActorState.Jump);	
			velocity.y = -_jumpHeight; 
			//trace("FirstJump: "+stateID);
		}else {
			transition(ActorState.DoubleJump);
			velocity.y = -_jumpHeight; 
			//trace("DoubleJump: " + stateID);
			_jumped++;
		}
		//trace("_jumped: "+_jumped);
	}
	override function Notify_Move(userData:Dynamic):Void 
	{
		if (stateID == ActorState.ThrowBomb) {
			if (isGrounded) {
				velocity.x = 0;
				acceleration.x = 0;
			}
			return;
		}
		//近战状态不能移动
		if (stateID == ActorState.Melee && isGrounded){
			//trace("ActorState.Melee");
			return;
		}
		//trace("stateID: "+stateID);
		if (stateID != ActorState.ThrowBomb && stateID != ActorState.Melee && stateID != ActorState.DoubleJump && stateID != ActorState.Jump && stateID != ActorState.Skill)
			transition(ActorState.Move);
		acceleration.x = 0;
		dir = userData;
		if (dir == LEFT && velocity.x > -_maxSpeed.x)
			acceleration.x = -_moveSpeed;
		else if(dir == RIGHT && velocity.x < _maxSpeed.x)
			acceleration.x = _moveSpeed;
		//trace("Notify_Move" + acceleration +" dir:"+ dir);
	}
	override public function onState() 
	{
		if (ActorState.IsDestroyed(stateID))
			return;
		//if (Math.abs(velocity.x) > _maxSpeed.x) {
			friction(true, false);
		//}
		//陷阱
		if (_model.collide(UnitModelType.Trap,x,y)!=null )
		{
			if (!cast(_stat, PlayerStat).istrapping) 
			{
				trace("collide Trap!");
				cast(_stat, PlayerStat).istrapping = true;
				notify(MsgActor.Injured, {damage:Math.floor(cast(_stat, PlayerStat).hpMax/3)+1, renderType:EffectRequest.Normal});
			}						
		}else if(cast(_stat, PlayerStat).istrapping)
		{
			cast(_stat, PlayerStat).istrapping = false;
		}
		//落地
		isGrounded = false;
		var e = _model.collideTypes(_collides, x, y + 1);
		if (e != null) 
		//if (_model.collide(UnitModelType.Solid, x, y + 1) != null) 
		{
			isGrounded = true;
		}
		if (isGrounded) 
		{		
			if (velocity.y > 0) {				
				if (stateID == ActorState.Jump || stateID == ActorState.DoubleJump) {
					_jumped = 0;
					transition(ActorState.Stand);
					//trace("transition(ActorState.Stand)");
				}
				//trace("isGrounded,_jumped = 0");
				if (stateID == ActorState.Move && velocity.x == 0 && acceleration.x == 0) {	
					transition(ActorState.Stand);
					//trace("transition(ActorState.Stand)");
				}
			}			
		}else 
		{
			if (stateID == ActorState.Stand || stateID == ActorState.Move) 
			{
				transition(ActorState.Jump);
			}
		}
		
		// JUMP
		//if (stateID == ActorState.Jump || stateID != ActorState.DoubleJump)
		//{
			////normal jump
			//if (isGrounded) {
				////trace("isground");
				//velocity.y = -_jumpHeight; 
				//_jumped = 1;
				//_doublejump = true;
			//}else {
				//if(_jumped==0){
				//_jumped = 2;
				//_doublejump = true;
				//}
			//}
			///*弹墙
			//if (_model.collide(UnitModelType.Solid, x - 1, y) != null && _jumped==0 ) 
			//{ 
				//velocity.y = -_jumpHeight;		//jump up
				//velocity.x = _maxSpeed.x * 2;	//move right fast
				//_jumped = 1;		//so we don't "use up" or double jump
			//}
			////same as above
			//if (_model.collide(UnitModelType.Solid, x + 1, y) != null && _jumped==0 ) 
			//{
				//velocity.y = -_jumpHeight; 
				//velocity.x = -_maxSpeed.x * 2;
				//_jumped = 1;
			//}
			//*/
			//
			////set double jump to false
			//if (!isGrounded && _jumped > 1 && _doublejump) {
				//transition(ActorState.DoubleJump);
				//velocity.y = -_jumpHeight;
				//_doublejump = false;
			//}
		//}
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgPlayer.AddCollide:
				cmd_AddCollide(userData);
		}
	}
	
	private function collideNPC(entity:Entity):Void
	{
		trace("npc collide");
		entity.type = "";
		var target:MTAvatar = cast(entity, MTAvatar);
		var item:SimEntity = target.owner;
		item.notify(MsgActor.Destroying);
	}
	
	private function pickItem(entity:Entity):Void
	{
		entity.type = "";
		var target:MTAvatar = cast(entity, MTAvatar);
		var item:SimEntity = target.owner;
		//item.notify(MsgActor.Destroy);
		if (item.parent!=null) {
			var itemInfo:ItemBaseInfo = item.getProperty(ItemBaseInfo);
			if (itemInfo == null) 
				itemInfo = item.getProperty(GoldGoodInfo);
			if (Std.is(itemInfo, GoldGoodInfo)) {
				item.notify(MsgActor.Destroying);
				return;
			}
			DC.log("pickup item" + itemInfo.itemId);
			var itemKind2:Int = GoodsProtoManager.instance.getItemLittleKind(itemInfo.itemId);
			if (itemKind2 == ItemType.IK2_BUFF) {
				var info:BattlePrepareInfo = BattlePrepareManager.instance.getProtoBattlePrepareByID(itemInfo.itemId);
				trace("pickup buff itemId:"+ itemInfo.itemId + " SkillID: " + info.SkillId);
				notify(MsgPlayer.ItemSkill, info.SkillId);
			}
			item.notify(MsgActor.Destroy);
		}
	}
	
	override function Notify_InitFaction(userData:Dynamic):Void 
	{
		super.Notify_InitFaction(userData);
		//switch(faction) {
			//case BoardFaction.Player, BoardFaction.Block,BoardFaction.Enemy, BoardFaction.Npc, BoardFaction.Vehicle, BoardFaction.Boss:
				//_gravity = 1500;
		//}
	}

	override private function onComplete(i:Int,name:Dynamic):Void 
	{
		//trace(name);
		if (name == Std.string(ActionType.dead_1)) {
			//trace("Destorying to soul");
			notify(MsgActor.Soul);
			return;
		}
		var setDefault:Bool = true;
		
		if (name.substr(0,7) == Std.string(ActionType.attack_1).substr(0,7)) {
			if (isGrounded && !isVictory)  transition(ActorState.Stand);
			setDefault = false;
		}
		if (name == Std.string(ActionType.cut_1)) {			
			//trace("cut_1onComplete");
			cast(_stat, PlayerStat).melee = false;			
		}
		
		//if (name == Std.string(ActionType.throwBomb_1)) {
			////trace("cut_1onComplete");
		if (!setDefault || isVictory) return;
			if (isGrounded) {
				_jumped = 0; 
				if (stateID!=ActorState.Stand) 
				{
					transition(ActorState.Stand);
				}				
				//trace("transition(ActorState.Stand)");
			}else if(stateID!=ActorState.Jump) 
			{
				transition(ActorState.Jump);
				//trace("transition(ActorState.Jump)");
			}
		//}
		
	}
	
	override function notify_ChangeSpeed(userData:Dynamic):Void 
	{
		velocity.x = velocity.x * userData[0];
		//trace(_speed + ":"+userData+":" + userData / 100);
	}
	
	override function Notify_Destroy(userData:Dynamic):Void 
	{
		notifyParent(MsgItr.Destory, {key:owner.keyId, id:bindPlayerID});
		super.Notify_Destroy(userData);
	}
	
	override function Notify_Soul(userData:Dynamic):Void 
	{
		super.Notify_Soul(userData);
		
		respawnTotal++;
		if (respawnTotal >= 10) {
			var battle:BattleSystem = GameProcess.root.getComponent(BattleSystem);
			if (battle.currentStage().DuplicateType == 9)
			{
				GameProcess.SendUIMsg(MsgUI.BattleResult, battle.currentStage());//胜利界面
			}else
			{
				GameProcess.SendUIMsg(MsgUI.BattleFailure);
			}
		} else {
			GameProcess.SendUIMsg(MsgUI.RevivePanel, respawnTotal);
		}
		//notify(MsgActor.ExitBoard);
	}
	public function getRebornTime():Int
	{
		return respawnTotal;
	}
	
	override function Notify_Respawn(userData:Dynamic):Void 
	{
		super.Notify_Respawn(userData);
		transition(ActorState.Stand);
	}
	override function Notify_Escape(userData:Dynamic):Void 
	{
		//trace("Victory Escape:"+(HXP.camera.x + HXP.width) +">>>" + x);
		//if (x >= HXP.camera.x+HXP.width){
			GameProcess.root.notify(MsgStartup.TransitionMap);
		//}else {
			//if (onWall) {
				//transition(ActorState.Jump);
			//}
			//Notify_Move(Direction.RIGHT);
		//}
	}
	override function Notify_Victory(userData:Dynamic):Void 
	{
		//trace("Notify_Victory");
		isVictory = true;
		super.Notify_Victory(userData);		
		velocity.x = 0;
		Actuate.tween(this, 2.5, { } ).onComplete(function() { 
			GameProcess.root.notify(MsgStartup.TransitionMap);
		} );
	}
	private function cmd_AddCollide(userData:Dynamic):Void 
	{
		_collides.push(userData);
	}
}