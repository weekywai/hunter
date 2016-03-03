package com.metal.ui.battleResult;

import com.metal.component.GameSchedual;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.BagInfo;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.BaseCmd;
import com.metal.utils.DropItemUtils;
import com.metal.utils.FileUtils;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;

/**
 * 胜利结算
 * @author hyg
 */
class BattleResultCmd extends BaseCmd
{
	private var _duplicateInfo:DuplicateInfo;
	private var goldNum:Int = 0;
	private var goodsBox:Widget;
	public function new(data:Dynamic) 
	{
		super();
		_duplicateInfo = data;
		//notifyRoot(MsgView.NewBie, 3);
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		if (_duplicateInfo.DuplicateType == 9)
		{
			notifyRoot(MsgView.NewBie, 33);
		}else if(_duplicateInfo.DuplicateType == 1)
		{
			notifyRoot(MsgView.NewBie, 16);
		}
		
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("overcome");
		goldNum = 0;
		setData();
		_widget.getChildAs("submit", Button).onPress = suerBtn_click;
		
	}
	/**设置数据*/
	private function setData():Void
	{
		goodsBox = _widget.getChildAs("goodsBox", Widget); 
		if (goodsBox.numChildren > 0) goodsBox.removeChildren();
		var rewardGoods:Array<ItemBaseInfo> = [];
		
		var duplicateArr:Array<Array<Int>> = [];
		if (_duplicateInfo.DuplicateType == 0 )
		{
			duplicateArr = DropItemUtils.ordinaryDrop(_duplicateInfo);
		}else if (_duplicateInfo.DuplicateType == 9)
		{
			duplicateArr = DropItemUtils.bossDrop(_duplicateInfo);
		}
		for (i in 0...duplicateArr.length)
		{
			var tempInfo = GoodsProtoManager.instance.getItemById(duplicateArr[i][0]);
			
			var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png' , x:10, y:10 } );
			//品质
			var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId), x:13, y:13 } );
			var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId,0), x:5, y:5 } );
			var oneGoods = UIBuilder.buildFn('ui/popup/oneGoods.xml')( { } );
			var len:Int = duplicateArr.length;
			
			if (duplicateArr.length > 8) len = 8;
			
			oneGoods.x = goodsBox.wparent.w * 0.5 - ((len * 100) * 0.5) + 100 * (i % 8);// (oneGoods.width + 25) * i;
			oneGoods.y = 110 * (Math.floor(i / 8));
			oneGoods.scaleX = 0.7;
			oneGoods.scaleY = 0.7;
			oneGoods.getChildAs("img", Bmp).addChild(quality);
			oneGoods.getChildAs("img", Bmp).addChild(img);
			oneGoods.getChildAs("img", Bmp).addChild(quality_1);
			
			goodsBox.addChild(oneGoods);
			
			oneGoods.getChildAs("goodsName", Text).text = tempInfo.itemName;
			oneGoods.getChildAs("goodsNum", Text).text = "x" + duplicateArr[i][1];
			
			if (duplicateArr[i][0] == 10201)
			{
				//notifyRoot(MsgPlayer.UpdateMoney, duplicateArr[i][1]);
				goldNum += duplicateArr[i][1];
			}
			else
			{
				for(j in 0...duplicateArr[i][1]){
					rewardGoods.push(tempInfo);
				}
			}
		}
		
		var playerInfo:PlayerInfo = PlayerUtils.getInfo();
		if (playerInfo.getProperty(PlayerPropType.THROUGH) < _duplicateInfo.Id && _duplicateInfo.DuplicateType == 0) 
		{
			notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.THROUGH, data:_duplicateInfo.Id});
		}
		notifyRoot(MsgNet.UpdateBag, {type:1, data:rewardGoods});
		setStar();
	}
	/**设置星星等级*/
	private function setStar():Void
	{
		var star:Bmp;
		var count:Float=0.5;
		for (i in 0..._duplicateInfo.rate) 
		{
			count = count * 2;
			star = _widget.getChildAs("star" + (i + 1), Bmp);
			star.alpha = 0;
			star.scaleX = 5;
			star.scaleY = 5;
			star.visible = true;
			star.tween(0.2, { scaleX:1, scaleY:1, alpha:1 } ).delay(0.1*count);
		}
		//用完就清零
		_duplicateInfo.setRate(0);
		//var star_1:Bmp = _widget.getChildAs("star1", Bmp);
		//var star_2:Bmp = _widget.getChildAs("star2", Bmp);
		//var star_3:Bmp = _widget.getChildAs("star3", Bmp);
		//star_1.alpha = 0;
		//star_2.alpha = 0;
		//star_3.alpha = 0;
		//star_1.scaleX = 5;
		//star_1.scaleY = 5;
		//star_2.scaleX = 5;
		//star_2.scaleY = 5;
		//star_3.scaleX = 5;
		//star_3.scaleY = 5;
		//star_1.visible = true;
		//star_2.visible = true;
		//star_3.visible = true;
		//star_1.tween(0.2, { scaleX:1, scaleY:1, alpha:1 } ).delay(0.1);
		//star_2.tween(0.2, { scaleX:1, scaleY:1, alpha:1 } ).delay(0.2);
		//star_3.tween(0.2, { scaleX:1, scaleY:1, alpha:1 } ).delay(0.4);
	}
	/**点击确定*/
	private function suerBtn_click(e):Void
	{
		var num:Int = 1;
		var nn:Int = 1;
		SfxManager.getAudio(AudioType.Btn).play();
		_widget.getParent("popup").free();
		sendMsg(MsgUI2.Loading, true);
		var main = UIBuilder.buildFn('ui/mainIndex.xml')( { } );
		main.show();
		sendMsg(MsgUI.MainPanel);
		notifyRoot(MsgPlayer.UpdateMoney, goldNum);
		
		if (_duplicateInfo.DuplicateType == 9)
		{
			if (num == 1)
			{
				notify(MsgUIUpdate.OpenCopy);
			}else
			{
				notify(MsgView.NewBie, 17);
			}
		}else if(_duplicateInfo.DuplicateType == 1) {
			notifyRoot(MsgView.NewBie, 3);
		}else {
			if (nn == 1)
			{
				notify(MsgUIUpdate.OpenThrough);
			}else
			{
				notifyRoot(MsgView.NewBie, 14);
			}
		}
	}
	override function onClose():Void 
	{
		goodsBox.removeChildren();
		_widget = null;
		//_duplicateInfo = null;
		super.onClose();
	}
	override function onDispose():Void 
	{
		
		super.onDispose();
	}
}