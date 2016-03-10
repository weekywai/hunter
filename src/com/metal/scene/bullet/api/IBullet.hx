package com.metal.scene.bullet.api;
import com.metal.proto.impl.BulletInfo;
import de.polygonal.core.sys.IDisposer;
import de.polygonal.core.sys.SimEntity;
import signals.Signal1;

/**
 * @author weeky
 */

interface IBullet extends IDisposer
{
	var info(default, null):BulletInfo;
	var x(get, set):Float;
	var y(get, set):Float;
	/** 目标X */
	var _tx:Float;
	/** 目标Y */
	var _ty:Float;
	var canRemove:Bool;
	var removeCall:Signal1<IBullet>;
	/**
	 * 初始化，一次初始化后可以多次重用
	 * @param	$body
	 * @param	$info
	 */
	function init(body:SimEntity):Void;
	function setInfo(info:BulletInfo):Void;
	
	function start(req:BulletRequest):Void;
	function recycle():Void;
}