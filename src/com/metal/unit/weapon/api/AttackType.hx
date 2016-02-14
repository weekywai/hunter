package com.metal.unit.weapon.api;

/**
 * ...
 * @author weeky
 */
class AttackType
{
	/*
1 射击类
2 激光类
3 范围清怪类
4 全屏清怪类
5 全屏清子弹类
6 自爆类
7 刀砍类
8 BOSS导弹类
9 喷火类
10 子弹升级类
11 只给目标挂BUFF类
12 一次回血类 
	 */
	/**手雷*/
	public static var Grenade:Int = 1;
	/**清屏*/
	public static var CLear:Int = 4;
	/**暴走*/
	public static var BurstOut:Int = 11;
	/**子弹升级*/
	public static var BulletLevelUp:Int = 10;
	/**回血*/
	public static var Regen:Int = 12;
	public function new() {}
	
}