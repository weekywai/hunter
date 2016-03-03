package com.metal.ui.reward;

import com.metal.component.GameSchedual;
import com.metal.component.RewardComponent;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.NoviceOpenType;
import com.metal.message.MsgMission;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.LiveNessInfo;
import com.metal.proto.manager.LiveNessManager;
import com.metal.ui.BaseCmd;
import com.metal.utils.FileUtils;
import com.metal.utils.SavaTimeUtil;
import de.polygonal.core.event.IObservable;
import haxe.ds.IntMap;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Progress;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author zxk
 */
class RewardCmd extends BaseCmd
{
	/**活跃度数值*/
	private var livelyNum:Float = 0;
	private var mainStack:MainStack;
	private var _newbieFun:Dynamic;
	public function new(data:Dynamic) 
	{
		if (data != null) livelyNum = data;
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("reward");
		super.onInitComponent();
		mainStack = UIBuilder.getAs("allView", MainStack);
		initUI();
	}
	override function onRemoveComponent() 
	{
		trace("remove");
		super.onRemoveComponent();
	}
	
	override public function onNotify(type:Int, sender:IObservable, userData:Dynamic):Void
	{
		if (_unparent)
			return;
		switch(type)
		{
			case MsgUIUpdate.Reward:
				cmd_Reward(userData);
			case MsgUIUpdate.NewBie:
				cmd_NewBie(userData);
		}
		
	}
	
	private function initUI():Void
	{
		setData(null);
	}
	private function cmd_Reward(data:Dynamic):Void
	{
		setData(data);
	}
	private function cmd_NewBie(data:Dynamic):Void
	{
		if (data == NoviceOpenType.NoviceText28) {
			if (_newbieFun != null){
				_newbieFun(null);
				_newbieFun = null;
			}
		}
	}
	
