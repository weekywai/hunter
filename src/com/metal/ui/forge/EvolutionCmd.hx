package com.metal.ui.forge;

import com.metal.component.GameSchedual;
import com.metal.config.BagType;
import com.metal.config.EquipProp;
import com.metal.config.SfxManager;
import com.metal.enums.BagInfo;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgUI;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.TexturePackerPlay;
import com.metal.utils.AlertTips;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;
/**
 * 进阶
 * @author hyg
 */
class EvolutionCmd extends ForgetBase
{
	private var meterailArr:Array<ItemBaseInfo>;
	private var selectMeterail:Array<ItemBaseInfo>;
	public function new(data:Dynamic) 
	{
		super(data);
	}
	function onInitComponent(owner:Widget):Void 
	{
		//_widget = UIBuilder.get("evolution");
		meterailArr = new Array();
		selectMeterail = new Array();
		setData();
		onEnabled();
	}

	/*设置数据*/
	override private function setData():Void
	{
		if (_unparent || goodsInfo == null) return;
		
		
		
		if (_widget.getChildAs("selectEquip", Button).numChildren > 0)_widget.getChildAs("selectEquip", Button).removeChildren();
		
		//装备展示图
		var widgetPanel:Widget = new Widget();
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/big/' + goodsInfo.ResId + '.png' ,x:-85,y:-85} );
		var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(goodsInfo.itemId,3) ,x:-95,y:-92} );
		var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(goodsInfo.itemId, 2), x: -113 , y: -110 } );
		widgetPanel.addChild(quality);
		widgetPanel.addChild(img);
		widgetPanel.addChild(quality_1);
		
		_widget.getChildAs("selectEquip", Button).addChild(widgetPanel);
		_widget.getChildAs("goodsNames", Text).text = goodsInfo.itemName;
		var starPanel:VBox = _widget.getChildAs("starPanel", VBox);
		if (starPanel.numChildren > 0) starPanel.removeChildren();
		for (j in 0...goodsInfo.Upgrade)
		{
			var star:Bmp = UIBuilder.create(Bmp, { src:"ui/forge/xingxing.png" } );
			star.scaleX = 1.5;
			star.scaleY = 1.5;
			starPanel.addChild(star);
		}
		
		if (Std.is(goodsInfo, WeaponInfo))
		{
			_widget.getChildAs("typeName", Text).text = "攻击";
			_widget.getChildAs("typeValue", Text).text = "+" + goodsInfo.Att;
			_widget.getChildAs("level", Text).resetFormat(EquipProp.levelColor(goodsInfo.InitialQuality), 24);
			_widget.getChildAs("level", Text).text = "LV:" + goodsInfo.strLv;
		}else if(Std.is(goodsInfo, ArmsInfo)){
			_widget.getChildAs("typeName", Text).text = "生命";
			_widget.getChildAs("typeValue", Text).text = "+" + (goodsInfo.Hp);
			_widget.getChildAs("level", Text).resetFormat(EquipProp.levelColor(goodsInfo.InitialQuality), 24);
			_widget.getChildAs("level", Text).text = "LV:" + goodsInfo.strLv;
		}
		
		
		var listPanel:Widget = _widget.getChildAs("listPanel", Widget);
		if (listPanel.numChildren > 0) listPanel.removeChildren();
		
		
		/**初始化进阶材料*/
		meterailArr = [];
		selectMeterail = [];
		var bag:BagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		for (j in 0...bag.itemArr.length)
		{
			if (bag.itemArr[j].itemId == goodsInfo.itemId && bag.itemArr[j].keyId!=goodsInfo.keyId) 
			{ 
				
				meterailArr.push (bag.itemArr[j]);
			}
		}
		if (meterailArr.length <= 0)_widget.getChildAs("tiptxt", Text).visible = true;
		else 
			_widget.getChildAs("tiptxt", Text).visible = false;
		var setGodos:Map<Int,Dynamic> = new Map();
		for (i in 0...meterailArr.length)
		{	
			var tempInfo = cast meterailArr[i];
			
			//品质
			var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId), x:13, y:13 } );
			var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId,0), x:5, y:4 } );
			
			
			var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png' , x:15, y:15 } );
			
			var oneGoods = UIBuilder.buildFn('ui/forge/oneGoods.xml')( { } );
			setGodos.set(i, oneGoods);
			oneGoods.x = (oneGoods.width+25) * (i % 4);
			oneGoods.y = 183 * (Std.int(i / 4) % 4);
			oneGoods.getChildAs("img", Bmp).addChild(quality);
			oneGoods.getChildAs("img", Bmp).addChild(img);
			oneGoods.getChildAs("img", Bmp).addChild(quality_1);
			listPanel.addChild(oneGoods);
			listPanel.h = 280 * (Std.int(i / 4) % 4);
			
			oneGoods.mouseChildren = false;
			
			for (j in 0...tempInfo.Upgrade)
			{
				oneGoods.getChildAs("star" + (j+1), Bmp).visible = true;
			}
			
			oneGoods.addEventListener(MouseEvent.CLICK, function(e) {
					SfxManager.getAudio(AudioType.Btn).play();
					var oneData:Dynamic = cast tempInfo;
					var selectImg:Text = oneGoods.getChildAs("selectTxt", Text);
					
					if (Std.int(goodsInfo.strLv) != Std.parseInt(tempInfo.strLv))
					{
						AlertTips.openTip("进阶装备与材料装备等级不同", "tipPopup");
					}else{
						selectImg.visible = !selectImg.visible;
						if (selectImg.visible)
						{
							for (j in 0...selectMeterail.length)
							{
								
								selectMeterail.splice( j, 1);
							}
							for (key in setGodos.keys())
							{
								setGodos.get(key).getChildAs("selectTxt", Text).visible = false;
							}
							selectMeterail.push(oneData);
							selectImg.visible = true;
						}else
						{
							for (j in 0...selectMeterail.length)
							{
								if (oneData.itemId == selectMeterail[j].itemId && oneData.keyId == selectMeterail[j].keyId)
								{
									selectMeterail.splice( j, 1);
									break;
								}
							}
							
							//consumptionArr.remove(tempInfo);
						}
					}
				} );
			
			oneGoods.getChildAs("goodsName", Text).text = tempInfo.itemName;
			if (tempInfo.strLv == null) oneGoods.getChildAs("strLv", Text).text = "";
			else oneGoods.getChildAs("strLv", Text).text = "Lv."+tempInfo.strLv;
		}
	}
	private function onEnabled():Void
	{
		_widget.getChildAs("selectEquip", Button).onRelease = selectEquip_click;
		_widget.getChildAs("suerEvo", Button).onRelease = suerEvo_click;
	}
	/*点击选择进阶装备*/
	private function selectEquip_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_STR);
	}
	/*进阶*/
	private function suerEvo_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		if (selectMeterail.length <= 0 )
		{
			AlertTips.openTip("选择相同装备作材料", "tipPopup");
		}else if (goodsInfo == null || goodsInfo.Upgrade>=goodsInfo.InitialQuality )
		{
			AlertTips.openTip("已达等级上限", "tipPopup");
		}else{
			_widget.getChildAs("effPanel", Widget).removeChildren();
					
			var eff:TexturePackerPlay = new TexturePackerPlay();
			eff.effectPlay("effect/T001", "T00100");
			_widget.getChildAs("effPanel", Widget).addChild(eff);
			eff.onPlay();
			goodsInfo.Upgrade += 1;
			
			notifyRoot(MsgNet.UpdateBag, { type:0, data:selectMeterail } );
			notifyRoot(MsgMission.Update, {type:"forge",data:{id:6, info:goodsInfo } });
			notifyRoot(MsgMission.Forge, 7);
			setData();
		}
	}
}