package com.metal.unit.actor.view;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgBullet;
import com.metal.proto.manager.BulletManager;
import com.metal.proto.manager.SkillManager;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.view.ViewEnemy;
import haxe.ds.IntMap;
import spinehaxe.Bone;
import spinehaxe.Event;

/**
 * 精英怪 通用
 * @author 
 */
class ViewBoss extends ViewEnemy
{
	private var _gunBoneMap:IntMap<Bone>;
	private var _skillType:Int;
	
	public function new() 
	{
		super();
		_skillType = 0;
	}
	override public function onDispose():Void 
	{
		super.onDispose();
		//_gunBone1 = null;
		_gunBoneMap = null;
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		super.Notify_PostBoot(userData);
		_gunBoneMap =  new IntMap();
		//_gunBone2 = getBone("muzzle_2");
		for (i in 1...8)
		{
			if (getBone("muzzle_1") != null)
			{
				_gunBoneMap.set(i, getBone("muzzle_" + i));
			}
		}
		//_gunBone3 = getBone("muzzle_3");
		_actor.isNeedRightFlip = false;
		//type = "solid";
	}
	
	override function Notify_Skill(userData:Dynamic):Void 
	{
		super.Notify_Skill(userData);
		_skillType = userData;
		//trace("_skillType " + _skillType);
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		//trace("action " + action);
		if (_curAction == action) 
			return;
		//trace("after action " + action);
		if (_actor.isRunMap)
		{
			if (action == ActionType.idle_1)
				action = ActionType.walk_1;
				//trace(Std.string(action));W
			if (Std.string(action).indexOf("attack") != -1) {
				
				//action = ActionType.attack_walk;
			}
		}
		_curAction = action;
		var action1:ActionType;
		if (_actor.stateID == ActorState.Skill)
		{
			switch(_skillType)
			{
				case 0: action1 = ActionType.attack_1;
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
		//super.setAction(action, loop);
	}
	
	override function onEventCallback(value:Int, event:Event):Void 
	{
		var bulletX = 0.0 ;
		var bulletY = 0.0;
		var index:Int = 0;
		switch(event.data.name)
		{
			case "attack_1":
				bulletX = x + _gunBoneMap.get(1).worldX;
				bulletY = y + _gunBoneMap.get(1).worldY;
				index = 1;
			case "attack_2":
				bulletX = x + _gunBoneMap.get(2).worldX;
				bulletY = y + _gunBoneMap.get(2).worldY;
				index = 2;
			case "attack_3":
				bulletX = x + _gunBoneMap.get(3).worldX;
				bulletY = y + _gunBoneMap.get(3).worldY;
				index = 3;
			case "attack_4":
				bulletX = x + _gunBoneMap.get(4).worldX;
				bulletY = y + _gunBoneMap.get(4).worldY;
				index = 4;
			case "attack_5":
				bulletX = x + _gunBoneMap.get(5).worldX;
				bulletY = y + _gunBoneMap.get(5).worldY;
				index = 5;
			case "attack_6":
				bulletX = x + _gunBoneMap.get(6).worldX;
				bulletY = y + _gunBoneMap.get(6).worldY;
				index = 6;
			case "attack_7":
				
		}
		//需要检测方向
		_bulletReq.x = bulletX;
		_bulletReq.y = bulletY;
		_bulletReq.targetX = _player.x;
		_bulletReq.targetY = _player.y;
		_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[index-1]).BulletID);
		notifyParent(MsgBullet.Create, _bulletReq);
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