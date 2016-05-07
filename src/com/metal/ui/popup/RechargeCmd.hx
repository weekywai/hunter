package com.metal.ui.popup;

import com.metal.component.BagpackSystem;
import com.metal.component.BattleSystem;
import com.metal.component.GameSchedual;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.BaseCmd;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.EntityManager;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;

/**
 * 是否复活
 * @author hyg
 */
class RechargeCmd extends BaseCmd
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
	/*确定补满子弹*/
	private function suerBtn_click(e):Void
	{
		if (PlayerUtils.getInfo().getProperty(PlayerProp.GOLD) < _price)
		{
			_widget.getChildAs("Load", Text).text = "金币不足";
			_widget.getChild("suerBtn").visible = false;
			return;
		}
		var tempInfo = GameProcess.root.getComponent(BagpackSystem).equipBagData.getItemByKeyId(PlayerUtils.getInfo().WEAPON);
		notifyRoot(MsgNet.BuyFullClip, { weapon:tempInfo, noTip:true} );
		notify(MsgUIUpdate.UpdateBullet, tempInfo);
		//notifyRoot(MsgPlayer.UpdateMoney, -_price);
		GameProcess.instance.pauseGame(false);
		SfxManager.getAudio(AudioType.Btn).play();
		
		_widget.getParent("popup").free();
		dispose();
	}
	/*退出购买*/
	private function closeBtn_click(e):Void
	{
		GameProcess.instance.pauseGame(false);
		SfxManager.getAudio(AudioType.Btn).play();
		_widget.getParent("popup").free();
		
		dispose();
	}
}