package com.metal.proto.manager;
import com.metal.config.MapLayerType;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
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
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.StageRoom);
		for (i in req) 
		{
			var info:MapRoomInfo = new MapRoomInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	
	public var _data:IntMap<MapRoomInfo>;
	
	/**提示*/
	public function getRoomInfo(roomId:Int):MapRoomInfo
	{
		return _data.get(roomId);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var room:Fast;
		var tempInfo:MapRoomInfo;
		for (room in source.nodes.propStageroom) {
			tempInfo = new MapRoomInfo();
			tempInfo.readXml(room);
			_data.set(tempInfo.Id,tempInfo);
		}*/
	}
	
	/***判断是否B类型的酷跑地图类型*/
	public function checkBtypeMap(roomId:Int):Bool
	{
		return getRoomInfo(roomId).RoomType == MapLayerType.MapTypeB;
	}
	
}