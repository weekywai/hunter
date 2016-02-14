package com.metal.manager;
import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.HXP;
import com.metal.unit.avatar.MTAvatar;
import de.polygonal.ds.pooling.DynamicObjectPool;
import haxe.ds.StringMap;
import openfl.errors.Error;
import spinehaxe.SkeletonJson;
import spinepunk.SpinePunk;

/**
 * 资源管理
 * @author weeky
 */
class ResourceManager
{
	static public var instance(default, null):ResourceManager = new ResourceManager();
	static public var PreLoad:Bool = false;
	
	private static var _graphicPool:DynamicObjectPool<Graphic>;
	private static var _graphicCache:StringMap<Array<Graphic>>;
	private var _cacheEntity:StringMap<Array<Entity>>;
	
	public function new() {	
		_graphicCache = new StringMap();
		_graphicPool = new DynamicObjectPool(null, fabricate);
		_cacheEntity = new StringMap();
	}
	
	public function getResource(id:String):Graphic 
	{
		if (_graphicCache.exists(id)){
			var list = _graphicCache.get(id);
			var g = list.pop();
			if (list.length <= 0)
				_graphicCache.remove(id);
		}
		return null;
	}
	public function isExist(id:String):Bool 
	{
		return _graphicCache.exists(id);
	}
	
	public function addSource(id:String, source:Graphic):Void
	{
		if (source == null)
			throw new Error("Resource no exist " + id);
			
		if (!_graphicCache.exists(id)){
			var list = [];
			list.push(source);
			_graphicCache.set(id, list);
		}
	}
	
	public function recycleGraphic(g:Graphic):Void 
	{
		if (g == null)
			throw new Error("recycle grphic is null");
		_graphicPool.put(g);
		//trace(_graphicPool.used());
	}
	private var _classType:Class<Graphic>;
	private var _args:Array<Dynamic>;
	public function getGraphic(classType:Class<Graphic>,?args:Array<Dynamic>): Graphic
	{
		_classType = classType;
		_args = (args == null)?[]:args;
		
		//trace(_graphicPool.used()+">>>usage:"+_graphicPool.maxUsageCount()+">>>Max pool:");
		return _graphicPool.get();
	}
	private function fabricate():Graphic 
	{
		//trace("fabricate"+ _classType+" "+_graphicPool.used());
		return Type.createInstance(_classType, _args);
	}
	
	public function addEntity(type:String, e:Entity)
	{
		
		if (_cacheEntity.exists(type)) {
			_cacheEntity.get(type).push(e);
		}else {
			_cacheEntity.set(type, [e]);
		}
	}
	
	public function getEntity(type:String):Entity
	{
		
		if (_cacheEntity.exists(type)) {
			var a =  _cacheEntity.get(type).shift();
			//if(type=="m111")
			//trace(_cacheEntity.get(type) + ">>" + a);
			return a;
		}
		return null;
	}
	
	public function reclaim():Void 
	{
		var count = _graphicPool.reclaim();
		//trace("Graphic reclaim :" + count);
	}
	
	public function unLoadAll():Void 
	{
		for (key in _graphicCache.keys()) 
		{
			var list = _graphicCache.get(key);
			for (g in list) 
			{
				g.destroy();
				list.remove(g);
			}
			_graphicCache.remove(key);
		}
		_graphicCache = new StringMap();
		_graphicPool.free();
		for (key in _cacheEntity.keys()) 
		{
			var list = _cacheEntity.get(key);
			for (e in list) 
			{
				HXP.scene.remove(e);
				cast(e, MTAvatar).dispose();
			}
		}
		_cacheEntity = new StringMap();
		SpinePunk.clear();
		SkeletonJson.clearJson();
		TextureAtlasFix.clearCacahes();
		AtlasData.destroyAll();
		HXP.removeAllBitmap();
	}
}