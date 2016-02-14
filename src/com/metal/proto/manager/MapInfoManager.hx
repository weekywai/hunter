package com.metal.proto.manager;
import com.metal.config.MapLayerType;
import com.metal.proto.impl.MapRoomInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author 3D
 */
class MapInfoManager
{
	public static var instance(default, null):MapInfoManager = new MapInfoManager();
	
	public function new() 
	{
		mapData = new IntMap();
	}
	
	public var mapData:IntMap<MapRoomInfo>;
	
	/**提示*/
	public function getRoomInfo(roomId:Int):MapRoomInfo
	{
		return mapData.get(roomId);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var room:Fast;
		var tempInfo:MapRoomInfo;
		for (room in source.nodes.propStageroom) {
			tempInfo = new MapRoomInfo();
			tempInfo.readXml(room);
			mapData.set(tempInfo.Id,tempInfo);
		}
	}
	
	/***判断是否B类型的酷跑地图类型*/
	public function checkBtypeMap(roomId:Int):Bool
	{
		return getRoomInfo(roomId).RoomType == MapLayerType.MapTypeB;
	}
	
}