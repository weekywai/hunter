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
package spinehaxe.animation;

import spinehaxe.Event;
import spinehaxe.Skeleton;
import haxe.ds.Vector;

class AttachmentTimeline implements Timeline {
	public var frameCount(get, never):Int;

	public var slotIndex:Int;
	public var frames:Vector<Float>;
	// time, ...
		public var attachmentNames:Vector<String>;
	public function new(frameCount:Int) {
		frames = ArrayUtils.allocFloat(frameCount);
		attachmentNames = new Vector<String>(frameCount);
	}

	public function get_frameCount():Int {
		return frames.length;
	}

	/** Sets the time and value of the specified keyframe. */	public function setFrame(frameIndex:Int, time:Float, attachmentName:String):Void {
		frames[frameIndex] = time;
		attachmentNames[frameIndex] = attachmentName;
	}

	public function apply(skeleton:Skeleton, lastTime:Float, time:Float, firedEvents:Array<Event>, alpha:Float):Void {
		if(time < frames[0]) 
			return;
		// Time is before first frame.
		var frameIndex:Int;
		if(time >= frames[frames.length - 1]) 
			// Time is after last frame.
		frameIndex = frames.length - 1
		else frameIndex = Animation.binarySearch(frames, time, 1) - 1;
		var attachmentName:String = attachmentNames[frameIndex];
		skeleton.slots[slotIndex].attachment = attachmentName == (null) ? null:skeleton.getAttachmentForSlotIndex(slotIndex, attachmentName);
	}

}

