package com.metal.ui.buyDiamonds;
import com.metal.config.SfxManager;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.proto.impl.Gold_Info;
import com.metal.proto.manager.DiamondManager;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author hyg
 */
class BuyDiamondsCmd extends BaseCmd
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
		_widget = UIBuilder.get("diamonds");
		initData();
		super.onInitComponent();
	}
	private function initData():Void
	{
		var  boxPage = _widget.getChild("box");
		if (boxPage.numChildren > 0) boxPage.removeChildren();
		var datas = DiamondManager.instance.data;
		var key:Int = 1;
		_btnList = [];
		for (i in datas.keys())
		{
			var oneBuy:Widget =  UIBuilder.buildFn("ui/buyGoldOrDiamonds/OneDiamonds.xml")( );
			boxPage.addChild(oneBuy);
			oneBuy.getChildAs("give", Text).text = "加送"+DiamondManager.instance.getProto(key).Proportion+"%";
			oneBuy.getChildAs("rmb", Text).text = "人民币" + Std.string(DiamondManager.instance.getProto(key).Price)+ "元";
			oneBuy.getChildAs("desc", Text).text = DiamondManager.instance.getProto(key).Description;
			
			
			var buyBtn:Button = oneBuy.getChildAs("buyBtn", Button);
			buyBtn.onPress = function(e)
			{
				btnNum = _btnList.indexOf(e.currentTarget);
				SfxManager.getAudio(AudioType.Btn).play();
				var diamond = DiamondManager.instance.getProto(btnNum);
				var price:String  = "是否花费人民币" + Std.string(diamond.Price) + "元\n购买" + Std.string(diamond.Gold) +"颗钻石";
				sendMsg(MsgUI.Tips, { msg:price, type:TipsType.buyTip, callback:tipCallback} );
				//var tipCmd:TipCmd = new TipCmd();
				//tipCmd.onInitComponent();
				//tipCmd.callbackFun.addOnce(tipCallback);
			}
			_btnList[key] = buyBtn;
			key++;
		}
	}

	private function tipCallback(flag:Bool):Void
	{
		if (flag)
		{
			//trace(Diamond_Manager.instance.getProto(btnNum).Gold);
			var diamond:Gold_Info = DiamondManager.instance.getProto(btnNum);
			var zuanshi:Int = Std.int(diamond.Gold + diamond.Gold * (diamond.Proportion / 100));
			GameProcess.root.notify(MsgPlayer.UpdateGem, zuanshi);
			GameProcess.root.notify(MsgMission.Update, { type:"forge", data: { id:5 }} );
		}
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