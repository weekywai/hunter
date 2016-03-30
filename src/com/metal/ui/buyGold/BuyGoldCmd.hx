package com.metal.ui.buyGold;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.Gold_Info;
import com.metal.proto.manager.Gold_Manager;
import com.metal.ui.BaseCmd;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;

/**
 * ...
 * @author hyg
 */
class BuyGoldCmd extends BaseCmd
{
	
	private var btnNum:Int = 0;
	private var _btnList:Array<Button>;
	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("gold");
		super.onInitComponent();
		setData();
	}
	private function setData():Void
	{
		var boxPage:VBox = _widget.getChildAs("box",VBox);
		if (boxPage.numChildren > 0) boxPage.removeChildren();
		/*读表*/
		var datas = Gold_Manager.instance.data;
		var key:Int = 1;
		_btnList = [];
		for (i in datas.keys())
		{
			var oneBuy = UIBuilder.buildFn("ui/buyGoldOrDiamonds/OneGold.xml")( );
			boxPage.addChild(oneBuy);
			//trace(Gold_Manager.instance.getProto(key).Proportion);
			
			oneBuy.getChildAs("give", Text).text = "加送"+Gold_Manager.instance.getProto(key).Proportion+"%";
			oneBuy.getChildAs("goldGroup", Text).text = Gold_Manager.instance.getProto(key).Description;
			//oneBuy.getChildAs("goldnum", Text).text = Std.string(Gold_Manager.instance.getProto(key).Gold);
			oneBuy.getChildAs("cost", Text).text = "钻石" + Std.string(Gold_Manager.instance.getProto(key).Price) + "颗";
			var btn = oneBuy.getChildAs("buyBtn", Button);
			btn.onPress = function (e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				btnNum = Lambda.indexOf(_btnList, e.currentTarget);
				buy();
			}
			_btnList[key] = btn;
			key++;
		}
		
	}
	
	private function buy ():Void
	{
		
		var price:String = "";
		if (PlayerUtils.getInfo().getProperty(PlayerPropType.GEM) < Gold_Manager.instance.getProto(btnNum).Price)
		{
			sendMsg(MsgUI.Tips, { msg:"钻石不足", type:TipsType.tipPopup} );
			return;
		}
		
		price = "是否花费" + Std.string(Gold_Manager.instance.getProto(btnNum).Price) + "颗钻石购买金币";
		
		sendMsg(MsgUI.Tips, { msg:price, type:TipsType.buyTip, callback:callBackFun} );
	}
	
	private function callBackFun(flag:Bool):Void
	{
		if (flag) 
		{
			var info:Gold_Info = Gold_Manager.instance.getProto(btnNum);
			var zuanshi:Int = -info.Price;
			var jinbi:Int = Std.int(info.Gold + info.Gold * (info.Proportion / 100));
			notifyRoot(MsgPlayer.UpdateGem, zuanshi);
			notifyRoot(MsgPlayer.UpdateMoney, jinbi);
		}
	}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
	}
	override function onDispose():Void 
	{
		//_widget.getChild("box").removeChildren();
		//_widget = null;
		_btnList = null;
		super.onDispose();
	}
	override function onClose():Void
	{
		dispose();
		super.onClose();
	}
}