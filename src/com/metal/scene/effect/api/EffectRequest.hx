package com.metal.scene.effect.api;
import com.metal.proto.impl.EffectInfo;
import com.metal.unit.avatar.MTAvatar;
import de.polygonal.core.sys.SimEntity;

/**
 * 特效请求，注意:此类是重用类，接受者绝不驻留此类，需将此类的参数复制出来。
 * @author weeky
 */
class EffectRequest
{
	public var Key:Int;
	/**攻击类型ID*/
	public var attackType:String;
	
	public var attacker:MTAvatar;
	
	/**起始位置*/
	public var x:Float = 0;
	public var y:Float = 0;
	
	public var angle:Float = 0;
	/**是否碰撞检测*/
	public var collide:Bool = false;
	
	/**模型的宽*/
	public var width:Float = 0;
	/**模型的高**/
	public var height:Float = 0;
	/**爆炸类型*/
	public var boomType:Int = 0;
	/**缩放*/
	public var scale:Float = 1;
	
	public var text:String;
	
	public var renderType:Int;
	
	/**正常*/
	public static var Normal:Int = 0;
	/**暴击*/
	public static var Crit :Int = 1;
	/**抵御*/
	public static var Defense:Int = 2;
	
	
	public function new() 
	{
		
	}
	
	public function setInfo(av:MTAvatar,type:Int,renderType:Int=0):Void
	{
		x = av.x;
		y = av.y;
		attacker = av;
		width = av.width;
		height = av.height;
		boomType = type;
		this.renderType = renderType;
	}
	
}