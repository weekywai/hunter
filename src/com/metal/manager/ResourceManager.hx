package com.metal.manager;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.graphics.atlas.BitmapFontAtlas;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import de.polygonal.ds.pooling.DynamicObjectPool;
import de.polygonal.ds.pooling.ObjectPool;
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
	static public var instance(get, null):ResourceManager;
	static private function get_instance() {
		if (instance == null)
			instance = new ResourceManager();
		return instance;
	}
	static public var PreLoad:Bool = false;
	
	private static var _graphicPool:DynamicObjectPool<Graphic>;
	private static var _graphicCache:StringMap<Array<Graphic>>;
	
	public function new() {	
		_graphicCache = new StringMap();
		_graphicPool = new DynamicObjectPool(null, fabricate);
		//_graphicPool.allocate(false, Graphic);
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
	
	
	public function reclaim():Void 
	{
		//var count = _graphicPool.reclaim();
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
		SpinePunk.clear();
		SkeletonJson.clearJson();
		BitmapFontAtlas.clear();
		TextureAtlasFix.clear();
		AtlasData.destroyAll();
		HXP.removeAllBitmap();
	}
}