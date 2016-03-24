package com.metal.unit.avatar;

/**
 * ...
 * @author weeky
 */

class AvatarAction
{
	public static inline var Idle:String = "Idle";
	public static inline var Walk:String = "Walk";
	public static inline var Attack:String = "Attack";
	
	public static inline var Jump:String = "Jump";
	public static inline var Dead:String = "Dead";
	
	public static inline var Sk1:String = "Skill1";
	public static inline var Victory:String = "Victory";
	public static inline var Drink:String = "Drink";
	
	//attack 7方向
	public static inline var DirU:Int = 0;
	public static inline var DirUR:Int = 1;
	public static inline var DirRU:Int = 2;
	public static inline var DirR:Int = 3;
	public static inline var DirRD:Int = 4;
	public static inline var DirDR:Int = 5;
	public static inline var DirD:Int = 6;
	
	public static inline var DirDL:Int = 7;
	public static inline var DirLD:Int = 8;
	public static inline var DirL:Int = 9;
	public static inline var DirLU:Int = 10;
	public static inline var DirUL:Int = 11;
	//蹲
	public static inline var Crouch:String = "_Crouch";
	
	private static var _dirFrames = ["_U", "_UR", "_RU", "_R", "_RD", "_DR", "_D","_DR","_RD","_R","_RU","_UR"];
	private static var _flips = [false, false, false, false, false, false, false, true, true, true, true, true];
	
	public static function getFlip(dir:Int):Bool
	{
		return _flips[dir];
	}
	/**获取攻击状态*/
	public static function getAttack(dir:Int, walk:Bool = false, crouch:Bool =false):Array<String>
	{
		var ary:Array<String> = [];
		if (crouch) {
			ary.push(Attack + Crouch);
		}else if (walk) {
			ary.push(Attack + _dirFrames[dir]);
			ary.push(Walk);
		}else{
			ary.push(Attack + _dirFrames[dir]);
			ary.push(Idle);
		}
		return ary;
	}
	/**获取走路状态*/
	public static function getWalk(dir:Int, jump:Bool =false) :Array<String>
	{
		var ary:Array<String> = [];
		if (jump) {
			ary.push(Idle);
			ary.push(Walk + "_" + Jump);
		}else {
			ary.push(Walk);
			ary.push(Walk);
		}
		return ary;
	}
	/**获取待机状态*/
	public static function getIdle(dir:Int, jump:Bool =false):Array<String> {
		var ary:Array<String> = [];
		if (jump) {
			ary.push(Idle);
			ary.push(Jump);
		}else {
			if (dir == DirD){
				ary.push(Idle + Crouch);
			}else if(dir == DirU){
				ary.push(Idle + _dirFrames[dir]);
				ary.push(Idle);
			}else{
				ary.push(Idle);
				ary.push(Idle);
			}
		}
		return ary;
	}
	/**角度*/
	public static function angleDir(angle:Float):Int
	{
		var a = 22.5;
		if (angle < a && angle>-a)
			return DirR;
		else if (angle > a && angle < a * 2)
			return DirRU;
		else if (angle > a * 2 && angle < a * 3)
			return DirUR;
		else if (angle > a * 3)
			return DirU;
		else if (angle > -a * 2 && angle < -a)
			return DirRD;
		else if (angle > -a * 3 && angle < -a * 2)
			return DirDR;
		else if (angle < -a * 3)
			return DirD;
		else
			return 3;
	}
}