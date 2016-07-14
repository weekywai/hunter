package com.metal.ui.copy;

import com.metal.config.GuideText;
import com.metal.config.PlayerPropType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.manager.DuplicateManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.popup.BattleCmd;
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
		openTip(TipsType.onBattle, GuideText.Duplicate(taskType));
		
		var tipCmd:BattleCmd = new BattleCmd();
		tipCmd.onInitComponent();
		tipCmd.setData(DuplicateManager.instance.getProtoDuplicateByID(checkpoint));
		tipCmd.callbackFun.addOnce(callBackFun);
		
	}
	private function callBackFun(flag:Bool):Void
	{
		//trace("BattleCmd callback " + flag);
		if(flag)
		{
			trace("BattleCmd callback " + flag);
			var _playInfo = PlayerUtils.getInfo();
			var _duplicateInfo:DuplicateInfo = DuplicateManager.instance.getProtoDuplicateByID(checkpoint);
			if (_playInfo.data.POWER >= _duplicateInfo.NeedPower) {
				notifyRoot(MsgMission.UpdateCopy, taskType);
				notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.POWER, data:_playInfo.data.POWER - _duplicateInfo.NeedPower } );
				sendMsg(MsgUI.Battle,checkpoint);
				dispose();
			}else
			{
				openTip("是否购买体力", callBackFun_buy);
			}
		}
	}
	private function callBackFun_buy(flag:Bool):Void
	{
		if (flag)
		{
			var _playInfo = PlayerUtils.getInfo();
			var _duplicateInfo:DuplicateInfo = DuplicateManager.instance.getProtoDuplicateByID(checkpoint);
			notifyRoot(MsgMission.UpdateCopy, taskType);
			notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.POWER, data:_playInfo.data.POWER - _duplicateInfo.NeedPower } );
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