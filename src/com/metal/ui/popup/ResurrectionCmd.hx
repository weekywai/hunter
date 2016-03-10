package com.metal.ui.popup;

import com.metal.component.BattleSystem;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerUtils;
import com.metal.ui.BaseCmd;
import de.polygonal.core.sys.Component;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;

/**
 * 是否复活
 * @author hyg
 */
class ResurrectionCmd extends BaseCmd
{
	private var _price:Int;
	public function new(price:Int) 
	{
		_price = price;
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("resurrection");
		super.onInitComponent();
		onEnable();
		GameProcess.instance.pauseGame(true);
	}
	private function onEnable():Void
	{
		_widget.getChildAs("suerBtn", Button).onRelease = suerBtn_click;
		_widget.getChildAs("closeBtn", Button).onRelease = closeBtn_click;
	}
	/*确定复活*/
	private function suerBtn_click(e):Void
	{
		if (PlayerUtils.getInfo().getProperty(PlayerPropType.GEM) < _price)
		{
			_widget.getChildAs("Load", Text).text = "钻石不足";
			_widget.getChild("suerBtn").visible = false;
			return;
		}
		notifyRoot(MsgPlayer.UpdateGem, -_price);
		GameProcess.instance.pauseGame(false);
		SfxManager.getAudio(AudioType.Btn).play();
		
		var e = PlayerUtils.getPlayer();
		var arr =e.observable.getObserverList();
		//e.getObservable().clear(true);
		for (o in arr) 
		{
			//PlayerUtils.getPlayer().getObservable().detach(o);
			//e.attach(o);
			o.onUpdate(MsgActor.Respawn, e, null);
		}
		trace(arr);
		//e.notify(MsgActor.Respawn);
		//PlayerUtils.getPlayer().notify(MsgActor.Respawn);
		
		//复活增加关卡时间
		//notify(MsgUIUpdate.UpdateCountDown, 30);
		_widget.getParent("popup").free();
		dispose();
	}
	/*关闭直接退出游戏*/
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