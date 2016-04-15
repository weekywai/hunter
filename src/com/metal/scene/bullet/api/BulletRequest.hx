package com.metal.scene.bullet.api;
import com.metal.enums.Direction;
import com.metal.proto.impl.BulletInfo;
import de.polygonal.core.sys.SimEntity;

/**
 * 子弹请求，注意:此类是重用类，接受者绝不驻留此类，需将此类的参数复制出来。
 * @author weeky
 */
class BulletRequest
{
	public var attacker:SimEntity;
	//public var attackerType:String;
	/**攻击力*/
	public var atk:Int;
	public var atkType:String;
	
	/**子弹描述*/
	public var info:BulletInfo;
	/**起始位置*/
	public var x:Float = 0;
	public var y:Float = 0;
	/**目标位置*/
	public var targetX:Float = 0;
	public var targetY:Float = 0;
	/**飞行速率*/
	public var rate:Float = 1;
	/***/
	public var bulletAngle:Float=0;
	public var fix:Array<Int> = [];
	/**枪口火花*/
	public var spark:Int =-1;
	public var dir:Direction;
	public var buffTarget:Int = 0;
	public var buffId:Int = 0;
	public var buffTime:Int = 0;
	/**子弹数值渲染方式*/
	public var renderType:Int = 0;
	/**暴击率*/
	public var critPor:Float = 0;
	
	public function new() 
	{
		
	}
	
}