package com.metal.proto.impl;
import com.metal.enums.RunVo;
import com.utils.StringUtils;
import haxe.ds.IntMap;

/**
 * 房间数据
 * @author 3D
 */
class MapRoomInfo
{
	/**房间id*/
	public var Id:Int;
	public var MapId:String;
	//房间类型
	public var RoomType:Int;
	/**音效*/
	public var Round:String;
	//出场事件
	public var Events:Array<Array<String>>;
	//结束条件
	public var EndName:String;
	//景层参数
	public var _layerArgs1:String;
	public var _layerArgs2:String;
	public var _layerArgs3:String;
	public var _layerArgs4:String;
	public var _layerArgs5:String;
	public var _layerArgs6:String;
	public var _layerArgs7:String;
	public var _layerArgs8:String;
	
	public var runData:IntMap<RunVo>;
	/**任务类型*/
	public var MissionType:Int;
	
	//单资源 无缝连接图层
	//public var OncPicArr:Array<String>;
	/**载具*/
	public var vehicle:Int;
	
	//public var Monsters:Array<Array<String>>;
	
	public function new() 
	{
		runData = new IntMap();
	}
	
	public function readXml(data:Dynamic):Void
	{
		
		Id = data.Id;
		MapId = data.MapID;
		RoomType = data.RoomType;
		Round = data.RoundNum;
		Events = parseEvent(data.PlayEvents);
		EndName = data.EndCondition;
		vehicle = data.Vehicle;
		
		MissionType = data.MissionType;
		
		_layerArgs1 = Std.string(data.Foreground_1);
		_layerArgs2 = Std.string(data.Middle_2_1);
		_layerArgs3 = Std.string(data.Middle_2_2);
		_layerArgs4 = Std.string(data.Middle_2_3);
		_layerArgs5 = Std.string(data.Surface_3);
		_layerArgs6 = Std.string(data.Vision_4);
		_layerArgs7 = Std.string(data.Clouds_5);
		_layerArgs8 = Std.string(data.Sky_6);
		var tempArr:Array<String> = [];
		tempArr.push(_layerArgs1);
		tempArr.push(_layerArgs2);
		tempArr.push(_layerArgs3);
		tempArr.push(_layerArgs4);
		tempArr.push(_layerArgs5);
		tempArr.push(_layerArgs6);
		tempArr.push(_layerArgs7);
		tempArr.push(_layerArgs8);
		var vo:RunVo;
		for (i in 0...tempArr.length) {
			vo = new RunVo();
			vo.runType = StringUtils.GetInt(tempArr[i].split(",")[0]);
			vo.runSpeed = StringUtils.GetInt(tempArr[i].split(",")[1]);
			runData.set(i, vo);
		}
		
		//切割数据
		//var str:String =  data.OneTier;
		//OncPicArr = new Array();
		//OncPicArr = str.split("|");
		//str = data.MonsterList;
		//Monsters = parseEvent(str);
	}
	
	public function initDefaultValues():Void {
	
	}
	private function parseEvent(data:Dynamic):Array<Array<String>>
	{
		var temp = [];
		var ary1 = [];
		var ary2 = [];
		temp = Std.string(data).split("|");
		for (i in 0...temp.length) 
		{
			var str = temp[i];
			ary2 = str.split(",");
			ary1.push(ary2);
		}
		
		return ary1;
	}
}