	/**设置数据*/
	private function setData(data:Dynamic):Void
	{
		if (_unparent) return;
		var rewardComp:RewardComponent = GameProcess.root.getComponent(RewardComponent);
		
		//************连续登陆签到**************//
		var reward1 = _widget.getChildAs("reward1", VBox);
		var rewardArrbtn = rewardComp.rewardArrbtn;
		var playInfo = PlayerUtils.getInfo();
		var signInNum = playInfo.getProperty(PlayerPropType.DAY);
		
		for (k in 0...signInNum)
		{
			rewardArrbtn[k] = true;
		}
		
		for (i in 0...rewardArrbtn.length)
		{
			//trace(get_btn.rewardArrbtn[i]+"======" + signInNum);
			var REwindow1 = UIBuilder.buildFn("ui/reward/REwindow1.xml")();
			//REwindow1.name = "list" + i;
			reward1.addChild(REwindow1);
			//REwindow1.getChildAs("getBtn", Button).name = "getBtn" + i;
			REwindow1.getChildAs("day", Text).text = "第" + (i + 1) + "天";
			REwindow1.getChildAs("jewel", Text).text = "钻石+" + Std.string(10*i+10);
			REwindow1.getChildAs("gold", Text).text =  "金币+" + Std.string(1000*i+1000);
			var getBtn:Button = REwindow1.getChildAs("getBtn", Button);
			if (rewardArrbtn!=null && rewardArrbtn[i]==true)
			{
				getBtn.format.color = 0xb8ffff;
				getBtn.text = "已领取";
				getBtn.disabled = true;
			}else
			{
				 //trace(SavaTime.rewardExits + "================="+signInNum);
				if ((SavaTimeUtil.rewardExits && i==signInNum)||(i==0&&signInNum==0))
				{
					REwindow1.getChildAs("getBtn", Button).onPress = function(e)
					{
						SfxManager.getAudio(AudioType.t001).play();
						//发送金币和钻石数值
						var gold:Int = (100*i+100);
						var diamond:Int = (10 * i + 10);
						notifyRoot(MsgPlayer.UpdateMoney, gold);
						notifyRoot(MsgPlayer.UpdateGem, diamond);
						//GameProcess.root.notify(MsgPlayer.UpdateMoney, jinbi);
						//GameProcess.root.notify(MsgPlayer.UpdateGem, zuanshi);
						getBtn.disabled = true;
						getBtn.text = "已领取";
						notifyRoot(MsgMission.UpdateReward, {type:"online",data:i});
						signInNum = i + 1;
					}
					if (i == 0)
						_newbieFun = REwindow1.getChildAs("getBtn", Button).onPress;
				}else
				{
					getBtn.format.color = 0xb8ffff;
					getBtn.text = "待签";
					getBtn.disabled = true;
				}
			}
			
		}
		
		
		
		//********************活跃度*******************************//
		var activePanel = _widget.getChildAs("reward2-1", VBox);
		if (activePanel.numChildren > 0) activePanel.removeChildren();
		
		var infoMap:IntMap<LiveNessInfo> = rewardComp.getLiveNesss();
		var livelyBtn:Button;
		for (j in 1...11)
		{
			var liveInfo = infoMap.get(j);
			var oneActive = UIBuilder.buildFn("ui/reward/reward2-1.xml")();
			oneActive.name = "list" + j;
			livelyBtn = oneActive.getChildAs("livelyBtn" , Button);
			//if (liveInfo.isDraw!=1)activePanel.addChild(oneActive);
			oneActive.getChildAs("msg", Text).text = liveInfo.name;
			oneActive.getChildAs("lively", Text).text = "" + liveInfo.Point;
			if (liveInfo.Num >= liveInfo.Count)
			{
				oneActive.getChildAs("part", Text).text = liveInfo.Count + "/" + liveInfo.Count;
				livelyBtn.text = "领取";
				livelyBtn.disabled = false;
			}else
			{
				oneActive.getChildAs("part", Text).text = liveInfo.Num + "/" + liveInfo.Count;
			}
			//是否已领取
			if (liveInfo.isDraw==1)
			{
				livelyBtn.text = "已领取";
				livelyBtn.disabled = true;
				livelyNum += liveInfo.Point;
				
			}else
			{
				var currActieNum:Text = _widget.getChildAs("currActieNum", Text);
				_widget.getChildAs("livelyNum", Progress).value = livelyNum + liveInfo.Point;
				currActieNum.text = "当前活跃度(" + livelyNum + "/100)";
				livelyBtn.onPress = function(e)
				{
					SfxManager.getAudio(AudioType.Btn).play();
					var btn = e.currentTarget;
					if (liveInfo.Num >= liveInfo.Count)
					{
						trace(liveInfo.Num+">>>"+liveInfo.Count);
						btn.disabled = true;
						btn.format.color = 0xb8ffff;
						btn.text = "已领取";
						liveInfo.isDraw = 1;
						livelyNum += liveInfo.Point;
						_widget.getChildAs("livelyNum", Progress).value = livelyNum;
						currActieNum.text = "当前活跃度(" + livelyNum + "/100)";
						var diamond:Int = 10;//暂时奖励
						notifyRoot(MsgPlayer.UpdateGem, diamond);
						notifyRoot(MsgMission.UpdateReward, {type:"active", data:liveInfo});
					}else {
						trace(liveInfo.TaskType);
						if (liveInfo.TaskType == 1)//普通副本
						{
							mainStack.show("through");
							sendMsg(MsgUI.Through);
						}else if (liveInfo.TaskType == 2||liveInfo.TaskType == 3||liveInfo.TaskType == 4||liveInfo.TaskType == 5)//类型副本
						{
							mainStack.show("endless");
							sendMsg(MsgUI.EndlessCopy);
						}else if (liveInfo.TaskType == 6||liveInfo.TaskType == 7||liveInfo.TaskType == 8)//锻造
						{
							mainStack.show("forge");
							sendMsg(MsgUI.Forge);
						}
					}
				}
			}
			//if (liveInfo.isDraw != 1)activePanel.addChild(oneActive);
			activePanel.addChild(oneActive);
			
		}
		_widget.getChildAs("livelyNum", Progress).value = livelyNum;
		_widget.getChildAs("currActieNum", Text).text = "当前活跃度(" + livelyNum + "/100)";
		FileUtils.setFileData(infoMap, FilesType.Active);
	}
	override public function onDispose():Void
	{
		_widget.free();
		super.onDispose();
	}
	
	//private function livelyClick(e:MouseEvent) :Void
	//{
		//SfxManager.getAudio(AudioType.t001).play();
		//if (livelyNum < 100)
		//{
			//livelyNum += 10;
			//_widget.getChildAs("livelyNum", Progress).value = livelyNum;
			//switch(livelyNum)
			//{
				//case 30:
					//_widget.getChildAs("livelyBtn0", Button).text = "可领取";
				//case 60:
					//_widget.getChildAs("livelyBtn1", Button).text = "可领取";
				//case 90:
					//_widget.getChildAs("livelyBtn2", Button).text = "可领取";
			//}
		//}
		//else
		//{
			//_widget.getChildAs("ceshi", Button).disabled = true;
		//}
	//}
	
	override public function onTick(timeDelta:Float) 
	{
		//trace("==reward==onTick==" + SavaTime.rewardExits);
		super.onTick(timeDelta);
	}
	override function onClose():Void 
	{
		//_widget.getChildAs("reward1", VBox).removeChildren();
		//_widget.getChildAs("reward2-1", VBox).removeChildren();
		//_widget = null;
		dispose();
		super.onClose();
	}
	
}