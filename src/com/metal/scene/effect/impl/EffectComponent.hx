package com.metal.scene.effect.impl;

import com.haxepunk.HXP;
import com.metal.message.MsgEffect;
import com.metal.proto.impl.EffectInfo;
import com.metal.proto.manager.EffectManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.api.IEffect;
import com.metal.scene.effect.impl.EffectFactory;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;

/**
 * 子弹管理器
 * @author weeky
 */
class EffectComponent extends Component
{
	private var _recycles:List<IEffect>;
	public function new() 
	{
		super();
		_recycles = new List();
	}
	
	override function onDispose():Void 
	{
		var itr = _recycles.iterator();
		var effect:IEffect = itr.next();
		while (effect!=null) {
			HXP.scene.clearRecycled(cast Type.getClass(effect));
			effect.dispose();
			effect = itr.next();
		}
		_recycles.clear();
		_recycles = null;
		super.onDispose();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgEffect.Create:
				cmd_create(userData);
			case MsgEffect.Recycle:
				cmd_recycle(userData);
		}
		super.onUpdate(type, source, userData);
	}
	
	private function cmd_create(userData:Dynamic):Void
	{
		var req:EffectRequest = userData;
		//trace(req.boomType);
		var effect:IEffect;
		if(req.boomType == 0)
		{
			var info:EffectInfo = EffectManager.instance.getProto(req.Key);
			effect = EffectFactory.instance.createEffect(info.type);
			effect.init(owner);
			effect.start(req);
		}
		else
		{
			effect = EffectFactory.instance.createEffect(req.boomType);
			effect.init(owner);
			effect.start(req);
		}
		_recycles.remove(effect);
	}
	
	private function cmd_recycle(userData:Dynamic):Void
	{
		var effect:IEffect = userData;
		_recycles.add(effect);
	}
}