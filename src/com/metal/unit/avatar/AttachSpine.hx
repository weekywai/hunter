package com.metal.unit.avatar;

import com.metal.enums.Direction;
import com.metal.manager.ResourceManager;
import openfl.geom.Rectangle;
import spinehaxe.Bone;
import spinehaxe.BoneData;
import spinehaxe.SkeletonData;
import spinehaxe.animation.Animation;
import spinehaxe.animation.AnimationState;
import spinepunk.SpinePunk;

/**
 * AttachSpine
 * @author weeky
 */
class AttachSpine extends SpinePunk implements IAttach
{
	public function new(skeletonData:SkeletonData,  smooth=true) 
	{
		super(skeletonData,  smooth);
	}
	
	public var color(get, set):Int;
	function get_color():Int { return colors; }
	function set_color(value:Int):Int
	{
		return colors = value;
	}
	public function initAttach(callback:Dynamic = null)
	{
		if(callback!=null)
			state.onComplete.add(callback);
	}
	public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void {
		//trace(action);
		//skeleton.skeleton.resetSlots(skeleton.skeletonData);
		//trace("setToSetupPose: " + action);
		skeleton.setToSetupPose();		
		state.setAnimationByName(0, action, loop);
		//skeleton.skeleton.setBonesToSetupPose();
	}
	public var flip(get, set):Bool;
	function get_flip():Bool { return flipX; }
	function set_flip(value:Bool):Bool
	{
		return flipX = value;
	}
	
	inline public function as<T:IAttach>(clss:Class<T>):T
	{
		#if flash
		return untyped __as__(this, clss);
		#else
		return cast this;
		#end
	}
	
	
	public function getBone(name:String):Bone
	{
		return skeleton.findBone(name);
	}
	/** modify slotData to set attachment */
	public function setAttachMent(slotName:String, attachName:String):Void
	{
		var index = skeletonData.findSlotIndex(slotName);
		skeletonData.slots[index].attachmentName = attachName;
		skeleton.setToSetupPose();
		update();
	}
	
	public function getBoneData(name:String):BoneData
	{
		return skeletonData.findBone(name);
	}
	
	public function animationState():AnimationState
	{
		return state;
	}
	public function getAnimation(name:String):Animation 
	{
		return skeletonData.findAnimation(name);
	}
	public function setGunHitbox(name:String):Void 
	{
		weaponHitslot = name;
	}
	public function getGunHitbox():Rectangle 
	{
		return weaponBox;
	}
	
	
}
