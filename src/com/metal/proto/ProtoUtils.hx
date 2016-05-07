package com.metal.proto;
import com.metal.proto.impl.ItemProto.ItemBaseInfo;
import com.metal.proto.impl.ItemProto.EquipInfo;

/**
 * ...
 * @author weeky
 */
class ProtoUtils
{

	/*public static function setStartBullet(info:ItemBaseInfo):Void
	{
		var item:WeaponInfo = cast info;
		item.vo.Bullets = item.OneClip;
		item.vo.Clips = item.StartClip;
		//item.firstGet = false;
	}*/
	
	public static function castType(info:Dynamic):Dynamic
	{
		var temp:Dynamic = info;
		return temp;
	}
	
	public static function getKind<T>(kind:Int, info:T):Null<T>
	{
		if (Reflect.field(info, "Kind") == kind)
			return info;
		return null;
	}
}