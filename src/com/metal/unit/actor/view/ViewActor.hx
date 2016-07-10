package com.metal.unit.actor.view;
import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.metal.config.ResPath;
import com.metal.config.UnitModelType;
import com.metal.enums.Direction;
import com.metal.manager.ResourceManager;
import com.metal.unit.avatar.AttachSpine;
import flash.geom.Rectangle;
import openfl.geom.Point;
import spinehaxe.Bone;
import spinehaxe.BoneData;
import spinehaxe.SkeletonData;
import spinehaxe.animation.Animation;
import spinehaxe.animation.AnimationState;
import spinepunk.SpinePunk;

/**
 * ...
 * @author weeky
 */
class ViewActor extends ViewBase
{
	private var _spine:AttachSpine;
	
	public var useHitBox:Bool = false;
	public var fly:Bool = false;
	
	#if debug
	/**瞄准点视图*/
	private var aimPointView:Entity;
	#end
	//瞄准间补
	private var aimPoint:Point;
	private var targetAimPoint:Point;
	private var aimHeight:Float = 0;
	private var aimAdjustY:Float = 20;
	private var rotationAdjust:Float = 5;
	private var _onAim:Bool;
	
	public function new() 
	{
		super();
	}
	
	override public function onInit():Void 
	{
		super.onInit();
		targetAimPoint = new Point();		
		aimPoint = new Point();
		_onAim = false;
#if debug
		aimPointView = new Entity(targetAimPoint.x, targetAimPoint.y, Image.createCircle(4, 0xffffff, 1));
		HXP.scene.add(aimPointView);		
#end
	}
	
	override public function onDispose():Void 
	{
		targetAimPoint = null;
		aimPoint = null;
		_spine = null;
	#if debug
		HXP.scene.remove(aimPointView);
		aimPointView = null;
	#end
		super.onDispose();
	}
	
	override private function createAvatar(name:String, type:String):Dynamic
	{
		var path = ResPath.getModelRoot(type, _info.res);
		var skeletonData:SkeletonData = SpinePunk.readSkeletonData(name, path, 1, _info.skin);
		//trace(name + skeletonData.name);
		var skeleton:AttachSpine = cast ResourceManager.instance.getResource(path);
		if (skeleton==null)
			skeleton = new AttachSpine(skeletonData);
		
		skeleton.scale = _info.scale;
		skeleton.flipX = (_info.flip == 0)?false:true;
		if(_info.fly==4){
			var aircraft = new Image("model/unit/a002/a002.png");
			aircraft.x = -aircraft.width * 0.5;
			aircraft.y = -10;
			addGraphic(aircraft);
		}
		addGraphic(skeleton);
		//trace(_info.ID + " " +  _info.flip);
		
		//暂时取消mask碰撞检测
		//if (skeleton.useMask){
			//mask = skeleton.mask;
		//}else {
			setHitboxTo(skeleton.mainHitbox);
		//}
		return skeleton;
	}

	override public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void {
		//trace("setToSetupPose: " + action);
		_model.setDirAction(action, dir, loop);
	}
	
	override public function update():Void {
		if (isDisposed || _isFree)
			return;
		if (_model != null) {
			//_spine.update();
			_spine.active = onCamera;
			//_model.color = _colorT.color;
		}
		/*
		if (_skeleton.useMask) {
			useHitBox = false;
			mask = _skeleton.mask;
		}else {
			useHitBox = true;
			setHitboxTo(_skeleton.mainHitbox);
		}
		*/
		
		super.update();
	}
	
	override private function preload():Void
	{
		switch(type){
			case UnitModelType.Player:
				_model = createAvatar("model", type);
			default:
				_model = createAvatar("model", UnitModelType.Unit);
		}
		_spine = _model.as(AttachSpine);
		changeColor();
	}
	
	override private function get_flip():Bool  { return _model.flip; }
	override private function set_flip(value:Bool):Bool
	{
		if (value)
			_model.flip = (_info.flip == 0)?true:false;
		else
			_model.flip = (_info.flip == 0)?false:true;
		return _model.flip;
	}
	
	
	public function getScale():Float
	{
		return _info.scale;
	}
	
	public function getGunPoint(name:String):Point
	{
		var p = new Point();
		var gun =getBone(name);
		p.x = x + gun.worldX * _info.scale;
		p.y = y + gun.worldY * _info.scale;
		return p;
	}
	
	public function getBone(name:String):Bone
	{
		return _spine.skeleton.findBone(name);
	}
	/** modify slotData to set attachment */
	public function setAttachMent(slotName:String, attachName:String):Void
	{
		_spine.setAttachMent(slotName, attachName);
	}
	
	public function getBoneData(name:String):BoneData
	{
		return _spine.getBoneData(name);
	}
	
	public function animationState():AnimationState
	{
		return _spine.state;
	}
	public function getAnimation(name:String):Animation 
	{
		return _spine.getAnimation(name);
	}
	public function setGunHitbox(name:String):Void 
	{
		_spine.weaponHitslot = name;
	}
	public function getGunHitbox():Rectangle 
	{
		return _spine.weaponBox;
	}
	
	override public function setCallback(fun:Dynamic)
	{
		_model.initAttach(fun);
	}
	
	function setAimPointWithoutTween()
	{
		aimPoint.x = targetAimPoint.x;
		aimPoint.y = targetAimPoint.y;
#if debug
		aimPointView.x = aimPoint.x;
		aimPointView.y = aimPoint.y;
#end
	}
	
	function setDefaultAimPoint(withoutTween:Bool=false)
	{
		if (_actor.halfHeight!=0 && aimHeight==0) 
		{
			aimHeight = _actor.halfHeight * 1.2;
		}
		
		targetAimPoint.x = _actor.x + ((_actor.dir == Direction.RIGHT)?1: -1) * 400;
		targetAimPoint.y = _actor.y - aimHeight;
		if (withoutTween) 
			setAimPointWithoutTween();
	}
	
	/**从from向to（递增/递减），单次增量为space*/
	private function complement(from:Float,to:Float,space:Float,rotate:Bool=false):Float
	{
		if (from == to) return from; 
		if (rotate) 
		{
			if (to - from > 180 ) {
				//trace("to - from > 180 : " + from);
				from += 360;
				
			}else if (from - to > 180 ) {
				//trace("(from - to > 180 ): " + from);
				from -= 360;
			}
		}
		if (from<to) 
		{
			from += space;
			if (from > to) from = to;
		}else if (from>to) 
		{
			from -= space;
			if (from < to) from = to;
		}
		return from;
	}
}