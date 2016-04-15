package com.metal.enums;
import com.metal.proto.impl.LiveNessInfo;
import haxe.ds.IntMap;

/**
 * ...
 * @author zxk
 */
class RewardInfo
{
	public var rewardAllNum:Int;
	public var rewardArr:Array<Dynamic>;
	public var rewardArrbtn:Array<Bool>;
	public var rewardArrbtn2:Array<Bool>;
	public function new() 
	{
		
	}
	
	public function removeData():Void
	{
		rewardAllNum = 0;
		rewardArr = [];
	}
}