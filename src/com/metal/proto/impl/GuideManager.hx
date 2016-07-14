package com.metal.proto.impl;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import haxe.ds.IntMap;

typedef GuideInfo = {
	/**最大重叠数*/
	@:optional var Id:Int;
	/**穿戴等级*/
	@:optional var Desc:Int;
	/**最高强化等级*/
	@:optional var Finish:Int;
	/**附加技能ID*/
	@:optional var Index:Int;
	
	//@:optional var strLv:Int;
	/**强化经验**/
	//@:optional var strExp:Int;
}
/**
 * ...
 * @author ...
 */
class GuideManager
{
	public static var instance(get, null):GuideManager;
	static private function get_instance() {
		if (instance == null)
			instance = new GuideManager();
		return instance;
	}
	public var _data:IntMap<GuideInfo>;
	
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.requestProfile(TableType.P_Guide);
		for (i in req) 
		{
			var info:GuideInfo = i;
			_data.set(info.Id, info);
		}
	}
	
	public function getGuide(Id:Int):GuideInfo
	{
		return _data.get(Id);
	}
	
	public function checkGuide(Id:Int):Bool
	{
		if(_data.exists(Id))
			return _data.get(Id).Finish==1;
		return false;
	}
	
	public function setGuide(Id:Int)
	{
		RemoteSqlite.instance.updateProfile(TableType.P_Guide, { Finish:1 }, { Id:Id } );
		_data.get(Id).Finish = 1;
	}
}