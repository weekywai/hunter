package com.metal.unit.actor.view.boss;
import com.metal.enums.Direction;
import com.metal.message.MsgBullet;
import com.metal.message.MsgEffect;
import com.metal.proto.manager.BulletManager;
import com.metal.proto.manager.SkillManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.view.ViewEnemy;
import com.metal.unit.ai.MonsterAI;
import spinehaxe.Bone;
import spinehaxe.Event;

/**
 * boss
 * @author weeky
 */
class ViewBoss2 extends ViewEnemy
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
	
	override private function cmd_PostBoot(userData:Dynamic):Void
	{
		super.cmd_PostBoot(userData);
		_gunBone1 = _avatar.getBone("muzzle_1");
		_gunBone2 = _avatar.getBone("muzzle_2");
		_gunBone3 = _avatar.getBone("muzzle_3");
		
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
		_avatar.setDirAction(Std.string(action1), Direction.NONE);
		//super.setAction(action, loop);
	}
	
	override function onEventCallback(value:Int, event:Event):Void 
	{
		if ( event.data.name == "attack_1") 
		{
			//var gun1:Bone =  _avatar.getBone("muzzle_1");
			var bulletX = _avatar.x + _gunBone1.worldX;
			var bulletY = _avatar.y + _gunBone1.worldY;
			//需要检测方向
			_bulletReq.x = bulletX-100;
			_bulletReq.y = bulletY+10;
			_bulletReq.targetX = _player.x-150;
			_bulletReq.targetY = _player.y;
			//_bulletReq.targetX = bulletX - 10;
			//_bulletReq.targetY = bulletY;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_info.Skill[0]).BulletID);
			notifyParent(MsgBullet.Create, _bulletReq);
		}
		else if (event.data.name == "attack_2")
		{
			//var gun2:Bone =  _avatar.getBone("muzzle_2");
			var bulletX = _avatar.x + _gunBone2.worldX;
			var bulletY = _avatar.y + _gunBone2.worldY;
			//需要检测方向 修正值
			_bulletReq.x = bulletX -70;
			_bulletReq.y = bulletY +80;
			_bulletReq.targetX = _player.x-20;
			_bulletReq.targetY =  _player.y-20;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_info.Skill[1]).BulletID);
			//trace(SkillManager.instance.getInfo(_info.Skill[1]).BulletID);
			notifyParent(MsgBullet.Create, _bulletReq);
		}
		else if (event.data.name == "attack_3")
		{
			var bulletX = _avatar.x + _gunBone3.worldX;
			var bulletY = _avatar.y + _gunBone3.worldY;
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = _player.x-50;
			_bulletReq.targetY = _player.y;
			//_bulletReq.targetX = bulletX - 10;
			//_bulletReq.targetY = bulletY;
			_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_info.Skill[2]).BulletID);
			notifyParent(MsgBullet.Create, _bulletReq);
		}
	}
	
	override private function onStartCallback(i:Int, value:Dynamic):Void
	{
		//trace("on start " + value);
		var v:String = cast(value, String);
		if (v == "attack_1" || v == "attack_2" || v == "attack_3")
		{
			cast(owner.getComponent(MonsterAI), MonsterAI).setAttackStatus(true);
		}
		
	}
	
	override private function onCompleteCallback(count:Int, value:String):Void
	{
		//trace("on complete "  + value);
		if (value == "attack_1" || value == "attack_2" || value == "attack_3")
		{
			cast(owner.getComponent(MonsterAI), MonsterAI).setAttackStatus(false);
		}
	}
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//super.Notify_Destorying(userData);
		_avatar.type = "";
		if (_info.isBoom) {
			//通知处理爆炸
			var vo:EffectRequest = new EffectRequest();
			vo.setInfo(this._avatar, _info.boomType+4);
			//vo.scale = 
			notifyParent(MsgEffect.Create, vo);
		}
	}
	
}