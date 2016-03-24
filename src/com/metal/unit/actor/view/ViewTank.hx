package com.metal.unit.actor.view;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgBullet;
import com.metal.proto.manager.BulletManager;
import com.metal.proto.manager.SkillManager;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import spinehaxe.Bone;
import spinehaxe.Event;

/**
 * 坦克
 * @author li
 */
class ViewTank extends ViewEnemy
{
	private var _gunBone1:Bone;
	private var _gunBone2:Bone;
	private var _gunBone3:Bone;
	private var _skillType:Int;
	public function new() 
	{
		super();
	}
	override public function onDispose():Void 
	{
		super.onDispose();
		_gunBone1 = null;
		_gunBone2 = null;
		_gunBone3 = null;
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		super.Notify_PostBoot(userData);
		_gunBone1 = getBone("muzzle_1");
		_gunBone2 = getBone("muzzle_2");
		_gunBone3 = getBone("muzzle_3");
		
	}
	
	override function Notify_Skill(userData:Dynamic):Void 
	{
		super.Notify_Skill(userData);
		_skillType = userData;
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		if (_curAction == action) 
			return;
		if (_actor.isRunMap)
		{
			if (action == ActionType.idle_1)
				action = ActionType.walk_1;
				//trace(Std.string(action));
			if (Std.string(action).indexOf("attack") != -1) {
				
				//action = ActionType.attack_walk;
			}
		}
		//trace("after action " + action);
		_curAction = action;
		var action1:ActionType;
		if (_actor.stateID == ActorState.Skill)
		{
			
			switch(_skillType)
			{
				case 0: action1 = ActionType.attack_1;
				case 1: action1 = ActionType.attack_2;
				case 2: action1 = ActionType.attack_3;
				default: action1 = ActionType.attack_1;
			}
			//trace(_info.Skill[_skillType]);
			if (_mInfo.Skill[_skillType] == -1)
				action1 = ActionType.attack_1;
		}
		else
		{
			action1 = action;
		}
		setDirAction(Std.string(action1), Direction.NONE);
	}
	
	override function onEventCallback(value:Int, event:Event):Void
	{
		if ( event.data.name == "attack_1") 
		{
			//trace(getScale());
			var bulletX = x + _gunBone1.worldX *(getScale()-0.1);
			var bulletY = y + _gunBone1.worldY * (getScale() - 0.1);
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = _player.x;
			_bulletReq.targetY = _player.y;
			_bulletReq.bulletAngle = _gunBone1.worldRotation;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[0]).BulletID);
			//notifyParent(MsgBullet.Create, _bulletReq);
			notifyParent(MsgBullet.Create, _bulletReq);
		}else if (event.data.name == "attack_2")
		{
			var bulletX = x + _gunBone2.worldX;
			var bulletY = y + _gunBone2.worldY;
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = _player.x;
			_bulletReq.targetY = _player.y;
			_bulletReq.bulletAngle = _gunBone2.worldRotation;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[1]).BulletID);
			//notifyParent(MsgBullet.Create, _bulletReq);
			notifyParent(MsgBullet.Create, _bulletReq);
		}else if (event.data.name == "attack_3")
		{
			var bulletX = x + _gunBone3.worldX;
			var bulletY = y + _gunBone3.worldY;
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = _player.x;
			_bulletReq.targetY = _player.y;
			_bulletReq.bulletAngle = _gunBone3.worldRotation;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[2]).BulletID);
			//notifyParent(MsgBullet.Create, _bulletReq);
			notifyParent(MsgBullet.Create, _bulletReq);
		}
	}
	override private function onStartCallback(i:Int, value:Dynamic):Void
	{
		//trace("on start " + value);
		var v:String = cast(value, String);
		if (v == "attack_1" || v == "attack_2" || v == "attack_3")
		{
			notify(MsgActor.AttackStatus, true);
		}
		
	}
	
	override private function onCompleteCallback(count:Int, value:String):Void
	{
		//trace("on complete "  + value);
		if (value == "attack_1" || value == "attack_2" || value == "attack_3")
		{
			notify(MsgActor.AttackStatus, false);
		}
	}
}