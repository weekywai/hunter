package com.metal.unit.render;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.Mask;
import com.metal.config.UnitModelType;
import de.polygonal.core.sys.IDisposer;
import de.polygonal.core.sys.SimEntity;
import openfl.geom.Point;

/**
 * ...
 * @author weeky
 */
class ViewDisplay extends Entity implements IDisposer
{
	private var _collideTypes:Array<String> = [UnitModelType.Solid];
	
	public var owner(default, null):SimEntity;
	
	public var isDisposed(default, null) : Bool = false;
	
	public function new(x:Float = 0, y:Float = 0, graphic:Graphic = null, mask:Mask = null) 
	{
		super(x, y, graphic, mask);
	}
	
	public function dispose() : Void {
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
	
	public function init(owner:SimEntity):Void
	{
		this.owner = owner;
		type = owner.name;
	}
}