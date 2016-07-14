package com.metal.ui.forge;

import com.metal.component.BagpackSystem;
import com.metal.config.ItemType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.proto.impl.DecompositionInfo;
import com.metal.proto.manager.DecompositionManager;
import com.metal.proto.manager.GoodsProtoManager;
import de.polygonal.core.sys.SimEntity;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;

using com.metal.proto.impl.ItemProto;
/**
 * ...分解
 * @author hyg
 */
class DecompositionCmd extends ForgetBase
{
	private var consumptionArr:Array<ItemBaseInfo>;
	private var txtStr:String;
	public function new() 
	{
		super();
	}
	override public function onInitComponent(owner:SimEntity):Void 
	{
		_widget = UIBuilder.get("decomposition");
		//ForgeCmd.forgeType = "decomposition";
		consumptionArr = new Array();
		super.onInitComponent(owner);
	}
	
	override public function setData(data:Dynamic):Void
	{
		super.setData(data);
		var listPanel:Widget = _widget.getChildAs("listPanel", Widget);
		if (listPanel.numChildren > 0) listPanel.removeChildren();
		var bagInfo = GameProcess.instance.getComponent(BagpackSystem).bagData;
		var num:Int = 0;
		for (item in bagInfo.itemArr)
		{	
			if (item.Kind == ItemType.IK2_GON || item.Kind == ItemType.IK2_ARM)
			{
				var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + item.ResId + '.png' ,x:15,y:15} );
				//品质
				var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(item.ID), x:13, y:13 } );
				var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(item.ID,0), x:5, y:4 } );
				
				var oneGoods = UIBuilder.buildFn('ui/forge/oneGoods.xml')( { } );
				
				oneGoods.x = (oneGoods.width+25) * (num % 4);
				oneGoods.y = 183 * Std.int(num / 4);
				oneGoods.getChildAs("img", Bmp).addChild(quality);
				oneGoods.getChildAs("img", Bmp).addChild(img);
				oneGoods.getChildAs("img", Bmp).addChild(quality_1);
				
				listPanel.addChild(oneGoods);
				listPanel.h = 280 * (Std.int(num / 4) % 4);
				
				num++;
				
				for (j in 0...(item.vo.Upgrade))
				{
					oneGoods.getChildAs("star" + (j+1), Bmp).visible = true;
				}
				oneGoods.mouseChildren = false;
				//点击选择分解的装备
				oneGoods.addEventListener(MouseEvent.CLICK, function(e) {
						var selectImg:Text = oneGoods.getChildAs("selectTxt", Text);
						selectImg.visible = !selectImg.visible;
						
						
						if (selectImg.visible)
						{
							consumptionArr.push(item);
						}else
						{
							for (i in 0...consumptionArr.length)
							{
								var consumItem = consumptionArr[i];
								if (item.ID == consumItem.ID && item.vo.keyId == consumItem.vo.keyId)
								{
									consumptionArr.splice( i, 1);
									break;
								}
							}
							//consumptionArr.remove(tempInfo);
						}
					} );
				
				oneGoods.getChildAs("goodsName", Text).text = item.Name;
				if (item.vo.strLv == null) oneGoods.getChildAs("strLv", Text).text = "";
				else oneGoods.getChildAs("strLv", Text).text = "Lv."+item.vo.strLv;
			}
		}
	}
	/**点击分解*/
	public function submit(e):Void
	{
		if (consumptionArr.length <= 0)
		{
			sendMsg(MsgUI.Tips, { msg:"选择分解的装备", type:TipsType.tipPopup} );
		}else
		{
			sendMsg(MsgUI.Tips, { msg:"确定分解所选择的装备？", type:TipsType.tipPopup, callback:callBackFun} );
		}
	}
	/**确定分解*/
	private function callBackFun(flag:Bool):Void
	{
		if (!flag) return;
		txtStr = "获得物品：";
		var itemArr:Array<Int> = [];
		for (item in consumptionArr)
		{
			var weaponInfo = cast item;
			//trace(item);
			var num:Int = (weaponInfo.ID - weaponInfo.SubId * 100) * 10 + weaponInfo.Upgrade;
			var decomInfo:DecompositionInfo = DecompositionManager.instance.getProtoDecom(num);
			//txtStr += "\n";
			decomData(decomInfo);
			itemArr.push(weaponInfo.ID);
			
		}
		notifyRoot(MsgNet.UpdateBag, { type:0, data:itemArr } );
		sendMsg(MsgUI.Tips, { msg:txtStr, type:TipsType.tipPopup} );
		notifyRoot(MsgMission.Update, {type:"forge",data:{id:13 }} );
		notifyRoot(MsgMission.Forge, 9);
		setData(null);
	}
	/*装备分解处理*/
	private function decomData(_decomInfo:DecompositionInfo):Void
	{
		var goods:Array<Int> = [];
		for (data in _decomInfo.Items)
		{
			var num:Int = Math.floor(Math.random() * 100);
			if (num <= data[1])
			{
				if (data[0] != 10201)
				{
					for (i in 0...data[2])
					{
						var itemInfo = Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(data[0])));
						goods.push(data[0]);
						txtStr += itemInfo.Name+" x" + data[2] + "   ";
					}
				}else
				{
					notifyRoot(MsgPlayer.UpdateMoney, data[2]);
					txtStr += "金钱 x" + data[2] + "   ";
				}
			}
		}
		if(goods.length>0)
			notifyRoot(MsgNet.UpdateBag, { type:1, data:goods } );
	}
}