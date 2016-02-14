package com.metal.config;

/**
 * ...
 * @author 3D
 */
class BagType
{
	
	
	public static var BAG:Int = 1;//普通背包
	public static var EQUIP_BAG:Int = 2;//装备包
	
	
	public static var OPENTYPE_STORE:Int = 0;//仓库直接打开装备
	public static var OPENTYPE_MATERIAL:Int = 1;//仓库切换到材料
	public static var OPENTYPE_LVUP:Int = 2;//升级选择装备
	public static var OPENTYPE_STR:Int = 3;//强化选择材料 -->单选  确定就行
	public static var OPENTYPE_LVUP_EQUIP:Int = 4;//升级时切换到选择装备 同上2
	/**打开枪械仓库*/
	public static var OPENTYPE_WEAPON:Int = 5;
	/**打开护甲仓库*/
	public static var OPENTYPE_ARMS:Int = 6;
	
	public function new() 
	{
		
	}
	
}