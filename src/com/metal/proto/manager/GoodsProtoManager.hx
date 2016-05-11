package com.metal.proto.manager;
import com.metal.component.BagpackSystem;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import de.polygonal.core.math.Limits;
import haxe.ds.IntMap;

using com.metal.proto.impl.ItemProto;
/**
 * 物品管理
 * @author weeky
 */
class GoodsProtoManager
{
	public static var instance(default, null):GoodsProtoManager = new GoodsProtoManager();
	var keyIdMap:IntMap<ItemBaseInfo>;
	
	public function new() 
	{
		keyIdMap = new IntMap();
	}
	
	/**通过id拿到物品,默认创建新物品*/
	public function getItemById(id:Int, createNewItem:Bool=true):ItemBaseInfo
	{
		var request = RemoteSqlite.instance.request(TableType.Item, "ID", id);
		if (Lambda.empty(request))
			return null;
		var item:ItemBaseInfo = request[0];
		if (createNewItem) 
		{
			//item.vo = findEmptyKeyId();
			//keyIdMap.set(item.keyId, item);
		}
		return item;
	}
	
	/**获得物品的小类*/
	public function getItemLittleKind(key:Int):Int
	{
		var request = RemoteSqlite.instance.request(TableType.Item, "ID", key);
		if (Lambda.empty(request))
			return null;
		return request[0].Kind;
	}
	
	
	/**获取所有物品*/
	public function getAll():IntMap<ItemBaseInfo>
	{
		var list = RemoteSqlite.instance.request(TableType.Item);
		var map:IntMap<ItemBaseInfo> = new IntMap();
		var item:ItemBaseInfo;
		for (node in list) 
		{
			item = node;
			map.set(item.ID, item);
		}
		return map;
	}
	
	/**获取指定类型物品*/
	public function getAllItem(kind:Int):IntMap<ItemBaseInfo>
	{
		var request = RemoteSqlite.instance.request(TableType.Item, "Kind", kind);
		if (Lambda.empty(request))
			return null;
		var map:IntMap<ItemBaseInfo> = new IntMap();
		var item:ItemBaseInfo;
		for (node in request) 
		{
			item = node;
			map.set(item.ID, item);
		}
		return map;
	}
	
	/**获取道具的品质资源路劲**/
	public  function getColorSrc(id:Int,num:Int=1):String
	{
		var src:String ="";
		switch(num)
		{
			case 1:
				src = "icon/quality/" + getItemById(id).Color + ".png";
			case 0:
				src = "icon/quality/" + getItemById(id).Color + "_1" + ".png";
			case 2:
				src = "icon/quality/" + getItemById(id).Color + "_2" + ".png";//大 外框
			case 3:
				src = "icon/quality/" + getItemById(id).Color + "_3" + ".png";//大 内背景
			case 4:
				src = "storeListBtn" + getItemById(id).Color;//滚动背景
		}
		return src;
	}
	
	
	/**获取道具的图标资源路劲***/
	public function getIconSrc(id:Int):String
	{
		var src:String ;
		src = "icon/" + getItemById(id).ResId + ".png";
		return src;
	}
	/**获取子id*/
	public function getSubID(id:Int):Int 
	{
		return getItemById(id).SubId;
	}
}