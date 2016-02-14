package com.metal.unit.actor.view;
import com.haxepunk.graphics.Image;
import com.metal.config.SfxManager;
import com.metal.enums.Direction;
import com.metal.message.MsgBullet;
import com.metal.scene.board.impl.BattleResolver;
import haxe.Timer;
import motion.Actuate;
import spinehaxe.Bone;
import spinehaxe.Event;
//import tweenx909.TweenX;

/**
 * ...
 * @author li
 */
class ViewMonster extends ViewEnemy
{
	private var _gunBone1:Bone;
	private var _aircraft:Image;
	private var _timers:Array<Dynamic>;
	public function new() 
	{
		super();
		_timers = [];
	}
	
	override public function onDispose():Void 
	{
		_gunBone1 = null;
		while (_timers.length > 0) {
			var t = _timers.pop();
			t.stop();
			//t.clear();
		}
		_timers = null;
		super.onDispose();
	}
	
	override private function cmd_PostBoot(userData:Dynamic):Void
	{
		super.cmd_PostBoot(userData);
		_gunBone1 = _avatar.getBone("muzzle_1");
	}
	
	override private function onEventCallback(value:Int, event:Event):Void
	{
		super.onEventCallback(value,event);
		if (_weapon != null)
			_meleeHit = false;
		if (_gunBone1 == null || _bulletReq.info==null)
			return;
		if ( event.data.name == "attack") 
		{
			
			var gun1:Bone =  _avatar.getBone("muzzle_1");
			var bulletX = _avatar.x + _gunBone1.worldX;
			var bulletY = _avatar.y + _gunBone1.worldY;
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			//_bulletReq.targetX = _player.x;// bulletX - 10;
			_bulletReq.targetX = ((_actor.dir == Direction.LEFT)?-1:1)*1000+_avatar.x ;// 只判断方向
			_bulletReq.targetY = bulletY;
			_bulletReq.renderType = BattleResolver.resolveAtk(_bulletReq.critPor);
			if (bulletX > _bulletReq.targetX)
				_bulletReq.dir = Direction.LEFT;
			else
				_bulletReq.dir = Direction.RIGHT;
		
			if (_weapon == null) {
				for (i in 0..._skill.num) 
				{
					_timers.push(Timer.delay(createBullet, Std.int(_skill.interval * 1000 * i)));
					//_timers.push(TweenX.tweenFunc(createBullet,[],[],0).delay(_skill.interval * i));
				}
			}
		}
	}
	private function createBullet()
	{
		notifyParent(MsgBullet.Create, _bulletReq);
		if (_timers!=null) _timers.shift();
		
	}
	
	override private function onStartCallback(i:Int, value:String):Void
	{
		super.onStartCallback(i, value);
		if(value == "dead_1")
			SfxManager.getAudio(AudioType.DeadHuman).play(0.5);
	}
}