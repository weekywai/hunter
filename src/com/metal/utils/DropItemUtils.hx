package com.metal.utils;
import com.metal.component.BattleSystem;
import com.metal.proto.impl.DuplicateInfo;
import haxe.ds.StringMap;

/**
 * ...物品掉落
 * @author hyg
 */
class DropItemUtils
{

	public function new() 
	{
		
	}
	/**
	 * 普通副本掉落
	 * **/
	public static function ordinaryDrop(duplicateInfo:DuplicateInfo,justShow:Bool=false):Array<Array<Int>>
	{
		var arrNum:Int = Math.floor(Math.random() * 3);
		var dropArr:Array<Array<Int>> = [];
		var dropItems:Array<Array<String>> = [];
		dropItems = dropItems.concat(duplicateInfo.DropItem1);
		dropItems = dropItems.concat(duplicateInfo.DropItem2);
		dropItems = dropItems.concat(duplicateInfo.DropItem3);
		//switch(arrNum)
		//{
			//case 0:
				//dropItems = duplicateInfo.DropItem1;
			//case 1:
				//dropItems = duplicateInfo.DropItem2;
			//case 2:
				//dropItems = duplicateInfo.DropItem3;
		//}
		if (justShow) 
		{
			dropArr = showDropItems(dropItems);
		}else 
		{
			dropArr = runDropItems(dropItems);
		}		
		return dropArr;
	}
	/**
	 * BOSS副本掉落
	 * */
	public static function bossDrop(duplicateInfo:DuplicateInfo):Array<Array<Int>>
	{
		var battle:BattleSystem = GameProcess.instance.getComponent(BattleSystem);
		var total:Int =  battle.TotalKillBoss;
		if (total == 0) return [];
		var arrNum:Int = Math.floor(Math.random() * 2);
		var dropArr:Array<Array<Int>> = [];
		var dropItems:Array<Array<String>> = [];
		if (arrNum == 0)
		{
			dropItems = duplicateInfo.DropItem2;
		}else if (arrNum == 1)
		{
			dropItems = duplicateInfo.DropItem3;
		}
		dropArr = bossDropItems(dropItems, total,duplicateInfo);
		//if (dropArr.length == 0)
		//{
			//dropArr = bossDropItems(duplicateInfo.DropItem1, total);
		//}
		return dropArr;
	}
	private static function bossDropItems(_dropItems:Array<Array<String>>,num:Int,duplicateInfo:DuplicateInfo):Array<Array<Int>>
	{
		var dropArr:Array<Array<Int>> = [];
		var goldNum:Int = 0;
		for (j in 0...num )
		{
			var _random :Int = Math.floor(Math.random() * _dropItems.length);
			
			var randomNum:Float = Math.random() * 100;
			
			if (_dropItems[_random][0] != "10201")
			{
				
				if (randomNum <= Std.parseInt(_dropItems[_random][1]))
				{
					dropArr.push([Std.parseInt(_dropItems[_random][0]),Std.parseInt(_dropItems[_random][2])]);
				}else
				{
					_random = Math.floor(Math.random() * duplicateInfo.DropItem1.length);
					//trace("===");
					dropArr.push([Std.parseInt(duplicateInfo.DropItem1[_random][0]), Std.parseInt(duplicateInfo.DropItem1[_random][2])]);
					//trace("==sdf=");
				}
			}else
			{
				goldNum = Std.parseInt(_dropItems[_random][2]);
			}
		}
		if (goldNum > 0 )
		{
			dropArr.push([10201,goldNum*num]);
		}
		return dropArr;
	}
	/***普通关卡掉落**/
	private static function runDropItems(_dropItems:Array<Array<String>>):Array<Array<Int>>
	{
		var dropArr:Array<Array<Int>> = [];
		var goldNum:Int = 0;
		for (i in 0..._dropItems.length)
		{
			var randomNum:Float = Math.random() * 100;
			if (randomNum <= Std.parseInt(_dropItems[i][1]))
			{
				var arr:Array <Int> = [];
				arr.push(Std.parseInt(_dropItems[i][0]));
				arr.push(Std.parseInt(_dropItems[i][2]));
				if (_dropItems[i][0] == "10201")
				{
					goldNum += Std.parseInt(_dropItems[i][2]);
				}else{
					dropArr.push(arr);
				}
			}
		}
		if(goldNum > 0){
			dropArr.push([10201, goldNum]);
		}
		return dropArr;
	}
	/***显示关卡掉落**/
	private static function showDropItems(_dropItems:Array<Array<String>>):Array<Array<Int>>
	{
		var dropArr:Array<Array<Int>> = [];
		var goldNum:Int = 0;
		var dropIdArr:StringMap<Bool>=new StringMap();
		for (i in 0..._dropItems.length)
		{
			if (!dropIdArr.get(_dropItems[i][0])) 
			{
				dropIdArr.set(_dropItems[i][0], true);
				var arr:Array <Int> = [];
				arr.push(Std.parseInt(_dropItems[i][0]));
				arr.push(Std.parseInt(_dropItems[i][2]));
				if (_dropItems[i][0] == "10201")
				{
					goldNum += Std.parseInt(_dropItems[i][2]);
				}else{
					dropArr.push(arr);
				}
			}
			
		}
		if(goldNum > 0){
			dropArr.push([10201, goldNum]);
		}
		return dropArr;
	}
}