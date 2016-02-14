package com.metal.scene.effect.api;
import com.metal.proto.impl.EffectInfo;
import de.polygonal.core.sys.IDisposer;
import de.polygonal.core.sys.SimEntity;

/**
 * @author weeky
 */

interface IEffect extends IDisposer
{
	var info(default, null):EffectInfo;
	var x(get, set):Float;
	var y(get, set):Float;
	function init(body:SimEntity, req:EffectRequest):Void;
	function start(req:EffectRequest):Void;
}