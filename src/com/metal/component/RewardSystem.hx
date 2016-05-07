package com.metal.component;

import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.TableType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUIUpdate;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.impl.LiveNessInfo;
import com.metal.proto.manager.LiveNessManager;
import com.metal.utils.FileUtils;
import com.metal.utils.SavaTimeUtil;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import haxe.ds.IntMap;

/**
 * ...
 * @author zxk
 */
class RewardSystem extends Component
{
	private var _liveNessList:IntMap<LiveNessInfo>;
	public function getLiveNesss():IntMap<LiveNessInfo> {
		return _liveNessList;
	}
	
	public var rewardArr:Array<Dynamic>;
	public var rewardArrbtn:Array<Bool>;
	public var rewardArrbtn2:Array<Bool>; 
	
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void
	{
		super.onInitComponent();
		cmd_initReward(null);
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type)
		{
			//case MsgNet.UpdataReward:
				//upDateReward(userData);
				//GameProcess.SendUIMsg(MsgUI.RewardPanel, userData);
			case MsgMission.Add:
				cmd_AddReward(userData);
			case MsgStartup.BattleResult:
				cmd_BattleResult(userData);
			case MsgMission.Reward:
				cmd_AddReward(userData);
			case MsgMission.Forge:
				cmd_updateForge(userData);
			case MsgMission.UpdateReward:
				cmd_updateReward(userData);
			case MsgMission.UpdateCopy:
				Cmd_UpdateCopy(userData);
		}
		super.onUpdate(type, source, userData);
	}
	
	override function onDispose():Void
	{
		_liveNessList = null;
		super.onDispose();
	}
	/**
	 * 初始化任务奖励数据
	 * 
	 */
	public function cmd_initReward(data:Dynamic):Void
	{
		rewardArrbtn = [false, false, false, false, false, false, false];
		rewardArrbtn2 = [false, false, false, false, false, false];
		_liveNessList = FileUtils.getActive();
	}
	//更新奖励选项
	private function cmd_AddReward(data:Dynamic):Void
	{
		var info = _liveNessList.get(Std.parseInt(data[0]));
		info.vo.Times = Std.parseInt(data[1]);
		updateSql(info);
		notify(MsgUIUpdate.Reward, data);
	}
	/**更新并保存奖励任务数据*/
	private function cmd_BattleResult(duplicateInfo:DuplicateInfo):Void
	{
		//if (duplicateInfo.DuplicateType == 0)//普通关卡
		//{
			for ( key in _liveNessList.keys())
			{
				var info = _liveNessList.get(key);
				if (info.TaskType == 1 && duplicateInfo.DuplicateType == 0
				||info.TaskType == 2 && duplicateInfo.DuplicateType == 9
				||info.TaskType == 3 && duplicateInfo.DuplicateType == 10
				||info.TaskType == 4 && duplicateInfo.DuplicateType == 11
				||info.TaskType == 5&&duplicateInfo.DuplicateType == 12)
				{
					info.vo.Times += 1;
					if (info.vo.Times >= info.Count )
					{
						info.vo.Times = info.Count;
					}
					updateSql(info);
				}
			}
		//}
	}
	/*特殊副本*/
	private function Cmd_UpdateCopy(userData:Dynamic):Void
	{
		var type:Int = userData;
		for ( key in _liveNessList.keys())
		{
			var info = _liveNessList.get(key);
			if (info.TaskType == 2 && type == 9
			||info.TaskType == 3 && type == 10
			||info.TaskType == 4 && type == 11
			||info.TaskType == 5&&type== 12)
			{
				info.vo.Times += 1;
				if (info.vo.Times >= info.Count )
				{
					info.vo.Times = info.Count;
				}
				updateSql(info);
			}
		}
	}
	/*锻造任务更新*/
	private function cmd_updateForge(userData:Dynamic):Void
	{
		var type:Int = userData;
		for ( key in _liveNessList.keys())
		{
			var info = _liveNessList.get(key);
			if(type == info.TaskType){
				info.vo.Times += 1;
				if (info.vo.Times >= info.Count )
				{
					info.vo.Times = info.Count;
				}
				updateSql(info);
			}
		}
	}
	
	private function cmd_updateReward(userData:Dynamic):Void
	{
		if(userData.type=="online"){
			var i:Int = userData.data;
			notify(MsgNet.UpdateInfo, { type:PlayerProp.DAY, data:i + 1 } );
			rewardArrbtn[i] = true;
			SavaTimeUtil.saveFile();
		}else if (userData.type=="active") {
			var info:LiveNessInfo = userData.data;
			_liveNessList.get(info.Id).vo.Draw = 1;
			updateSql(info);
			
		}
	}
	
	private function updateSql(data:LiveNessInfo)
	{
		RemoteSqlite.instance.updateProfile(TableType.P_Active, data.vo, { Id:data.Id } );
	}
}