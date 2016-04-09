package com.metal.unit.actor.view;
import com.metal.config.SfxManager;
import com.metal.message.MsgBullet;
import com.metal.message.MsgEffect;
import com.metal.scene.effect.api.EffectRequest;
import haxe.Timer;
import motion.Actuate;
import openfl.geom.Point;
import spinehaxe.Bone;
import spinehaxe.Event;
//import tweenx909.TweenX;

using com.metal.enums.Direction;
/**
 * ...
 * @author weeky
 */
class ViewMachine extends ViewEnemy
{
	private var _frontArmBone:Bone;
	private var _gunBone:Bone;
	private var originRarmRo:Float;
	private var r:Float = 0;
	private var _timers:Array<Dynamic>;
	
	public function new() 
	{
		super();
		_timers = [];
	}
	
	override public function onDispose():Void 
	{
		while (_timers.length > 0) {
			var t = _timers.pop();
			t.stop();
			//t.clear();
		}
		_timers = null;
		super.onDispose();
		_frontArmBone = null;
		_gunBone = null;
	}
	/*super is double effect 
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//trace("Notify_Destorying");
		super.Notify_Destorying(userData);
		if (_info.isBoom) {
			//通知处理爆炸
			var vo:EffectRequest = new EffectRequest();
			vo.setInfo(_avatar, _info.boomType+4);
			notifyParent(MsgEffect.Create, vo);
		}
		//_avatar.type = "npc";
	}*/
	
	override private function cmd_PostBoot(userData:Dynamic):Void
	{
		super.cmd_PostBoot(userData);
		_frontArmBone = _avatar.getBone("gun_1");
		_gunBone = _avatar.getBone("muzzle_1");
		originRarmRo = _frontArmBone.rotation;
		//originRarmRo = _avatar.getBoneData("gun_1").rotation;
		//var skill:SkillInfo = owner.getProperty(SkillInfo);
		//_bulletReq.info = BulletManager.instance.getInfo(skill.BulletID);
	}
	
	override function onEventCallback(value:Int, event:Event):Void 
	{
		#if debug
		//trace("event: " + value + " " +  event.data.name + ": " + event.intValue + ", " + event.floatValue + ", " + event.stringValue);
		#end
		//return;
		if ( event.data.name == "attack") 
		{
			//var gun:Bone =  _avatar.getBone("muzzle_1");
			var bulletX = _avatar.x + _gunBone.worldX;
			var bulletY = _avatar.y + _gunBone.worldY;
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = _player.x;
			_bulletReq.targetY = _player.y;
			for (i in 0..._skill.num) 
			{
				//Actuate.
				_timers.push(Timer.delay(createBullet, Std.int(_skill.interval * 1000 * i)));
				//_timers.push(TweenX.tweenFunc(createBullet,[],[],0).delay(_skill.interval * i));
			}
		}
	}
	private function createBullet()
	{
		notifyParent(MsgBullet.Create, _bulletReq);
		_timers.shift();
	}
	
	override public function onDraw() 
	{
		super.onDraw();
		/*if(_attcking)
		{
			//D点
			_targetPos.x = _player.x;
			_targetPos.y = _player.y;
			
			if (_avatar.distanceToPoint(_targetPos.x, _targetPos.y) > 100){
				//setHeadRotation(_targetPos, _actor.dir);
				setGunRoatation(_targetPos, _actor.dir);
			}else {
				//_headBone.data.rotation = originHeadRo;
				_frontArmBone.data.rotation = originRarmRo;
			}
		}
		else
		{
			//_headBone.data.rotation = originHeadRo;
			_frontArmBone.data.rotation = originRarmRo;
		}*/
	}
	//设置头部旋转角度
	//private function setHeadRotation(pos:Point, dir:Direction):Void
	//{
		//var ro:Float = 0;
		//var headPos:Point = new Point();
		//#if cpp
		//if (!Math.isNaN(_headBone.worldX) && !Math.isNaN(_headBone.worldY))
		//#else
		//if (_headBone.worldX !=null && _headBone.worldY!=null)
		//#end
		//{
			//headPos.x = _headBone.worldX + _avatar.x;
			//headPos.y = _headBone.worldY + _avatar.y;	
			//
			//var len:Point = new Point();
			//len.x = headPos.x - pos.x;
			//len.y =  headPos.y - pos.y;
			//
			//var angle:Float;
			//if (len.x == 0)
				//angle = 90;
			//else
				//angle = Math.atan2(len.y, len.x);
			//if (dir == Direction.RIGHT)
				//ro = 180 - angle * (180 / Math.PI);
			//else if(dir == Direction.LEFT)
				//ro = angle * (180 / Math.PI);
			//_avatar.getBoneData("head").rotation = ro;
		//}
	//}
	
	private function setGunRoatation(mousePos:Point, dir:Direction):Void
	{
		//C点
		var gunPos:Point = new Point();
		gunPos.x = _gunBone.worldX + _avatar.x;
		gunPos.y = _gunBone.worldY + _avatar.y;	
		
		//A点
		var armPos:Point = new Point();
		armPos.x = _frontArmBone.worldX + _avatar.x;
		armPos.y = _frontArmBone.worldY + _avatar.y;
			
		//AD距离
		var rAD:Float = Math.sqrt((mousePos.x - armPos.x) * (mousePos.x - armPos.x) + (mousePos.y - armPos.y) * (mousePos.y - armPos.y));
		//OAC
		//var a:Float = Math.atan2((gunPos.x - armPos.x), (armPos.y - gunPos.y));
		//OAD
		var b:Float = 0;
		if (mousePos.y < armPos.y)
		{
			if(dir == Direction.RIGHT)
				b = 180 - Math.atan((mousePos.x - armPos.x) / (armPos.y - mousePos.y)) * 180 / Math.PI;
			else if(dir == Direction.LEFT)
				b = 180 - Math.atan((armPos.x - mousePos.x) / (armPos.y - mousePos.y)) * 180 / Math.PI;
		}
		else if (mousePos.y == armPos.y)
			b = 90;
		else
		{
			if(dir == Direction.RIGHT)
				b = Math.atan((mousePos.x - armPos.x) / (mousePos.y - armPos.y)) * 180 / Math.PI;
			else if(dir == Direction.LEFT)
				b = Math.atan((armPos.x - mousePos.x) / (mousePos.y - armPos.y)) * 180 / Math.PI;
		}
		//C'AD
		var c:Float = Math.acos(r / rAD) * 180/Math.PI;
		
		var angle:Float;
		if(mousePos.y < armPos.y - r)
		{
			angle = b - c;
			_avatar.getBoneData("gun_1").rotation = originRarmRo + angle;
			//_avatar.getBoneData("gun_1").rotation = originLarmRo + angle;	
		}
		else
		{
			angle = c - b;
			_avatar.getBoneData("gun_1").rotation = originRarmRo - angle;
			//_avatar.getBoneData("gun_1").rotation = originLarmRo - angle;
		}
	}
	override private function onStartCallback(i:Int, value:String):Void
	{
		super.onStartCallback(i, value);
		if(value == "dead_1")
			SfxManager.getAudio(AudioType.DeadMachine).play(0.5);
	}
}