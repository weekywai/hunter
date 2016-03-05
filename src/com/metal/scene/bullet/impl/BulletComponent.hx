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
	private var _recycles:List<IBullet>;
	private var _bullets:List<IBullet>;
	public var bullets(get, null):List<IBullet>;
	private function get_bullets():List<IBullet>  { return _bullets; }
	
	public function new() 
	{
		super();
		_recycles = new List();
		_bullets = new List();
	}
	
	override function onDispose():Void 
	{
		removeBullet(_bullets);
		removeBullet(_recycles, true);
		_bullets = null;
		_recycles = null;
		super.onDispose();
	}
	
	private function removeBullet(bullets:List<IBullet>, recycle:Bool = false):Void 
	{
		//var bullet:SLLNode<IBullet> = bullets.head;
		var itr = bullets.iterator();
		var bullet:IBullet = itr.next();
		while (bullet!=null) {
			if(recycle)
				HXP.scene.clearRecycled(cast Type.getClass(bullet));
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
		//if (req.info == null)//bug
			//return;
		var bullet:IBullet = BulletFactory.instance.createBullet(req.info.behavior);
		//trace(bullet);
		//trace(_bullets.size());
		_bullets.add(bullet);
		bullet.init(owner);
		bullet.setInfo(req.info);
		bullet.start(req);
		_recycles.remove(bullet);
	}
	
	private function cmd_clearBullet(userData:Dynamic):Void
	{
		var itr = _bullets.iterator();
		var node:IBullet = itr.next();
		while (node != null) 
		{
			node.recycle();
			node = itr.next();
		}
		_bullets.clear();
	}
	private function cmd_recycle(userData:Dynamic):Void
	{
		var bullet:IBullet = userData;
		_recycles.add(bullet);
		_bullets.remove(bullet);
	}
}