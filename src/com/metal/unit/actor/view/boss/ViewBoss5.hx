package com.metal.unit.actor.view.boss;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgBullet;
import com.metal.message.MsgEffect;
import com.metal.proto.manager.BulletManager;
import com.metal.proto.manager.SkillManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.view.ViewEnemy;
import spinehaxe.Bone;
import spinehaxe.Event;

/**
 * 四脚有轮BOSS
 * @author hyg
 */
class ViewBoss5 extends ViewEnemy
{
	private var _gunBone1:Bone;
	private var _gunBone2:Bone;
	private var _gunBone3:Bone;
	private var _skillType:Int;
	
	public function new() 
	{
		super();
		_skillType = 0;
	}
	override public function onDispose():Void 
	{
		super.onDispose();
		_gunBone1 = null;
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		super.Notify_PostBoot(userData);
		_gunBone1 = getBone("muzzle_1");
		_gunBone2 = getBone("muzzle_2");
		_gunBone3 = getBone("muzzle_3");
		
		_actor.isNeedRightFlip = false;
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
		}
		else
		{
			action1 = action;
		}
		if(Std.string(action1)!="walk_1")setDirAction(Std.string(action1), Direction.NONE);
		//super.setAction(action, loop);
	}
	
	override function onEventCallback(value:Int, event:Event):Void 
	{
		if ( event.data.name == "attack_1") 
		{
			//var gun1:Bone =  getBone("muzzle_1");
			var bulletX = x + _gunBone1.worldX;
			var bulletY = y + _gunBone1.worldY;
			//需要检测方向
			_bulletReq.x = bulletX-50;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = _player.x-180;
			_bulletReq.targetY = _player.y-50;
			//_bulletReq.targetX = bulletX - 10;
			//_bulletReq.targetY = bulletY;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[0]).BulletID);
			//trace(SkillManager.instance.getInfo(_info.Skill[0]).BulletID+"=======" + _bulletReq.info.speed);
			notifyParent(MsgBullet.Create, _bulletReq);
		}
		else if (event.data.name == "attack_2")
		{
			//var gun2:Bone =  getBone("muzzle_2");
			var bulletX = x + _gunBone2.worldX;
			var bulletY = y + _gunBone2.worldY;
			//需要检测方向 修正值
			_bulletReq.x = bulletX -80;
			_bulletReq.y = bulletY +90;
			_bulletReq.targetX = _player.x;
			_bulletReq.targetY =  _player.y;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[1]).BulletID);
			//trace(SkillManager.instance.getInfo(_info.Skill[1]).BulletID);
			notifyParent(MsgBullet.Create, _bulletReq);
		}
		else if (event.data.name == "attack_3")
		{
			var bulletX = x + _gunBone3.worldX;
			var bulletY = y + _gunBone3.worldY;
			//需要检测方向
			_bulletReq.x = bulletX ;
			_bulletReq.y = bulletY +20;
			_bulletReq.targetX = _player.x-10;
			_bulletReq.targetY = _player.y;
			//_bulletReq.targetX = bulletX - 10;
			//_bulletReq.targetY = bulletY;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[2]).BulletID);
			notifyParent(MsgBullet.Create, _bulletReq);
		}else if (event.data.name == "effect")//特殊攻击前特效
		{
			
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
		if (value == "attack_1" || value == "attack_2" || value == "attack_3" )
		{
			notify(MsgActor.AttackStatus, false);
		}
	}
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//super.Notify_Destorying(userData);
		type = "";
		if (_mInfo.isBoom) {
			//通知处理爆炸
			var vo:EffectRequest = new EffectRequest();
			vo.setInfo(this, _mInfo.boomType+4);
			//vo.scale = 
			notifyParent(MsgEffect.Create, vo);
		}
	}
	
}