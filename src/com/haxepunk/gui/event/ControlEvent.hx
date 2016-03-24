package com.haxepunk.gui.event;

import flash.events.Event;

/**
 * ...
 * @author Samuel Bouchet
 */

class ControlEvent extends Event {
	
	public var control:Control;
	
	public function new(control:Control, type:String, bubbles:Bool = false, cancelable:Bool = false) {
		this.control = control;
		super(type,bubbles,cancelable);
	}
}