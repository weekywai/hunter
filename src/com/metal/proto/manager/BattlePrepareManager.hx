package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.BattlePrepareInfo;
import haxe.ds.IntMap;

/**
 * 站前准备
 * @author li
 */
class BattlePrepareManager
{
	public static var instance(default, null):BattlePrepareManager = new BattlePrepareManager();
	
	private var _data:IntMap<BattlePrepareInfo>;
	
	/**顺序存储_protoBattlePrepare的key值*/
	private var _protoKeyMap:IntMap<Int>;
	
	private var _protoLength:Int;

	public function new() 
	{
		_data = new IntMap();
		_protoKeyMap = new IntMap();
		_protoLength = 0;
		var req = RemoteSqlite.instance.request(TableType.BattlePrepar);
		var id:Int = 0;
		for (i in req) 
		{
			var info:BattlePrepareInfo = new BattlePrepareInfo();
			info.readXml(i);
			_data.set(info.ID, info);
			_protoKeyMap.set(id, info.ID);
			_protoLength++;
			id++;
		}
		
	}
	
	public function getProtoBattlePrepare():IntMap<BattlePrepareInfo>
	{
		return _data;
	}
	
	public function getProtoBattlePrepareByID(key:Int):BattlePrepareInfo
	{
		return _data.get(key);
	}
	
	/**顺序获取_protoBattlePrepare的值*/
	public function getProtoBattlePrepareByOrder(key:Int):BattlePrepareInfo
	{
		var protoKey:Int = _protoKeyMap.get(key);
		return _data.get(protoKey);
	}
	
	public function getProtoLength():Int
	{
		return _protoLength;
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propBattlePrepare:Fast, key:Int, id:Int = 0;
		for (propBattlePrepare in source.nodes.propBattlePrepare) {
			key = Std.parseInt(propBattlePrepare.node.ID.innerData);
			var du:BattlePrepareInfo = new BattlePrepareInfo();
			du.readXml(propBattlePrepare);
			_data.set(key, du);
			_protoKeyMap.set(id, key);
			_protoLength++;
			id++;
		}*/
	}
	
}