package com.metal.ui.forge;

import com.marshgames.openfltexturepacker.TexturePackerImport.TexturePackerFrame;
import com.metal.component.GameSchedual;
import com.metal.config.EquipProp;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.ForgeVo;
import com.metal.enums.NoviceOpenType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.StrengthenInfo;
import com.metal.proto.manager.ForgeManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.forge.ForgeCmd.ForgeUpdate;
import de.polygonal.core.sys.SimEntity;
import haxe.ds.IntMap;
import haxe.Timer;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Progress;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
/**
 * ...
 * @author hyg
 */
class StrengthenCmd extends ForgetBase
{
	//道具信息
	public var iTimesData:ForgeVo;
	//材料选择储存
	private var meterailMap:IntMap<ItemBaseInfo>;
	private var metarialArr:Array<ItemBaseInfo>;
	//强化数据
	private var strengthenInfo:StrengthenInfo;
	//下已等级强化装备信息
	private var nextStrengthenInfo:StrengthenInfo;
	//选择消耗的强化材料
	private var consumptionArr:Array<ItemBaseInfo>;
	
	private var allExp:Int = 0;
	
	
	var frames:Array<TexturePackerFrame>;
	var tilesheet:Tilesheet;
	var idMap:Map<String,Int>;
	var imageNum:Int = 0;
	var effectSp:Sprite;
	
	
	public function new() 
	{
		super();
	}
	
	override public function onInitComponent(owner:SimEntity):Void 
	{
		_widget = UIBuilder.get("strengthen");
		meterailMap = new IntMap();
		metarialArr = [];
		consumptionArr = [];
		super.onInitComponent(owner);
	}
	
