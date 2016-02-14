package com.metal.scene.effect.impl;
import com.haxepunk.HXP;
import com.metal.message.MsgEffect;
import com.metal.proto.impl.EffectInfo;
import com.metal.proto.manager.EffectManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.api.IEffect;
import com.metal.scene.view.ViewDisplay;
import de.polygonal.core.sys.SimEntity;

/**
 * 特效entity
 * @author weeky
 */
class EffectEntity extends ViewDisplay implements IEffect
{
	private var _owner:SimEntity;
	
	public var info(default, null):EffectInfo;
	/** 旋转角度 */
	private var _angle:Float = 0;
	
	public var effectRequest(default, default):EffectRequest;
	
	private var _offset:Bool;
	
	public function new(x:Float, y:Float) 
	{
		super(x, y);
	}
	
	override private function onDispose():Void 
	{
		_owner = null;
		info = null;
		effectRequest = null;
		super.onDispose();
	}
	
	override public function removed():Void 
	{
		_owner = null;
		info = null;
		effectRequest = null;
		super.removed();
	}
	
	public function init(body:SimEntity, req:EffectRequest):Void
	{
		if (req == null) throw "req is null";
		effectRequest = req;
		_offset = false;
		info = EffectManager.instance.getProto(req.Key);
		_owner = body;
		onInit();
	}
	/**继承*/
	private function onInit():Void
	{
		
	}
	public function start(req:EffectRequest):Void 
	{
		x = req.x;
		y = req.y;
		_angle = req.angle;
		if (req.collide)
			validateCollide(req.attackType);
		HXP.scene.add(this);
	}
	
	override public function update():Void 
	{
		super.update();
	}
	/** 结束，循环再用 */
	private function recycle():Void {
		scene.recycle(this);
		_owner.notify(MsgEffect.Recycle, this);
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