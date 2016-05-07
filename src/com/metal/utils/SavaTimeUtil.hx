package com.metal.utils;
import com.metal.component.RewardSystem;
import com.metal.config.FilesType;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
/**
 * ...
 * @author hyg
 */
class SavaTimeUtil
{
	private static var _filePath:String;
	private static var currTime:Array<Int>;
	public static var  rewardExits(get, null):Bool;
	
	public function new() 
	{
		
	}
	public static function readTime():Void
	{
		#if sys
		var path:String = FileUtils.getPath() + "/proto/";
		_filePath = path + "preserveTime.txt";
		if (!FileSystem.exists(path))
		{
			FileSystem.createDirectory(path);
		}
		if (!FileSystem.exists(_filePath)) {
			saveFile();
		}
		
		//read the message
		var sanityCheck:String = File.getContent(_filePath);
		
		var fin = File.read(_filePath, false);
		var lineNum = 0;
		var str:String = fin.readLine();
		currTime = [];
		var strArr = str.split(",");
		for (i in 0...strArr.length)
		{
			currTime.push(Std.parseInt(strArr[i]));
		}
		fin.close();
		#end
	}
	public static function saveFile()
	{
		var f:FileOutput = File.write( _filePath, false );
		f.writeString(getCurrTimes());
		f.close();
	}
	/**获取时间*/
	private static function getCurrTimes():String
	{
		var myDate = Date.now();
		
		var str:String = "";
		
		currTime = [];
		currTime.push(myDate.getFullYear());
		currTime.push(myDate.getMonth()+1);
		currTime.push(myDate.getDate());
		//currTime.push(myDate.getDay());
		currTime.push(myDate.getHours());
		currTime.push(myDate.getMinutes());
		currTime.push(myDate.getSeconds());
		for (i in 0...currTime.length)
		{
			if (i == currTime.length - 1)
			{
				str +=	currTime[i]+""	;
			}else {
				str +=	currTime[i]+","	;
			}
			
		}
		
		return str;
	}
	/**是否恢复体力*/
	public static function isRecovery():Void
	{
		if (currTime != null && currTime.length > 0)
		{
			//var _playInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).playerInfo;
			var nowDate = Date.now();
			if (currTime[0] >= nowDate.getFullYear())
			{
				if (currTime[1] >= nowDate.getMonth()+1)
				{
					if (currTime[2] <= nowDate.getDate())
					{
						if ((nowDate.getDate() - currTime[2]) < 1 )
						{
							if ((nowDate.getHours()-currTime[3])<16)
							{
								var hours =  nowDate.getHours() - currTime[3];
								var minutes =0 ;
								if (hours == 0)
								{
									minutes = nowDate.getMinutes() - currTime[4];
								}else
								{
									minutes = hours * 60 - (60 - nowDate.getMinutes()) + (60 - currTime[4]);
									
								}
								if (minutes / 5 >= 1)
								{
									//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).updatePlayerInfo( _playInfo.getProperty(PlayerProp.POWER) + Math.floor(minutes / 5),PlayerProp.POWER);
									//latestFlag = true;
									//upDate_Vit(null);
									
								}
							}else
							{
								//加满
								//latestFlag = true;
								//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).updatePlayerInfo( 200, PlayerProp.POWER);
								//upDate_Vit(null);
							}
						}else
						{
							//latestFlag = true;
							//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).updatePlayerInfo( 200, PlayerProp.POWER);
							//upDate_Vit(null);
							//加满体力
						}
					}
				}else
				{
					//latestFlag = true;
					//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).updatePlayerInfo( 200, PlayerProp.POWER);
					//upDate_Vit(null);
					//加满体力
				}
			}
		}
	}
	/**签到日期，天数*/
	private static function get_rewardExits():Bool
	{
		readTime();
		var nowDate = Date.now();
		if (currTime != null && currTime.length > 0)
		{
			if (currTime[0] >= nowDate.getFullYear())
			{
				if (currTime[1] >= nowDate.getMonth()+1)
				{
					if (currTime[2] <= nowDate.getDate())
					{
						//trace(nowDate.getDate() + "     ::  " + currTime[2]);
						if (nowDate.getDate()-currTime[2] >= 1)
						{
							var infoMap = cast(GameProcess.root.getComponent(RewardSystem), RewardSystem).getLiveNesss();
							FileUtils.setFileData(infoMap, FilesType.Active);
							return true;
						}else
						{
							return false;
						}
					}
				}
			}
		}
		return false;
	}
}