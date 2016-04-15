package com.metal.scene.bullet.api;
import de.polygonal.core.sys.SimEntity;

/**
 * 子弹
 * @author weeky
 */
class BulletHitInfo
{
	public var atk:Int;
	public var fix:Array<Int>;
	public var target:SimEntity;
	public var melee:Bool = false;
	public var buffId:Int;
	public var buffTarget:Int;
	public var buffTime:Int;
	
	public var critPor:Float;
	public var renderType:Int;
	public function new() 
	{
		
	}
	
}