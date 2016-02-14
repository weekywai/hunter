package com.metal.unit.avatar;

import com.haxepunk.graphics.Image;
import com.haxepunk.Tween.TweenType;
import com.haxepunk.tweens.misc.ColorTween;
import com.haxepunk.tweens.TweenEvent;
import com.metal.config.ResPath;
import com.metal.config.UnitModelType;
import com.metal.enums.Direction;
import com.metal.manager.ResourceManager;
import com.metal.unit.actor.api.ActorState.ActionType;
import openfl.geom.Rectangle;
import pgr.dconsole.DC;
import spinehaxe.animation.Animation;
import spinehaxe.animation.AnimationState;
import spinehaxe.Bone;
import spinehaxe.BoneData;
import spinehaxe.SkeletonData;
import spinepunk.SpinePunk;

/**
 * MAvatar
 * @author weeky
 */
class MTAvatar extends AbstractAvatar
{
	
	private var _skeleton:SpinePunk;
	//public var skeleton(get, null):SpinePunk;
	
	private var _color:Int;
	private var _colorT:ColorTween;
	public var useHitBox:Bool = false;
	public var fly:Bool = false;
	
	public function new(x:Float = 0, y:Float = 0) 
	{
		super(x, y);
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
		_skeleton.state.onEvent.listeners = [];
		_skeleton.state.onStart.listeners = [];
		_skeleton.state.onComplete.listeners = [];
		_skeleton.state.onEnd.listeners = [];
		ResourceManager.instance.addSource(_skeleton.name, _skeleton);
		//_skeleton.destroy();
		_skeleton = null;
		owner = null;
	}
	override public function removed():Void 
	{
		super.removed();
		owner = null;
	}
	
	override private function createAvatar(name:String, resPath:String):Dynamic
	{
		/*
		var atlas = TextureAtlas.create(Assets.getText(ResPath.getModelAtlas(name, resPath, _info.res)), ResPath.getModelRoot(resPath, _info.res), new BitmapDataTextureLoader());
		var json:SkeletonJson = SkeletonJson.create(atlas);
		var path:String = ResPath.getModelJson(name, resPath, _info.res);
        var skeletonData:SkeletonData = json.readSkeletonData(Assets.getText(path), path);
		//需要设置皮肤
		var skin;
		if(skeletonData.skins.length>1){
			skin = skeletonData.findSkin("clips"+_info.skin);
		} else {
			skin = skeletonData.skins[0];
		}
		skeletonData.defaultSkin = skin;
		*/
		//stateData.defaultMix = 0.2; //动作之间间隔时间
		
		//var spine = ResourceManager.instance.getGraphic(SpinePunk, [skeletonData]);
		var path = ResPath.getModelRoot(resPath, _info.res);
		var skeletonData:SkeletonData = SpinePunk.readSkeletonData(name, path, 1, _info.skin);
		//trace(name + skeletonData.name);
		var skeleton:SpinePunk = cast ResourceManager.instance.getResource(path);
		if (skeleton==null)
			skeleton = new SpinePunk(skeletonData);
		
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
		//trace(action);
		//skeleton.skeleton.resetSlots(skeleton.skeletonData);
		//trace("setToSetupPose: " + action);

		_skeleton.skeleton.setToSetupPose();		
		_skeleton.state.setAnimationByName(0, action, loop);
		//skeleton.skeleton.setBonesToSetupPose();
	}
	
	private var _isInit:Bool = false;
	override public function update():Void {
		_skeleton.update();
		/*
		if (_skeleton.useMask) {
			useHitBox = false;
			mask = _skeleton.mask;
		}else {
			useHitBox = true;
			setHitboxTo(_skeleton.mainHitbox);
		}
		*/
		if (_skeleton != null)
			_skeleton.color = _colorT.color;
		super.update();
	}
	
	override private function initTexture():Void
	{
		switch(type){
			case UnitModelType.Player:
				_skeleton = createAvatar("model", type);
			default:
				_skeleton = createAvatar("model", UnitModelType.Unit);
		}
		changeColor();
	}
	
	override private function set_flip(value:Bool):Bool
	{
		if (value)
			_skeleton.flipX = (_info.flip == 0)?true:false;
		else
			_skeleton.flipX = (_info.flip == 0)?false:true;
		return value;
	}
	override function get_flip():Bool 
	{
		return	_skeleton.flipX;
	}
	
	public function getScale():Float
	{
		
		return _info.scale;
	}
	
	public function getBone(name:String):Bone
	{
		return _skeleton.skeleton.findBone(name);
	}
	/** modify slotData to set attachment */
	public function setAttachMent(slotName:String, attachName:String):Void
	{
		var index = _skeleton.skeletonData.findSlotIndex(slotName);
		_skeleton.skeletonData.slots[index].attachmentName = attachName;
		_skeleton.skeleton.setToSetupPose();
		_skeleton.update();
	}
	
	public function getBoneData(name:String):BoneData
	{
		return _skeleton.skeletonData.findBone(name);
	}
	
	public function animationState():AnimationState
	{
		return _skeleton.state;
	}
	public function getAnimation(name:String):Animation 
	{
		return _skeleton.skeletonData.findAnimation(name);
	}
	public function setGunHitbox(name:String):Void 
	{
		_skeleton.weaponHitslot = name;
	}
	public function getGunHitbox():Rectangle 
	{
		return _skeleton.weaponBox;
	}
	
	public function setCallback(fun:Dynamic)
	{
		_skeleton.state.onComplete.add(fun);
	}
	
	public var color(get, set):Int;
	private function get_color():Int { return _skeleton.color; }
	private function set_color(value:Int):Int
	{
		return _skeleton.color = value;
	}
	
	public function startChangeColor():Void
	{
		if (_colorT != null)
			_colorT.start();
	}
	//设置受击闪红
	private function changeColor():Void
	{
		var _tuneColor:Int = 0xff0000;
		_color = color;
		_colorT = new ColorTween(TweenType.Persist);
		_colorT.tween(0.1, _color, _tuneColor, 0, 0.6);
		_colorT.addEventListener(TweenEvent.FINISH, completeTween);
		_colorT.cancel();
		addTween(_colorT);
	}
	
	private function completeTween(e):Void
	{
		//trace(color + "  complete  " + _color);
		_colorT.color = -1;
	}
}
