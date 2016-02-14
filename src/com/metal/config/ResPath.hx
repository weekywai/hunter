package com.metal.config;

/**
 * 资源路径管理
 * @author weeky
 */
class ResPath 
{
	public static inline var MapRoot:String = "map/";
	public static inline var ModelRoot:String = "model/";
	
	public static inline var ModelIcon:String = "head/";
	
	public function new() {}
	
	//public static inline var playerRoot:String = "model/player";
	/**获取角色资源路径*/
	public static inline function getModelAtlas(name:String, type:String, id:String):String {
		return getModelRoot(type, id) + name+".atlas";
	}
	public static inline function getModelJson(name:String, type:String, id:String):String {
		return getModelRoot(type, id) + name+".json";
	}
	public static inline function getModelXML(type:String, id:String){
		return getModelRoot(type, id) + id+".xml";
	}
	
	public static inline function getModelRoot(type:String, id:String):String
	{
		return ModelRoot + type + "/" + id + "/";
	}
	/**地图数据资源*/
	public static inline function getMapDataRes(name:String):String {
		return MapRoot  + name + ".tmx";
	}
	/**地图图片资源*/
	public static inline function getMapImgRes(name:String, id:String = "M0001"):String {
		return MapRoot + id + "/" + name;
	}
	/**图标资源路劲*/
	public static inline function getIconPath(id:String, type:String = "", fileType:String=".png"):String {
		if (type != "")
			return "icon/" + type + id + fileType;
		return "icon/" + id + fileType;
	}
	/** 特效 1:png  2:Xml 3:json 其他代表不用填格式*/
	public static inline function getEffectRes(id:String, type:Int):String
	{
		var path:String = "effect/" + id;
		return addType(path, type);
	}
	/**
	 * 子弹资源
	 */
	public static inline function getBulletRes(id:String, type:Int=1):String
	{
		return "bullet/" + id;
	}
	
	private static function addType(path:String, type:Int):String {
		return switch(type) {
			case 1:
				path +".png";
			case 2:
				path +".xml";
			case 3:
				path+".json";
			default:
				path;
		}
	}
	public static inline function getProto(name:String):String
	{
		return "proto/" + name + ".xml";
	}
	
}