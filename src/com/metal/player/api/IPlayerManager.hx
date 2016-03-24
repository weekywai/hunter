package com.metal.player.api;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
interface IPlayerManager
{
	/**
	 * 自己ID
	 */
	function myPlayerID():Int;
	/**
	 * 玩家数量
	 */
	function playerCount():Int;
	/**
	 * 获取玩家核
	 * @param	$id 玩家ID
	 * @return
	 */
	function getPlayerByID(id:Int):SimEntity;
	/**
	 * 通过索引获取玩家核
	 * @param	$index
	 * @return
	 */
	function getPlayerByIndex(index:Int):SimEntity;
}