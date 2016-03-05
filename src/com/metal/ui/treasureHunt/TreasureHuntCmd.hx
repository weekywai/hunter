package com.metal.ui.treasureHunt;

import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.NoviceOpenType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ChestInfo;
import com.metal.proto.manager.ChestManager;
import com.metal.proto.manager.TreasuerHuntManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.forge.component.DetailAnalysis;
import com.metal.ui.popup.GainGoodsCmd;
import com.metal.ui.popup.TipCmd;
import com.metal.utils.FileUtils;
import de.polygonal.core.event.IObservable;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author hyg
 */
class TreasureHuntCmd extends BaseCmd
{
	private var _chestInfo:ChestInfo;
	private var num:Int = 0;
	private var _playerInfo:PlayerInfo;
	private var _newbieFun1:Dynamic;
	public function new() 
	{
		super();
		
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("treasureHunt");
		init();
		super.onInitComponent();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgUIUpdate.NewBie:
				cmd_NewBie(userData);
		}
	}
	/*初始化宝箱*/
	private function init()
	{
		_chestInfo = null;
		num = 0;
		_playerInfo = PlayerUtils.getInfo();
		var treasure1:Widget = UIBuilder.buildFn("ui/treasureHunt/treasure.xml")();
		var treasure2:Widget = UIBuilder.buildFn("ui/treasureHunt/treasure.xml")();
		treasure1.getChildAs("name", Text).text = "中级宝箱";
		treasure1.getChildAs("intro", Text).text = "可获赠一次开启宝箱的机会，宝箱中可开出所有品质的装备。";
		treasure1.getChildAs("des", Text).text = "再购买5次，开启宝箱必然获得紫色装备。";
		treasure1.getChildAs("price", Text).text = "98钻石";
		var silverBtn = treasure1.getChildAs("buyBtn", Button);
		silverBtn.text = "一次寻宝";
		silverBtn.onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
			num = 1;
			_chestInfo = ChestManager.instance.getChest(1);
			if (_playerInfo.getProperty(PlayerPropType.GEM) < _chestInfo.NeedDiamond)
			{
				sendMsg(MsgUI.Tips, { msg:"钻石不足", type:TipsType.tipPopup} );
				return;
			}
			sendMsg(MsgUI.Tips, { msg:"是否花费98钻石购买？", type:TipsType.buyTip} );
			var tipCmd:TipCmd = new TipCmd();
			tipCmd.onInitComponent();
			tipCmd.callbackFun.addOnce(callBackFun);
		}
		_newbieFun1 = silverBtn.onPress;
		
		treasure2.getChildAs("name", Text).text = "高级宝箱";
		treasure2.getChildAs("intro", Text).text = "可获赠十次开启宝箱的机会，宝箱中可开出所有品质的装备。";
		treasure2.getChildAs("des", Text).text = "其中至少有一件紫色装备。";
		treasure2.getChildAs("price", Text).text = "888钻石";
		var goldBtn = treasure2.getChildAs("buyBtn", Button);
		goldBtn.text = "十连抽";
		goldBtn.onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
			num = 2;
			_chestInfo = ChestManager.instance.getChest(2);
			if (_playerInfo.getProperty(PlayerPropType.GEM) < _chestInfo.NeedDiamond)
			{
				sendMsg(MsgUI.Tips, { msg:"钻石不足", type:TipsType.tipPopup} );
				return;
			}
			sendMsg(MsgUI.Tips, { msg:"是否花费888钻石购买十连抽？", type:TipsType.buyTip} );
			var tipCmd:TipCmd = new TipCmd();
			tipCmd.onInitComponent();
			tipCmd.callbackFun.addOnce(callBackFun);
		}
		_widget.getChild("content").addChild(treasure1);
		_widget.getChild("content").addChild(treasure2);
	}
	
	/*确定购买宝箱*/
	private function callBackFun(flag:Bool):Void
	{
		if (flag==true)
		{
			
			var itemIdList:Array<Int> = [];
			var hunt = _playerInfo.getProperty(PlayerPropType.HUNT);
			trace(hunt);
			if (num == 1)
			{
				var jinbi:Int = 500;
				notifyRoot(MsgPlayer.UpdateMoney, jinbi);
				if (hunt%10== 0)
				{
					var itemList:String = TreasuerHuntManager.instance.getChest(4).ItemList;
					var itemArr:Array<String> = itemList.split(",");
					var itemId:Int = Std.parseInt(itemArr[Math.floor(Math.random() * itemArr.length)]);
					itemIdList.push(itemId);
				}
				else
				{
					itemIdList.push(getData(num));
				}
				notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.HUNT, data:hunt + 1 } );
			}
			else if (num == 2)
			{
				var ran:Int = Std.int(Math.random() * 10);
				for (i in 0...10) {
					if (i == ran )
					{
						var itemList:String = TreasuerHuntManager.instance.getChest(4).ItemList;
						var itemArr:Array<String> = itemList.split(",");
						var itemId:Int = Std.parseInt(itemArr[Math.floor(Math.random() * itemArr.length)]);
						itemIdList.push(itemId);
					}
					else
					{
						itemIdList.push(getData(num));
					}
				}
				notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.HUNT, data:hunt + 10 } );
			}
			
			notifyRoot(MsgPlayer.UpdateGem, -_chestInfo.NeedDiamond);
			sendMsg(MsgUI.Tips, { msg:"", type:TipsType.gainGoods} );
			var gainGoods:GainGoodsCmd = new GainGoodsCmd();
			gainGoods.onInitComponent();
			gainGoods.setData(itemIdList);
			
			notifyRoot(MsgMission.Update, { type:"forge", data: { id:10 }} );
			FileUtils.setFileData(_playerInfo, FilesType.Player);
			FileUtils.setFileData(null, FilesType.Bag);
			
			//init();
		}
	}
	/**获取单次抽取的道具*/
	private function getData(num:Int):Int
	{
		
		var hunInfo:ChestInfo; 
		var detail:DetailAnalysis = new DetailAnalysis();
		
		hunInfo = ChestManager.instance.getChest(num);
		var str:String = hunInfo.ItemListGroup;
		str = str.substr(1, str.length-2);
		var indexList:Array<String> = str.split(",");
		//概率
		var probability:Float = Math.random() * 100;
		//随机抽取1~4道具组
		var index:Int = 0;
		if (probability<=30)
		{
			index = 1;
		}else if (probability<=80&&probability>30)
		{
			index = 2;
		}else if (probability<=95&&probability>80)
		{
			index = 3;
		}else if (probability<=100&&probability>95)
		{
			index = 4;
		}
		//Std.parseInt(indexList[Math.floor(Math.random() * (indexList.length + 1))]);
		//获取道具组所有道具
		var itemList:String = TreasuerHuntManager.instance.getChest(index).ItemList;
		//var itemArr:Array<Array<Int>> = detail.analysis(itemList);
		var itemArr:Array<String> = itemList.split(",");
		
		var itemId:Int = Std.parseInt(itemArr[Math.floor(Math.random() * itemArr.length)]);
		return itemId;
	}
	
	private function cmd_NewBie(data:Dynamic):Void
	{
		if (data == NoviceOpenType.NoviceText5) {
			_newbieFun1(null);
		}
	}
	override function onDispose():Void 
	{
		_chestInfo = null;
		_playerInfo = null;
		_newbieFun1 = null;
		super.onDispose();
	}
	override function onClose():Void 
	{
		dispose();
		_widget = null;
		_chestInfo = null;
		super.onClose();
	}
}