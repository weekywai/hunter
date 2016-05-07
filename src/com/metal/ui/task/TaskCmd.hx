package com.metal.ui.task;

import com.metal.component.TaskSystem;
import com.metal.config.SfxManager;
import com.metal.enums.TaskInfo;
import com.metal.message.MsgMission;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.proto.impl.QuestInfo;
import com.metal.ui.BaseCmd;
import haxe.ds.IntMap;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;

/**
 * ...
 * @author zxk
 */
class TaskCmd extends BaseCmd
{
	/**主线任务关卡*/
	private var taskId:Int;
	/**按钮判断*/
	private var taskInfo:TaskInfo;
	
	/**测试按钮累计*/
	private var count1:Int = 0;
	private var count2:Int = 0;

	public function new(data:Dynamic) 
	{
		if (data != null) taskId = data;
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("activity");
		super.onInitComponent();
		initUI();
		
		onEnable();
	}
	
	private function initUI():Void
	{
		setData(null);
	}
	
	
	/**设置数据*/
	private function setData(data:Dynamic):Void
	{
		if (_unparent) return;
		/*主线任务*/
		var task1 = _widget.getChildAs("task1", VBox);
		if (task1.numChildren > 0) task1.removeChildren();
		var questInfo:IntMap<QuestInfo> = cast(GameProcess.root.getComponent(TaskSystem), TaskSystem).taskMap;
		//trace("questInfo==="+questInfo);
		for (i in questInfo.keys())
		{
			var info:QuestInfo = questInfo.get(i);
 			if(info.Type == 0)
			{
				var _upInfo:QuestInfo = questInfo.get(info.RepeatType);
				if ( (info.RepeatType == 0 && info.vo.State != 2) || info.vo.State != 2)
				{
					var ReTask1 = UIBuilder.buildFn("ui/task/task1.xml")();
					//ReTask1.getChildAs("getBtn", Button).name = "getBtn" + i;
					task1.addChild(ReTask1);
					
					ReTask1.getChildAs("taskname", Text).text = info.Name;
					ReTask1.getChildAs("task_msg", Text).text = info.Desc;
					if (questInfo.get(i).vo.State == 1) {
						//ReTask1.getChildAs("receiveBtn", Button).format.color = 0xff0000;
						ReTask1.getChildAs("receiveBtn", Button).text = "可领取";
						ReTask1.getChildAs("receiveBtn", Button).onPress = function(e)
						{
							SfxManager.getAudio(AudioType.t001).play();
							notifyRoot(MsgPlayer.UpdateGem, info.RewardGold);
							ReTask1.getChildAs("receiveBtn", Button).disabled = true;
							ReTask1.getChildAs("receiveBtn", Button).text = "已领取";
							notifyRoot(MsgMission.Update, { type:"forge", data: info} );
							setData(null);
						}
					}else
					{
						ReTask1.getChildAs("receiveBtn", Button).disabled = false;
						ReTask1.getChildAs("receiveBtn", Button).text = "前 往";
						ReTask1.getChildAs("receiveBtn", Button).onPress = function(e)
						{
							if (questInfo.get(i).RunType == 2)
							{
								sendMsg(MsgUI.Through);
							}
						}
						break;
					}
				}
			}
		}
		
		/*支线任务*/
		var task2 = _widget.getChildAs("task2", VBox);
		if (task2.numChildren > 0) task2.removeChildren();
		for (j in questInfo.keys())
		{
			var info = questInfo.get(j);
			if (info.Type == 1&&info.vo.State != 2)
			{
				var ReTask2 = UIBuilder.buildFn("ui/task/task1.xml")();
				task2.addChild(ReTask2);
				ReTask2.getChildAs("taskname", Text).text = info.Name;
				ReTask2.getChildAs("task_msg",Text).text = info.Desc;
				if(info.vo.State == 1)
				{
					ReTask2.getChildAs("receiveBtn", Button).format.color = 0xff0000;
					ReTask2.getChildAs("receiveBtn", Button).text = "可领取";
					ReTask2.getChildAs("receiveBtn", Button).onPress = function(e)
					{
						SfxManager.getAudio(AudioType.t001).play();
						notifyRoot(MsgPlayer.UpdateMoney, info.RewardSilver);
						notifyRoot(MsgPlayer.UpdateGem, info.RewardGold);
						ReTask2.getChildAs("receiveBtn", Button).disabled = true;
						ReTask2.getChildAs("receiveBtn", Button).text = "已领取";
						notifyRoot(MsgMission.Update, {type:"task", data:info});
						setData(null);
					}
				}else
				{
					ReTask2.getChildAs("receiveBtn", Button).disabled = false;
					ReTask2.getChildAs("receiveBtn", Button).text = "前 往";
					ReTask2.getChildAs("receiveBtn", Button).onPress = function(e)
					{
						if (info.RunType == 2)
						{
							sendMsg(MsgUI.EndlessCopy);
						}else if (info.RunType == 3 || info.RunType == 6 || info.RunType == 12 || info.RunType == 13)
						{
							sendMsg(MsgUI.Forge);
						}else if (info.RunType == 10 )//寻宝
						{
							sendMsg(MsgUI.TreasureHunt);
						}else if (info.RunType == 11)//关卡
						{
							sendMsg(MsgUI.Through);
						}
					}
				}
			}
		}
		task2.refresh();
	}
	
	override public function onDispose():Void
	{
		
		super.onDispose();
	}
	
	private function onEnable():Void
	{
	}
	
	override function onClose():Void 
	{
		dispose();
		//_widget.getChildAs("task1", VBox).removeChildren();
		//_widget.getChildAs("task2", VBox).removeChildren();
		//_widget = null;
		//taskInfo = null;
		super.onClose();
	}
	
}