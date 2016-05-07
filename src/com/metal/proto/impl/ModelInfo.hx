package com.metal.proto.impl;

/**
 * atk值 = actorInfo.hp/rate2*5
 * hp值 = actorInfo.dps*rate1
 * @author weeky
 */
class ModelInfo
{
	public var ID:Int;
	/**模型类型*/
	public var type1:Int;
	/**模型资源类型*/
	public var type:Int;
	/**武器骨络名字*/
	public var gun1:Array<String>; 
	public var gun2:Array<String>;
	public var gun3:Array<String>;
	public var gun4:Array<String>;
	public var gun5:Array<String>;
	/**非碰撞骨骼*/
	//public var unSlot:Array<String>;
	/**是否翻转*/
	public var flip:Int; 
	/**是否飞行*/
	public var fly:Int = 1;
	/**缩放*/
	public var scale:Float=1;
	/**资源*/
	public var res:String;
	/**受击特效*/
	public var hit:Int = 0;
	public var skin:Int = 1;
	
	public var rate1:Float;
	public var rate2:Int;
	public function new() 
	{
	}
	public function readXml(data:Dynamic):Void
	{
		ID = data.Id;
		type1 = data.Type1;
		type = data.Type;
		gun1 = parseList(data.gun1);
		gun2 = parseList(data.gun2);
		gun3 = parseList(data.gun3);
		gun4 = parseList(data.gun4);
		gun5 = parseList(data.gun5);
		//unSlot = parseList(data.UnBone);
		flip = data.IsFlip;
		scale = data.Size;
		res = data.ModelPic;
		hit = data.hit;
		skin = data.skin;
		rate1 = data.rate1;
		rate2 = data.rate2;
	}
	
	private function parseList(data:Dynamic):Array<String>
	{
		var temp = [];
		temp = Std.string(data).split(",");
		return temp;
	}
}