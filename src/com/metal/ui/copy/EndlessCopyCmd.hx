package com.metal.ui.copy;

import com.metal.component.GameSchedual;
import com.metal.component.RewardComponent;
import com.metal.component.TaskComponent;
import com.metal.config.FilesType;
import com.metal.config.GuideText;
import com.metal.config.PlayerPropType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.manager.DuplicateManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.popup.BattleCmd;
import com.metal.ui.popup.TipCmd;
import com.metal.utils.FileUtils;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;

/**
 * ...
 * @author hyg
 */
class EndlessCopyCmd extends BaseCmd
{
	private var checkpoint:Int = 0;
	private var taskType:Int ;//任务类型
	public function new() 
	{
		super();
		
	}
	override function onInitComponent():Void 
	{
		_widget = UIBuilder.get("endless");
		
		super.onInitComponent();
		initData();
	}
	private function initData():Void
	{
		
		
		_widget.getChildAs("endlessBtn",Button).onPress = openEndless;
		_widget.getChildAs("ormorBtn",Button).onPress = openOrmor;
		_widget.getChildAs("weaponsBtn",Button).onPress = openWeapons;
		_widget.getChildAs("goldBtn",Button).onPress = openGold;
	}
	/**打开无尽副本*/
	private function openEndless(e):Void
	{
		checkpoint = 9001;
		taskType = 9;
		handler();
		
	}
	/*护甲副本*/
	private function openOrmor(e):Void
	{
		checkpoint = 9003;
		taskType = 10;
		handler();
	}
	/*武器副本*/
	private function openWeapons(e):Void
	{
		checkpoint = 9002;
		taskType = 11;
		handler();
	}
	/*金钱副本*/
	private function openGold(e):Void
	{
		checkpoint = 9004;
		taskType = 12;
		handler();
	}
	/*点击关卡*/
	private function handler():Void
	{
		sendMsg(MsgUI.Tips, { msg:GuideText.Duplicate(taskType), type:TipsType.onBattle} );
		//var onBattle = UIBuilder.buildFn('ui/popup/onBattle.xml') ( { } );
		//onBattle.x = _widget.w * 0.5-930*0.5;
		//onBattle.y = _widget.h * 0.5-444*0.5;
		//onBattle.name = "battleTip";
		//_widget.addChild(onBattle);
		
		var tipCmd:BattleCmd = new BattleCmd();
		tipCmd.onInitComponent();
		tipCmd.setData(DuplicateManager.instance.getProtoDuplicateByID(checkpoint));
		tipCmd.callbackFun.addOnce(callBackFun);
		
	}
	private function callBackFun(flag:Bool):Void
	{
		if(flag)
		{
			var _playInfo = PlayerUtils.getInfo();
			var _duplicateInfo:DuplicateInfo = DuplicateManager.instance.getProtoDuplicateByID(checkpoint);
			if (_playInfo.getProperty(PlayerPropType.POWER) >= _duplicateInfo.NeedPower) {
				cast(GameProcess.root.getComponent(TaskComponent), TaskComponent).searchTask(taskType);
				cast(GameProcess.root.getComponent(RewardComponent), RewardComponent).updateEndlessTask(taskType);
				//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).updatePlayerInfo(_playInfo.getProperty(PlayerPropType.POWER) - _duplicateInfo.NeedPower, PlayerPropType.POWER);
				notifyRoot(MsgPlayer.UpdateInfo,{type:PlayerPropType.POWER,data:_playInfo.getProperty(PlayerPropType.POWER) - _duplicateInfo.NeedPower});
				
				FileUtils.setFileData(_playInfo, FilesType.Player);
				sendMsg(MsgUI.Battle,checkpoint);
				dispose();
			}else
			{
				//var popup = UIManager.Alert({
					//msg:'是否购买体力',
					//content:'buyTip'
				//});
				//popup.show();
				
				sendMsg(MsgUI.Tips, { msg:"是否购买体力", type:TipsType.buyTip} );
				var tipCmd:TipCmd = new TipCmd();
				tipCmd.onInitComponent();
				tipCmd.callbackFun.addOnce(callBackFun_buy);
			}
		}
	}
	private function callBackFun_buy(flag:Bool):Void
	{
		if (flag)
		{
			var _playInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).playerInfo;
			
			var _duplicateInfo:DuplicateInfo = DuplicateManager.instance.getProtoDuplicateByID(checkpoint);
			cast(GameProcess.root.getComponent(TaskComponent), TaskComponent).searchTask(taskType);
			cast(GameProcess.root.getComponent(RewardComponent), RewardComponent).updateEndlessTask(taskType);
			//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).updatePlayerInfo(_playInfo.getProperty(PlayerPropType.POWER) - _duplicateInfo.NeedPower, PlayerPropType.POWER);
			notifyRoot(MsgPlayer.UpdateInfo,{type:PlayerPropType.POWER,data:_playInfo.getProperty(PlayerPropType.POWER) - _duplicateInfo.NeedPower});
			FileUtils.setFileData(_playInfo, FilesType.Player);
			sendMsg(MsgUI.Battle,checkpoint);
			dispose();
		}
	}
	override function onDispose():Void 
	{
		super.onDispose();
	}
	override function onClose():Void 
	{
		dispose();
		super.onClose();
	}
}