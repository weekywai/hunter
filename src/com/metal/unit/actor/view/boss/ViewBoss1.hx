package com.metal.unit.actor.view.boss;

import com.haxepunk.HXP;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.enums.Direction;
import com.metal.message.MsgActor;
import com.metal.message.MsgBullet;
import com.metal.message.MsgEffect;
import com.metal.proto.manager.BulletManager;
import com.metal.proto.manager.SkillManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.view.ViewEnemy;
import spinehaxe.Bone;
import spinehaxe.Event;

/**
 * b031 飞机
 * @author li
 */
class ViewBoss1 extends ViewEnemy
{
	private var _skillType:Int;
	private var _skill2Count:Int;
	private var _time:Int;
	private var _pos:Bool;
	
	private var _lfire:TextrueSpritemap;
	private var _rfire:TextrueSpritemap;
	
	public function new() 
	{
		super();
		_skillType = 0;
		_skill2Count = 0;
		_time = 0;
		_pos = false;
	}
	override public function onDispose():Void 
	{
		super.onDispose();
		_skillType = 0;
		_skill2Count = 0;
		_time = 0;
		_pos = false;
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		super.Notify_PostBoot(userData);
		_actor.isNeedRightFlip = false;
		createFire();
	}
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//super.Notify_Destorying(userData); 
		type = "";
		if (_mInfo.isBoom) {
			//通知处理爆炸
			var vo:EffectRequest = new EffectRequest();
			vo.setInfo(this, _mInfo.boomType+4);
			notifyParent(MsgEffect.Create, vo);
		}
	}
	override function Notify_Skill(userData:Dynamic):Void 
	{
		super.Notify_Skill(userData);
		_skillType = userData;
		//trace("_skillType " + _skillType);
	}
	
	override public function update() 
	{
		super.update();
		var m1 = getBone("muzzle_1");
		var m2 = getBone("muzzle_2");
		_lfire.x = m1.worldX - 100;
		_lfire.y = m1.worldY + 105;
		_rfire.x = m2.worldX + 450;
		_rfire.y = m2.worldY + 120;
		
		if (_skillType == 2)
		{
			if (_pos)
			{
				if(_time < 180)
					_actor.velocity.x = 80;
				else
					_actor.velocity.x = -80;
				_time++;
			}
			else
			{
				if(_time < 180)
					_actor.velocity.x = -80;
				else
					_actor.velocity.x = 80;
				_time++;
			}
		}
		else
		{
			_time = 0;
		}
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		//trace("action " + action);
		if (_curAction == action) 
			return;
		//trace("after action " + action);
		_curAction = action;
		var action1:ActionType;
		switch(_actor.stateID){
			case ActorState.Skill:
				switch(_skillType)
				{
					case 0: action1 = ActionType.attack_1;
					case 1: action1 = ActionType.attack_2;
					case 2: action1 = ActionType.attack_3;
							if (x <= _player.x)
								_pos = true;
							else
								_pos = false;
					default: action1 = ActionType.attack_1;
				}
			case ActorState.Enter:
				action1 = (_actor.faction == BoardFaction.Boss1)?ActionType.walk_1:action;
			default:
				action1 = action;
		}
		setDirAction(Std.string(action1), Direction.NONE);
		//super.setAction(action, loop);
	}
	
	override function onEventCallback(value:Int, event:Event):Void 
	{
		//trace(event.data.name);
		switch(event.data.name) {
			case "attack_1":
				fireBullet(1);
			case "attack_2":
				fireBullet(2);
			case "attack_3":
				fireBullet(3);
			case "attack_4":
				fireBullet(4);
			case "attack_5":
				fireBullet(5);
			case "attack_6":
				fireBullet(6);
			case "attack_7":
				fireBullet(7);
		}
	}
	
	private function fireBullet(index:Int):Void
	{
		var gun:Bone =  getBone("muzzle_" + index);
		var bulletX = x + gun.worldX;
		var bulletY = y + gun.worldY;
		//需要检测方向 修正值
		_bulletReq.x = bulletX;
		_bulletReq.y = bulletY-100;
		var dis:Float = 0;
		if (index == 3)
		{
			if (_skill2Count % 2 == 0)
			{
				dis = -100 * (_skill2Count / 2 + 1);
			}
			else
			{
				dis = 100 * (_skill2Count / 2 + 1);
			}
			_skill2Count++;
			if (_skill2Count == 6)
			{
				_skill2Count = 0;
			}
			_bulletReq.targetX = _actor.x + dis;
			_bulletReq.targetY = HXP.height - HXP.camera.y;
		}
		else
		{
			if (index == 5)
			{
				_bulletReq.x = x + gun.worldX - _lfire.width * 0.55;
			}
			if (index == 6)
			{
				_bulletReq.x = x + gun.worldX - _rfire.width * 2.25;
			}
			_bulletReq.targetX = _player.x;
			_bulletReq.targetY = _player.y;
		}
		_bulletReq.info = BulletManager.instance.getInfo(SkillManager.instance.getInfo(_mInfo.Skill[index - 1]).BulletID);
		notifyParent(MsgBullet.Create, _bulletReq);
	}
	
	override private function onStartCallback(i:Int, value:String):Void
	{
		if (value.indexOf("attack")!=-1)
		{
			notify(MsgActor.AttackStatus, true);
		}
		if (value == "dead_1") {
			removeGraphic(_lfire);
			removeGraphic(_rfire);
			SfxManager.getAudio(AudioType.DeadBoss).play(0.5);
		}
	}
	
	override private function onCompleteCallback(count:Int, value:String):Void
	{
		//trace("on complete "  + value);
		if (value.indexOf("attack")!=-1)
		{
			notify(MsgActor.AttackStatus, false);
		}
	}
	
	private function createFire():Void
	{
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes("Q117.xml"));
		_lfire = new TextrueSpritemap(eff);
		_lfire.add("_lfire", eff.getReginCount(), 25);
		//_fireStart.animationEnd.add(onStartComplete);
		_lfire.centerOrigin();
		addGraphic(_lfire);
		_lfire.play("_lfire");
		_lfire.scale = 1.4;
		_lfire.angle = -6;
		
		_rfire = new TextrueSpritemap(eff);
		_rfire.add("_rfire", eff.getReginCount(), 25);
		//_fireStart.animationEnd.add(onStartComplete);
		_rfire.centerOrigin();
		addGraphic(_rfire);
		_rfire.play("_rfire");
		_rfire.scale = 1.4;
		_rfire.angle = 6;
	}
	
}