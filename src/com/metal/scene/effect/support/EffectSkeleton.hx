package com.metal.scene.effect.support;

import com.metal.scene.effect.impl.EffectEntity;
import spinepunk.SpinePunk;

/**
 * ...
 * @author weeky
 */
class EffectSkeleton extends EffectEntity
{
	private var _effect:SpinePunk;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	override function onDispose():Void 
	{
		_effect = null;
		super.onDispose();
	}
}