package com.metal.config;
import haxe.ds.IntMap;

/**
 * ...
 * @author hyg
 */
class FilesType
{
	public static var fileMap:IntMap<Dynamic> = new IntMap();//存储文件对象
	
	public static var Player:Int = 1;//角色信息
	public static var Active:Int = 2;//奖励
	public static var Task:Int = 3;//任务;
	public static var Bag:Int = 4;//背包仓库
	public static var EquipBag:Int = 5;//装备背包
	public static var News:Int = 6;//信息
	public static var StageStar:Int=7;//通关信息
	
	public static var fileArr:Array <Int> = [Player,Active,Task,Bag,EquipBag,News,StageStar];
	public function new() 
	{
		
	}
	
}