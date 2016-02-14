package com.metal.unit.stat;

/**
 * ...
 * @author weeky
 */
class BuffType
{
	/**掉血*/
	public static var Injured:Int = 1;
	/**回血*/
	public static var Regen:Int = 2;
	/**暴走*/
	public static var Runaway:Int = 3;
	/**改变速度*/
	public static var ChangeSpeed:Int = 4;
	/**无敌*/
	public static var Invincible:Int = 5;
	/**双倍积分*/
	public static var DoubleScore:Int = 6;
	/**换武器*/
	public static var ChangeWeapon:Int = 7;
	//public static var ImmuneBuff:Int = 5;		//免疫
	/**免伤*/
	public static var SkipHurt:Int = 11;		
	/**子弹有k%的几率升级*/
	public static var LevelupBullet:Int = 12;
	/**回复自身生命上限*/
	public static var Passive3:Int = 13;
	/**被动无敌*/
	public static var PassiveInvincible:Int = 14;
	public function new() 
	{
		
	}
	
}