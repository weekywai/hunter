package com.metal.enums;

/**
 * @author weeky
 */

class EffectAniType {
	/**TexturePack图片动画*/
	inline public static var Image = 1;
	/**序列帧动画 图片格式*/
	inline public static var Texture = 2;
	/**骨络动画*/
	inline public static var Skeleton = 3;
	/**纯图片动画**/
	inline public static var ImageMoive = 4;
	/**原地爆炸类型1**/
	inline public static var Boom1 = 5;
	/**跟随爆炸类型**/
	inline public static var Boom2 = 6;
	/**文字特效*/
	inline public static var Text = 7;
}



class BulletType {
	/**无状态*/
	inline public static var None:Int = 0;
	/**常态*/
	inline public static var Normal:Int = 1;
	/**贯穿*/
	inline public static var Pierce:Int = 2;
	/**爆炸*/
	inline public static var Explode:Int = 3;
}