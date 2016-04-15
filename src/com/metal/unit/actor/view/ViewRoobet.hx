package com.metal.unit.actor.view;

import com.metal.config.SfxManager;
import com.metal.message.MsgBullet;
import com.metal.scene.board.impl.GameMap;
import com.metal.unit.actor.api.ActorState.ActionType;
import spinehaxe.Bone;
import spinehaxe.Event;

/**
 * ...
 * @author li
 */
class ViewRoobet extends ViewEnemy
{
	private var _gunBone1:Bone;
	private var _gunBone2:Bone;
	
	public function new() 
	{
		super();
	}
	
	override public function onDispose():Void 
	{
		super.onDispose();
		_gunBone1 = null;
		_gunBone2 = null;
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		super.Notify_PostBoot(userData);
		
		_gunBone1 = getBone("muzzle_1");
		_gunBone2 = getBone("muzzle_2");
	}
	override private function onEventCallback(value:Int, event:Event):Void
	{
		if ( event.data.name == "attack_1") 
		{
			var gun1:Bone =  getBone("muzzle_1");
			var bulletX = x + _gunBone1.worldX;
			var bulletY = y + _gunBone1.worldY;
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = bulletX - 10;
			_bulletReq.targetY = bulletY;
			notifyParent(MsgBullet.Create, _bulletReq);
			
			var gun2:Bone =  getBone("muzzle_2");
			var bulletX = x + _gunBone2.worldX;
			var bulletY = y + _gunBone2.worldY;
			//需要检测方向
			_bulletReq.x = bulletX;
			_bulletReq.y = bulletY;
			_bulletReq.targetX = bulletX - 10;
			_bulletReq.targetY = bulletY;
			notifyParent(MsgBullet.Create, _bulletReq);
		}
	}
	override private function onStartCallback(i:Int, value:String):Void
	{
		super.onStartCallback(i, value);
		if(value == "dead_1")
			SfxManager.getAudio(AudioType.DeadMachine).play(0.5);
	}
}