	/**设置数据*/
	override public function setData(data:Dynamic):Void
	{
		super.setData(data);
		imageNum = 0;
		if (_goodsInfo == null) 
		{
			_widget.getChildAs("listPanel", Widget).removeChildren();
			return;
		}
		var equipType:Int = 0;
		equipType= _goodsInfo.equipType;
		subId = equipType * 1000 + _goodsInfo.strLv;
		strengthenInfo = ForgeManager.instance.getProtpForge(subId);
		nextStrengthenInfo = ForgeManager.instance.getProtpForge(subId + 1);
		var expValue:Int = (nextStrengthenInfo.MaxExp - Std.int(_goodsInfo.strExp) );
		if (expValue < 0) expValue = 0;
		_widget.getChildAs("needExp", Text).text = "升级还需经验："+Std.string(expValue);
		var totalNum:Int = _goodsInfo.MaxStrengthenLevel;
		var needAllExp:Int = Std.int(ForgeManager.instance.getProtpForge(Std.int(equipType * 1000 + totalNum)).MaxExp - _goodsInfo.strExp);
		if (needAllExp <= 0) needAllExp = 0;
		_widget.getChildAs("needAllExp", Text).text = "满级还需经验：" + Std.string(needAllExp);
		_widget.getChildAs("expValue", Progress).value = _goodsInfo.strExp / nextStrengthenInfo.MaxExp * 100;
		//_widget.getChildAs("needGolds", Text).text = "消耗金币:0" ;
		setMaterial();
	}
	/*设置背包中可作为强化的材料*/
	override private function setMaterial():Void
	{
		//强化材料显示
		var listPanel:Widget = _widget.getChildAs("listPanel", Widget);
		if (listPanel.numChildren > 0) listPanel.removeChildren();
		metarialArr = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData.getUpgradeMaterial(_goodsInfo);
		consumptionArr = [];
		var panelNum:Int = 0;
		for (i in 0...metarialArr.length)
		{	
			var tempInfo = cast metarialArr[i];// cast(GoodsProtoManager.instance.getItemById(10001 + i), GonUpLevelInfo);
			
			var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png' , x:15, y:15 } );
			//品质
			var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId), x:13, y:13 } );
			var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.itemId,0), x:5, y:4 } );
			
			var oneGoods = UIBuilder.buildFn('ui/forge/oneGoods.xml')( { } );
			
			oneGoods.x = (oneGoods.width+25) * (i % 4);
			oneGoods.y = 180 * Std.int(i / 4);
			oneGoods.getChildAs("img", Bmp).addChild(quality);
			oneGoods.getChildAs("img", Bmp).addChild(img);
			oneGoods.getChildAs("img", Bmp).addChild(quality_1);
			
			listPanel.addChild(oneGoods);
			//暂时无法正确获取scroll滑动的高度
			if ((i / 4) % 5 == 0 && i != 0) panelNum += 5;
			if ((i / 4) < 6) {
				listPanel.h = 280 * Std.int(i / 4);
			}else
			{
				listPanel.h = 280 * Std.int(i / 4) - ((i / 4) * (55 + panelNum));
			}
			
			
			for (j in 0...tempInfo.Upgrade)
			{
				oneGoods.getChildAs("star" + (j+1), Bmp).visible = true;
			}
			
			oneGoods.mouseChildren = false;
			//Reflect.setField(oneGoods, "listInfo", tempInfo);
			//点击选择升级材料
			oneGoods.addEventListener(MouseEvent.CLICK, function(e) { 
				
					notifyRoot(MsgView.NewBie, NoviceOpenType.NoviceText23);//选择材料
					
					SfxManager.getAudio(AudioType.Btn).play();
					var selectImg:Text = oneGoods.getChildAs("selectTxt", Text);
					selectImg.visible = !selectImg.visible;
					if (selectImg.visible)
					{
						//if (meterailMap.get(tempInfo.itemId) == null) 
						//{
							consumptionArr.push(cast tempInfo);
							//meterailMap.set(tempInfo.itemId,tempInfo);
						//}
					}else
					{
						for (j in 0...consumptionArr.length)
						{
							if (tempInfo.itemId == consumptionArr[j].itemId && tempInfo.keyId == consumptionArr[j].keyId)
							{
								consumptionArr.splice( j, 1);
								break;
							}
						}
						
						//consumptionArr.remove(tempInfo);
					}
					var needGoldNum:Int = 0;
					for (i in 0...consumptionArr.length)
					{
						needGoldNum += Std.int(consumptionArr[i].StrengthenExp);
					}
					notify(MsgUIUpdate.ForgeUpdate, {type:ForgeUpdate.Price,data: "消耗金币:" +needGoldNum} );
				} );
				
			oneGoods.getChildAs("goodsName", Text).text = tempInfo.itemName;
			oneGoods.getChildAs("strLv", Text).text = "Lv."+tempInfo.strLv;
		}
		
	}
	/**
	 *点击强化
	 */
	public function submit(e):Void
	{
		if (_goodsInfo == null)
			return;
		SfxManager.getAudio(AudioType.Btn).play();
		if (_goodsInfo == null)
		{
			GameProcess.UIRoot.sendMsg(MsgUI.Tips, { msg:"请选择装备！", type:TipsType.tipPopup} );
			return;
		}else if (consumptionArr.length<=0)
		{
			GameProcess.UIRoot.sendMsg(MsgUI.Tips, { msg:"请选择强化材料", type:TipsType.tipPopup} );
			return;
		}else if (_goodsInfo.strLv == _goodsInfo.MaxStrengthenLevel)
		{
			GameProcess.UIRoot.sendMsg(MsgUI.Tips, { msg:"强化等级上限！", type:TipsType.tipPopup} );
			return;
		}else
		{
			allExp = 0;
			if (consumptionArr.length > 0)
			{
				for (i in 0...consumptionArr.length)
				{
					if (consumptionArr[i].StrengthenExp != 0)
					{
						allExp += Std.int(consumptionArr[i].StrengthenExp);
					}
				}
				var _playerInfo:PlayerInfo = PlayerUtils.getInfo();
				if (_playerInfo.getProperty(PlayerPropType.GOLD) < allExp)
				{
					GameProcess.UIRoot.sendMsg(MsgUI.Tips, { msg:"金币不足", type:TipsType.tipPopup} );
					return;
				}
				//先移除
				consumptionArr.push(_goodsInfo);
				notifyRoot(MsgNet.UpdateBag, { type:0, data:consumptionArr } );
				//再添加
				_goodsInfo.strExp += allExp;
				numExp(_goodsInfo.strLv);
				
				if (_goodsInfo.itemIndex >= 1000)
				{
					_goodsInfo.itemIndex -= 1000;
					if (_goodsInfo.Kind == ItemType.IK2_GON)
					{
						trace("weapon");
						notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.WEAPON, data:_goodsInfo});
					}
					else if (_goodsInfo.Kind == ItemType.IK2_ARM)
					{
						trace("armor");
						notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:_goodsInfo});
					}
				}else {
					trace("normal");
					notifyRoot(MsgNet.UpdateBag, { type:1, data:[_goodsInfo] } );
				}
				
				setData(_goodsInfo);
				notifyRoot(MsgPlayer.UpdateMoney, -allExp);
				notifyRoot(MsgMission.Update, { type:"forge", data: { id:3, info:_goodsInfo }} );
				notifyRoot(MsgMission.Forge, 6);
				notify(MsgUIUpdate.ForgeUpdate, { type:ForgeUpdate.Success, data:_goodsInfo } );
				GameProcess.root.notify(MsgUIUpdate.UpdateModel);
			}
		}
	}
	private function callBackFun(flag:Bool):Void
	{
		trace("========callBackFun======"+flag);
	}
	/**升级经验等级判断*/
	private function numExp(currLv:Int):Void
	{
		var strInfo:StrengthenInfo = EquipProp.Strengthen(_goodsInfo, currLv + 1);// ForgeManager.instance.getProtpForge(Std.int(_goodsInfo.itemType * 1000 + (currLv+1)));
		
		if (strInfo.MaxExp < _goodsInfo.strExp)
		{
			currLv += 1;
			numExp(currLv);
		}else
		{
			if (currLv >= _goodsInfo.MaxStrengthenLevel) currLv = _goodsInfo.MaxStrengthenLevel;
			_goodsInfo.strLv = currLv;
		}
	}
	/**升级特效播放*/
	private function onPlay():Void
	{
		imageNum++;
		effectSp.graphics.clear();
		var str:String = Std.string(imageNum);
		if (imageNum < 10) str = "0"+Std.string(imageNum);
		tilesheet.drawTiles(effectSp.graphics, [0, 0, idMap["T00100" + str + ".png"]]);
		
		if (imageNum >= frames.length)
		{
			imageNum = 0;
			shast();
		}
	}
	private function shast():Void
	{
		imageNum = 0;
		for (i in 1...frames.length+1)
		{
			Timer.delay(onPlay, i * 7);
		}
	}
	function onClose():Void 
	{
		_widget.getChildAs("needExp", Text).text = "升级还需经验：";
		_widget.getChildAs("needAllExp", Text).text = "满级还需经验：" ;
		_widget.getChildAs("expValue", Progress).value = 0;
		_widget = null;
		_goodsInfo = null;
	}
}