package com.metal.proto.impl;
import haxe.ds.IntMap;

/**
 * ...
 * @author ...
 */
class MapStarInfo
{
	/**dataMap[DuplicateInfo.id]=array(condition1==true,condition2==true,condition3==true)*/
	public static var instance(get, null):MapStarInfo;
	static private function get_instance() {
		if (instance == null)
			instance = new MapStarInfo();
		return instance;
	}
	public var dataMap:IntMap<Int>;
	public function new() 
	{
		dataMap = new IntMap();
	}
	
	public function setMapStar(mapId:Int,starNum:Int)
	{
		if (dataMap.get(mapId)==null || starNum>dataMap.get(mapId)) 
		{
			dataMap.set(mapId, starNum);
		} 
	}
	
	public function getMapStar(mapId:Int):Int
	{
		if (dataMap.get(mapId)==null) dataMap.set(mapId, 0);
		return dataMap.get(mapId);
	}
}