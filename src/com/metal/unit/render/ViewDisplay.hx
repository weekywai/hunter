package com.metal.unit.render;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.metal.config.UnitModelType;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.sys.MsgCore;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class ViewDisplay extends Entity implements IObserver 
{
	private var _collideTypes:Array<String> = [UnitModelType.Solid];
	private var _isFree:Bool;
	
	public var owner(default, null):SimEntity;
	public function hasParent():Bool {
		return (owner!=null && owner.parent!=null);
	}
	
	public var isDisposed(default, null) : Bool = false;
	
	public function new(x:Float = 0, y:Float = 0, graphic:Graphic = null, mask:Mask = null) 
	{
		super(x, y, graphic, mask);
		_isFree = false;
	}
	
	override public function dispose() : Void {
		if (isDisposed)
			return;
		onDispose();
		isDisposed = true;
	}
	private function onDispose():Void
	{
		owner = null;
		_collideTypes = null;
		if (graphic != null)
			graphic.destroy();
		graphic = null;
		if (scene != null)
			scene.remove(this);
	}
	
	override public function removed():Void 
	{
		super.removed();
		owner = null;
		//graphic = null;
	}
	
	public function init(owner:SimEntity):Void
	{
		this.owner = owner;
		type = owner.name;
		onInit();
	}
	/**继承*/
	private function onInit():Void {
		//override 
	}
	public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void { }
	
	private function notify(type:Int, userData:Dynamic = null) {
		if (owner != null)
			owner.notify(type, userData);
	}
	private function notifyParent(type:Int, userData:Dynamic = null) {
		if (owner != null)
			owner.notifyParent(type, userData);
	}
}