package com.metal.scene.board.api;
import de.polygonal.core.sys.IDisposer;
//import suity.dsa.qTree3.SQuadTreeItem;

/**
 * 物理场景物体
 * @author Simage
 */
interface IBoardItem extends IDisposer
{
	/**
	 * 物体阵营 : BoardFaction
	 */
	var faction(get, null):Int;
	/**
	 * 是否在场景中
	 */
	function isInBoard():Bool;
	/**
	 * 是否激活
	 */
	//function active():Bool;
	/**
	 * 宽
	 */
	var width(get, null):Float;
	/**
	 * 高
	 */
	var height(get, null):Float;
	/**
	 * 半宽
	 */
	var halfWidth(get, null):Float;
	/**
	 * 半高
	 */
	var halfHeight(get, null):Float;
	/**
	 * Iso坐标X
	 */
	var x(default, default):Float;
	/**
	 * Iso坐标Y
	 */
	var y(default, default):Float;
	
	
	/**
	 * 是否可被攻击
	 */
	//function attackable():Bool;
	/**
	 * 是否可被瞄准
	 */
	//function aimable():Bool;
	/**
	 * 是否在雷达显示
	 */
	//function showInRadar():Bool;
	/**
	 * 是否始终可见
	 */
	//function alwaysCanSee():Bool;
	/**
	 * 可受伤害
	 */
	//function canDamage():Bool;
	/**
	 * 是否自己阵营碰撞检测
	 */
	//function hitTestFaction():Bool;

}