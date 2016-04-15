package com.metal.ui.popup;
import com.metal.component.BattleSystem;
import com.metal.config.SfxManager;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;

/**
 * ...暂停战斗提示界面
 * @author hyg
 */
class StopGame extends BaseCmd
{

	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("resurrection");
		super.onInitComponent();
		GameProcess.instance.pauseGame(true);
		var btn:Button;
		_widget.getChildAs("yesBtn", Button).onRelease = suerBtn_click;
		_widget.getChildAs("noBtn", Button).onRelease = closeBtn_click;
	}
	/**继续游戏*/
	private function suerBtn_click(e):Void
	{
		GameProcess.instance.pauseGame(false);
		SfxManager.getAudio(AudioType.Btn).play();
		_widget.getParent("popup").free();
		
		dispose();
	}
	/*退出游戏*/
	private function closeBtn_click(e):Void
	{
		GameProcess.instance.pauseGame(false);
		SfxManager.getAudio(AudioType.Btn).play();
		var battle:BattleSystem = GameProcess.root.getComponent(BattleSystem);
		//trace("" + battle.currentStage().DuplicateType);
		_widget.getParent("popup").free();
		if (battle.currentStage().DuplicateType == 9)
		{
			sendMsg(MsgUI.BattleResult, battle.currentStage());//胜利界面
		}else
		{
			sendMsg(MsgUI.BattleFailure);
			
		}
		notifyRoot(MsgStartup.Finishbattle);
		sendMsg(MsgUI2.Control, false);
		dispose();
	}
}