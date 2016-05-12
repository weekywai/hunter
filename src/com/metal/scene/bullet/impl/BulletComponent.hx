package com.metal.scene.bullet.impl;

import com.haxepunk.HXP;
import com.metal.message.MsgBullet;
import com.metal.message.MsgStartup;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.api.IBullet;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;

/**
 * 子弹管理器
 * @author weeky
 */
class BulletComponent extends Component
{
	public var bullets(default, null):List<IBullet>;
	
	public function new() 
	{
		super();
		bullets = new List();
	}
	
	override function onDispose():Void 
	{
		//trace("onDispose");
		removeBullet(bullets);
		bullets = null;
		super.onDispose();
	}
	
	private function removeBullet(bullets:List<IBullet>, recycle:Bool = false):Void 
	{
		var itr = bullets.iterator();
		var bullet:IBullet = itr.next();
		while (bullet!=null) {
			//if(recycle)
				//HXP.scene.clearRecycled(cast Type.getClass(bullet));
			bullet.dispose();
			bullet = itr.next();
		}
		bullets.clear();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgBullet.Create:
				cmd_create(userData);
			case MsgBullet.Recycle:
				cmd_recycle(userData);
			case MsgBullet.Clear, MsgStartup.TransitionMap:
				cmd_clearBullet(userData);
		}
		super.onUpdate(type, source, userData);
	}
	
	private function cmd_create(userData:Dynamic):Void
	{
		var req:BulletRequest = userData;
		//trace(req.info);
		//if (req.info == null)//bug
			//return;
		var bullet:IBullet = BulletFactory.instance.createBullet(req.info.effectType);
		//trace(bullet);
		//trace(bullets.size());
		bullets.add(bullet);
		bullet.init(owner);
		bullet.setInfo(req.info);
		bullet.removeCall.addOnce(cmd_recycle);
		bullet.start(req);
	}
	
	private function cmd_clearBullet(userData:Dynamic):Void
	{
		var itr = bullets.iterator();
		var node:IBullet = itr.next();
		while (node != null) 
		{
			node.recycle();
			node = itr.next();
		}
		bullets.clear();
	}
	private function cmd_recycle(userData:Dynamic):Void
	{
		var bullet:IBullet = userData;
		var r = bullets.remove(bullet);
		//trace("cmd_recycle "+ r);
	}
}