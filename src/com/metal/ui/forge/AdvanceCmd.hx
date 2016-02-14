package com.metal.ui.forge;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.AdvanceInfo;
import com.metal.proto.impl.GonUpGroupInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.AdvanceManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.forge.component.DetailAnalysis;
import com.metal.ui.forge.ForgeCmd.ForgeUpdate;
import com.metal.utils.BagUtils;
import de.polygonal.core.sys.SimEntity;
import haxe.ds.IntMap;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
/**
 * ...
 * @author hyg
 */
class AdvanceCmd extends ForgetBase
{
	//进阶装备数据
	private var advanceInfo:AdvanceInfo;
	private var meterailMap:IntMap<GonUpGroupInfo>;
	private var isMetaril:Bool;//是否有足够材料进化
	public function new() 
	{
		super();
	}
	override public function onInitComponent(owner:SimEntity):Void 
	{
		//ForgeCmd.forgeType = "advance";
		_widget = UIBuilder.get("advanced");
		meterailMap = new IntMap();
		super.onInitComponent(owner);
	}
	/**
	 * 
	 *设置数据*/
	override public function setData(data:Dynamic):Void
	{
		super.setData(data);
		if (_goodsInfo == null) return;
		setMaterial();
		
	}
	/*设置背包中可作为强化的材料*/
	override private function setMaterial():Void
	{
		
		//强化材料显示
		var listPanel:Widget = _widget.getChildAs("listPanel", Widget);
		if (listPanel.numChildren > 0) listPanel.removeChildren();
		
		var levelUpItemId:Int = _goodsInfo.LevelUpItemID;
		if (levelUpItemId == -1) 
		{
			_widget.getChildAs("tiptxt", Text).visible = true;
			return;
		}else{
			_widget.getChildAs("tiptxt", Text).visible = false;
		}
		var materialInfo:AdvanceInfo = AdvanceManager.instance.getProtpAdvance(levelUpItemId);
		notify(MsgUIUpdate.ForgeUpdate, {type:ForgeUpdate.Price,data: "消耗金币:" +materialInfo.NeedGold} );
		var desti:DetailAnalysis = new DetailAnalysis();
		var materialArr:Array<Array<Int>> = desti.analysis(materialInfo.Mat);
		isMetaril = true;
		
		for (i in 0...materialArr.length)
		{	
			var tempInfo = cast GoodsProtoManager.instance.getItemById(materialArr[i][0]);
			//trace("==material===" + materialArr[i][0]);
			var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png' , x:15, y:15 } );
			//品质
			var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId), x:13, y:13 } );
			var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId,0), x:5, y:4 } );
			
			var oneGoods = UIBuilder.buildFn('ui/forge/oneGoods.xml')( { } );
			
			oneGoods.x = (oneGoods.width+25) * (i % 4);
			oneGoods.y = 183 * (Std.int(i / 4) % 4);
			oneGoods.getChildAs("img", Bmp).addChild(quality);
			oneGoods.getChildAs("img", Bmp).addChild(img);
			oneGoods.getChildAs("img", Bmp).addChild(quality_1);
			
			listPanel.addChild(oneGoods);
			listPanel.h = 280 * (Std.int(i / 4) % 4);
			
			oneGoods.mouseChildren = false;
			
			var selectImg:Text = oneGoods.getChildAs("selectTxt", Text);
			selectImg.visible = true;
			
			if (!BagUtils.isBag(materialArr[i][0]))
			{
				selectImg.text = "材料不足";
				isMetaril = false;
			}
			
			//
			
			//oneGoods.addEventListener(MouseEvent.CLICK, function(e) { 
					//var oneData:GonUpGroupInfo = Reflect.getProperty(oneGoods, "listInfo");
					//var selectImg:Text = oneGoods.getChildAs("selectTxt", Text);
					//selectImg.visible = !selectImg.visible;
					//
					//if (selectImg.visible)
					//{
						//if (meterailMap.get(oneData.itemId) == null) meterailMap.set(oneData.itemId,oneData);
					//}else
					//{
						//meterailMap.remove(oneData.itemId);
					//}
				//} );
			
			oneGoods.getChildAs("goodsName", Text).text = tempInfo.itemName;
			if (tempInfo.strLv == null) oneGoods.getChildAs("strLv", Text).text = "";
			else oneGoods.getChildAs("strLv", Text).text = "Lv."+tempInfo.strLv;
		}
	}
	/**
	 * @param	e
	 *点击进阶
	 * */
	public function submit(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		if (_goodsInfo == null)
		{
			sendMsg(MsgUI.Tips, { msg:"请选择进化装备", type:TipsType.tipPopup} );
			return;
		}else if (!isMetaril)
		{
			if (_widget.getChildAs("tiptxt", Text).visible)
			{
				sendMsg(MsgUI.Tips, { msg:"等级上限", type:TipsType.tipPopup} );
			}else
			{
				sendMsg(MsgUI.Tips, { msg:"材料不足", type:TipsType.tipPopup} );
			}
			return;
		}else
		{
			var levelUpItemId:Int = cast(GoodsProtoManager.instance.getItemById(_goodsInfo.itemId), WeaponInfo).LevelUpItemID;
			if (levelUpItemId == -1) return;
			var materialInfo:AdvanceInfo = AdvanceManager.instance.getProtpAdvance(levelUpItemId);
			var _playerInfo:PlayerInfo = PlayerUtils.getInfo();
			if (_playerInfo.getProperty(PlayerPropType.GOLD) < materialInfo.NeedGold)
			{
				sendMsg(MsgUI.Tips, { msg:"金币不足", type:TipsType.tipPopup} );
				return;
			}
			
			var desti:DetailAnalysis = new DetailAnalysis();
			var materialArr:Array<Array<Int>> = desti.analysis(materialInfo.Mat);
			
			
			var removeMat:Array<ItemBaseInfo> = [_goodsInfo];
			for (j in 0...materialArr.length)
			{
				removeMat.push(BagUtils.getOneBagInfo(materialArr[j][0]));
			}
			notifyRoot(MsgNet.UpdateBag, { type:0, data:removeMat } );
			//更新背包或者装备背包
			var item:ItemBaseInfo = GoodsProtoManager.instance.getItemById(levelUpItemId);
			if (_goodsInfo.itemIndex >= 1000)
			{
				_goodsInfo.itemIndex -= 1000;
				if (_goodsInfo.Kind == ItemType.IK2_GON)
				{
					notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.WEAPON, data:item});
				}
				else if (_goodsInfo.Kind == ItemType.IK2_ARM)
				{
					notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:item});
				}
			}else {
				notifyRoot(MsgNet.UpdateBag, { type:1, data:[item] } );
			}
			item.itemIndex = _goodsInfo.itemIndex;
			notifyRoot(MsgPlayer.UpdateMoney, -materialInfo.NeedGold);
			
			_goodsInfo = item;
			setData(_goodsInfo);
			
			notifyRoot(MsgMission.Update, { type:"forge", data: { id:12, info:_goodsInfo }} );
			notifyRoot(MsgMission.Forge, 8);
			notify(MsgUIUpdate.ForgeUpdate, {type:ForgeUpdate.Success});
		}
	}
}