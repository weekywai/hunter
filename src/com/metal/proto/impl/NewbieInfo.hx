package com.metal.proto.impl;
import haxe.ds.IntMap;

/**
 * ...
 * @author ...
 */
class NewbieInfo
{
	public static var instance(get, null):NewbieInfo;
	static private function get_instance() {
		if (instance == null)
			instance = new NewbieInfo();
		return instance;
	}
	public var dataArr:Array<Int>;
	
	public function new() 
	{
		dataArr=new Array();
	}
	//public function setNewbie(newbieId:Int)
	//{
		//if (dataArr.get(newbieId)==null || !dataArr.get(newbieId)) 
		//{
			//dataArr.set(newbieId, true);
		//} else 
		//{
			//trace("error!!! NewbieId has been shown before");
		//}
	//}
	//
	//public function getNewbie(newbieId:Int):Int
	//{
		//if (dataArr.get(mapId)==null) dataArr.set(mapId, false);
		//return dataArr.get(mapId);
	//}
	
}