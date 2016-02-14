/******************************************************************************
 * Spine Runtime Software License - Version 1.1
 * 
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms in whole or in part, with
 * or without modification, are permitted provided that the following conditions
 * are met:
 * 
 * 1. A Spine Essential, Professional, Enterprise, or Education License must
 *    be purchased from Esoteric Software and the license must remain valid:
 *    http://esotericsoftware.com/
 * 2. Redistributions of source code must retain this license, which is the
 *    above copyright notice, this declaration of conditions and the following
 *    disclaimer.
 * 3. Redistributions in binary form must reproduce this license, which is the
 *    above copyright notice, this declaration of conditions and the following
 *    disclaimer, in the documentation and/or other materials provided with the
 *    distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/
package spinehaxe;

import spinehaxe.animation.Animation;
import spinehaxe.Exception;
import haxe.ds.Vector;

class SkeletonData {
	public var name:String;
	public var bones:Array<BoneData>;
	// Ordered parents first.
	public var slots:Array<SlotData>;
	// Setup pose draw order.
	public var skins:Array<Skin>;
	public var defaultSkin:Skin;
	public var events:Array<EventData>;
	public var animations:Array<Animation>;
	// --- Bones.
	public function addBone(bone:BoneData):Void {
		if(bone == null) 
			throw new IllegalArgumentException("bone cannot be null.");
		bones[bones.length] = bone;
	}

	/** @return May be null. */
	public function findBone(boneName:String):BoneData {
		if(boneName == null) 
			throw new IllegalArgumentException("boneName cannot be null.");
		var i:Int = 0;
		var n:Int = bones.length;
		while(i < n) {
			var bone:BoneData = bones[i];
			if(bone.name == boneName) 
				return bone;
			i++;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findBoneIndex(boneName:String):Int {
		if(boneName == null) 
			throw new IllegalArgumentException("boneName cannot be null.");
		var i:Int = 0;
		var n:Int = bones.length;
		while(i < n) {
			if(bones[i].name == boneName) 
				return i;
			i++;
		}
		return -1;
	}

	// --- Slots.
	public function addSlot(slot:SlotData):Void {
		if(slot == null) 
			throw new IllegalArgumentException("slot cannot be null.");
		slots[slots.length] = slot;
	}

	/** @return May be null. */
	public function findSlot(slotName:String):SlotData {
		if(slotName == null) 
			throw new IllegalArgumentException("slotName cannot be null.");
		var i:Int = 0;
		var n:Int = slots.length;
		while(i < n) {
			var slot:SlotData = slots[i];
			if(slot.name == slotName) 
				return slot;
			i++;
		}
		return null;
	}

	/** @return -1 if the bone was not found. */
	public function findSlotIndex(slotName:String):Int {
		if(slotName == null) 
			throw new IllegalArgumentException("slotName cannot be null.");
		var i:Int = 0;
		var n:Int = slots.length;
		while(i < n) {
			if(slots[i].name == slotName) 
				return i;
			i++;
		}
		return -1;
	}

	// --- Skins.
	public function addSkin(skin:Skin):Void {
		if(skin == null) 
			throw new IllegalArgumentException("skin cannot be null.");
		skins[skins.length] = skin;
	}

	/** @return May be null. */
	public function findSkin(skinName:String):Skin {
		if(skinName == null) 
			throw new IllegalArgumentException("skinName cannot be null.");
		for(skin in skins)
			if(skin.name == skinName) 
			return skin;
		return null;
	}

	// --- Events.
	public function addEvent(eventData:EventData):Void {
		if(eventData == null) 
			throw new IllegalArgumentException("eventData cannot be null.");
		events[events.length] = eventData;
	}

	/** @return May be null. */
	public function findEvent(eventName:String):EventData {
		if(eventName == null) 
			throw new IllegalArgumentException("eventName cannot be null.");
		var i:Int = 0;
		var n:Int = events.length;
		while(i < n) {
			var eventData:EventData = events[i];
			if(eventData.name == eventName) 
				return eventData;
			i++;
		}
		return null;
	}

	// --- Animations.
	public function addAnimation(animation:Animation):Void {
		if(animation == null) 
			throw new IllegalArgumentException("animation cannot be null.");
		animations[animations.length] = animation;
	}

	/** @return May be null. */
	public function findAnimation(animationName:String):Animation {
		//trace(animations);
		if(animationName == null) 
			throw new IllegalArgumentException("animationName cannot be null.");
		var i:Int = 0;
		var n:Int = animations.length;
		while(i < n) {
			var animation:Animation = animations[i];
			if(animation.name == animationName) 
				return animation;
			i++;
		}
		return null;
	}

	// ---
	public function toString():String {
		return name;
		//return name != (null) ? name : ("" + this);
	}

	public function new() {
		bones = new Array<BoneData>();
		slots = new Array<SlotData>();
		skins = new Array<Skin>();
		events = new Array<EventData>();
		animations = new Array<Animation>();
	}
	public function clone():SkeletonData
	{
		var data = new SkeletonData();
		data.name = name;
		data.bones = bones.copy();
		data.slots = slots.copy();
		data.skins = skins.copy();
		data.events = events.copy();
		data.animations = animations.copy();
		return data;
	}
	public function dispose()
	{
		defaultSkin = null;
		bones = null;
		slots = null;
		skins = null;
		events = null;
		animations = null;
	}
}

