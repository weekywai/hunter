package com.metal.config;

/**
 * 地图层分类
 * @author 3D
 */
class MapLayerType
{
	public static var LayerName:Array<String> = ["Foreground_1","Middle_2_1","Middle_2_2","Middle_2_3","Surface_3","Clouds_5","Sky_6"];
	public static var Block:Int = -1;//阻挡层
	public static var ForeGround:Int = 0;//前景
	
	public static var MiddleOne:Int = 1;//中景1
	
	public static var MiddleTwo:Int = 2;//中景2
	
	public static var Surface:Int = 3;//地表
	
	public static var Clouds:Int = 4;//云层
	
	public static var Sky:Int = 5;//天空
	/**地图层*/
	public static inline var MapLayer:Int = 500;
	/**角色图层*/
	public static inline var ActorLayer:Int = 499;
	/**前景/特效图层*/
	public static inline var FrontLayer:Int = 498;
	
	public static var MapTypeA:Int = 1;//
	public static var MapTypeB:Int = 2;//酷跑类型
	public static var MapTypeC:Int = 3;//有boss的地图
	
}