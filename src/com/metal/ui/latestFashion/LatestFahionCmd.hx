package com.metal.ui.latestFashion;

import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.ModelManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.popup.TipCmd;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
import spinepunk.SpriteActor;

/**
 * 时装
 * @author hyg
 */
class LatestFahionCmd extends BaseCmd
{
	private var leftModelContainer:Widget;
	private var mainStack:MainStack;
	public function new() 
	{
		super();
		
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("latestFashion");
		super.onInitComponent();
		mainStack = UIBuilder.getAs("allView", MainStack);
		initModel();
	}
	/**初始化模型*/
	private function initModel() :Void
	{
		_widget.getChild("fashion1").skin = UIBuilder.skins.get("fashionImg2")();
		
		leftModelContainer = _widget.getChildAs("leftModel", Widget);
		if (leftModelContainer.numChildren > 0) leftModelContainer.removeChildren();
		var leftModel:SpriteActor = new SpriteActor('model/player/p001/', 'model', 2, 2);
		leftModelContainer.addChild(leftModel);
		leftModel.point(55, 125);
		leftModel.setAnimation('idle_1');
		_widget.getChildAs("tipTxt", Text).text = "装备信息:\n生命 +3000    攻击 +1000\n" + "累计充值500元可获得蛇束，\n立刻享受10倍躶体属性加成！！";
		_widget.getChildAs("getBtn", Button).onPress = leftModel_click;
	}
	/**左边普通皮肤*/
	private function leftModel_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		var info = PlayerUtils.getInfo();
		if (info.getProperty(PlayerPropType.ROLEID) != 1002) {
			sendMsg(MsgUI.Tips, { msg:"是否立刻充值500元！", type:TipsType.buyTip} );
			var tipCmd:TipCmd = new TipCmd();
			tipCmd.onInitComponent();
			tipCmd.callbackFun.addOnce(buyFun);
		}else {
			sendMsg(MsgUI.Tips, { msg:"你已经获得此装束！", type:TipsType.tipPopup} );
		}
	}
	private function buyFun(flag:Bool)
	{
		if (!flag)
			return;
			
		notifyRoot(MsgPlayer.UpdateGem, 9000 * (1 + 0.8));
		var info = PlayerUtils.getInfo();
		info.res = 1002;
		var modelInfo = ModelManager.instance.getProto(info.res);
		modelInfo.skin = 2;
		notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.ROLEID, data:1002 } );//更新记录
		notify(MsgUIUpdate.UpdateModel);
		if (mainStack.numChildren > 0) 
		{
			mainStack.removeChildren();
		}
		notify(MsgUIUpdate.UpdataReturnBtn, true);
		sendMsg(MsgUI.Tips, { msg:"恭喜你获得此装束！\n生命 +3000    \n攻击 +1000", type:TipsType.tipPopup} );
	}
	override function onClose():Void
	{
		dispose();
		super.onClose();
	}
}