package com.metal.scene.effect.impl;
import com.haxepunk.HXP;
import com.metal.message.MsgEffect;
import com.metal.proto.impl.EffectInfo;
import com.metal.proto.manager.EffectManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.api.IEffect;
import com.metal.unit.render.ViewDisplay;
import de.polygonal.core.sys.SimEntity;

/**
 * 特效entity
 * @author weeky
 */
class EffectEntity extends ViewDisplay implements IEffect
{
	public var info(default, null):EffectInfo;
	/** 旋转角度 */
	private var _angle:Float = 0;
	
	private var _offset:Bool;
	
	public function new(x:Float, y:Float) 
	{
		super(x, y);
	}
	
	override private function onDispose():Void 
	{
		if(scene!=null)
			scene.clearRecycled(Type.getClass(this));
		info = null;
		super.onDispose();
	}
	
	override public function removed():Void 
	{
		info = null;
		super.removed();
	}
	
	override public function init(body:SimEntity):Void
	{
		_offset = false;
		super.init(body);
	}
	
	public function start(req:EffectRequest):Void 
	{
		info = EffectManager.instance.getProto(req.Key);
		x = req.x;
		y = req.y;
		_angle = req.angle;
		if (req.collide)
			validateCollide(req.attackType);
		HXP.scene.add(this);
	}
	
	/** end recycle */
	private function recycle():Void {
		if(scene!=null)
			scene.recycle(this);
		owner.notify(MsgEffect.Recycle, this);
	}
	/**
	 * 验证物体是否可攻击
	 * @param	$boardItem
	 * @return
	 */
	private function validateCollide(type:String):Void {
		_collideTypes = BoardFaction.collideType.copy();
		_collideTypes.remove(type);
		//trace(type+" : "+_collideTypes);
	}
}