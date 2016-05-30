package com.metal.ui.warehouse ;

import com.metal.config.BagType;
import com.metal.config.EquipProp;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType.PlayerProp;
import com.metal.config.PropertyType;
import com.metal.config.SfxManager;
import com.metal.enums.BagInfo;
import com.metal.enums.NoviceOpenType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.ProtoUtils;
import com.metal.proto.impl.AdvanceInfo;
import com.metal.proto.impl.DecompositionInfo;
import com.metal.proto.impl.PlayerInfo;
import com.metal.proto.manager.AdvanceManager;
import com.metal.proto.manager.DecompositionManager;
import com.metal.proto.manager.ForgeManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.forge.ForgeCmd.ForgeUpdate;
import com.metal.ui.forge.component.DetailAnalysis;
import com.metal.utils.BagUtils;
import com.particleSystem.ASTypes.B;
import de.polygonal.core.event.IObservable;
import haxe.ds.ArraySort;
import haxe.ds.IntMap;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.HBox;
import ru.stablex.ui.widgets.Progress;
import ru.stablex.ui.widgets.Radio;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Tip;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

using com.metal.proto.impl.ItemProto;
/**
 * ...仓库
 * @author hyg
 */
class WarehouseCmd extends BaseCmd
{
	private var _openType:Int =ItemType.IK2_GON;
	private var _bagInfo:BagInfo;
	private var _panel:VBox;
	/**枪*/
	private var _gunInfo:IntMap<ItemBaseInfo>;
	/**防具*/
	private var _asmInfo:IntMap<ItemBaseInfo>;
	/**进阶材料*/
	private var _materialInfo:Array<ItemBaseInfo>;
	
	private var isClose:Bool;
	
	//物品信息部分
	/**展示的物品名称*/
	private var _itemName:Text;	
	/**展示的物品描述*/
	private var _description:Text;	
	/**展示的物品图片*/
	private var _itemImg:Widget;	
	/**展示的物品属性*/
	private var _itemList:VBox;
	/**装备按钮*/
	private var _dressBtn:Button;
	/**强化按钮*/
	private var _strengthenBtn:Button;
	/**一键强化按钮*/
	//private var _maxStrengthenBtn:Button;
	/**强化已满图片*/
	private var _maxStrengthenBmp:Text;
	/**当前展示的装备*/
	private var _currentInfo:ItemBaseInfo;
	/**升级需要的钱*/
	private var strengthenMoney:Int;
	/**一键强化需要的钱*/
	private var maxStrengthenMoney:Int;
	
	
	/**武器栏*/
	private var _weaponPanel:HBox;
	/**首发武器*/
	private var _startWeapon:Button;
	/**备用武器1*/
	private var _weapon1:Button;
	/**备用武器2*/
	private var _weapon2:Button;
	/**是否正在选择装备*/
	private var choicing:Bool;
	
	//private var _rechargeBtn:Button;
	private var _rechargeOneBtn:Button;
	/**分解按钮*/
	private var _decomposeBtn:Button;
	private var _moneyBmp:Bmp;
	
	/**显示材料的panel*/
	private var _materialPanel:Widget;
	/**显示装备的panel*/
	private var _equipPanel:Widget;
	/**进阶材料1数量*/
	private var _materialNum1:Text;
	/**进阶材料2数量*/
	private var _materialNum2:Text;
	/**进阶材料3数量*/
	private var _materialNum3:Text;
	
	public function new(data:Dynamic) 
	{
		if(data == BagType.OPENTYPE_ARMS)
			_openType = ItemType.IK2_ARM;
		else if(data == BagType.OPENTYPE_WEAPON)
			_openType = ItemType.IK2_GON;
		else
			_openType = ItemType.IK2_GON_PROMOTED;
		super();
	}
	
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.Btn).play();
		_widget = UIBuilder.get("warehouse");
		
		isClose = false;
		super.onInitComponent();
		initUI();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgUIUpdate.Warehouse:
				setData();
				showWeaponPanel();
				updataPad(userData);
		}
	}
	
	private function initUI():Void
	{
		_panel = _widget.getChildAs("scrollPanel", VBox);
		_bagInfo = BagUtils.bag;
		
		getItem();		
		setData();
		//setTabListen("knifeTab");
		setTabListen("gunTab",ItemType.IK2_GON);
		setTabListen("armorTab",ItemType.IK2_ARM);
		//setTabListen("petTab");
		setTabListen("propTab",ItemType.IK2_GON_PROMOTED);		
		
		notifyRoot(MsgView.NewBie, NoviceOpenType.NoviceText34);
	}
	
	/**设置tab的监听*/
	private function setTabListen(tabName:String,type:Int=0)
	{
		var radio:Radio = _widget.getChildAs(tabName, Radio);
		radio.onPress = function(e) 
		{
			_openType = type; 
			setScroll(_openType);
			if (_openType!=ItemType.IK2_GON) 
			{
				_weaponPanel.visible = false;
			}else 
			{
				showWeaponPanel();
			}
		};
		//打开显示类型
		if (_openType == type){
			radio.onPress(null);
			radio.selected = true;
		}
	}
	
	/**更新展示类型数据*/
	private function setData():Void
	{
		if(_asmInfo==null)
			_asmInfo = GoodsProtoManager.instance.getAllItem(ItemType.IK2_ARM); 
		if(_gunInfo==null)
			_gunInfo = GoodsProtoManager.instance.getAllItem(ItemType.IK2_GON);
		//物品需要更新	
		_materialInfo = BagUtils.getItemArrByType(ItemType.IK2_GON_PROMOTED);
		
		for (equipItem in _bagInfo.itemArr)
		{
			//trace(equipItem.ID+" "+ equipItem.vo.Equip);
			if (equipItem.Kind == ItemType.IK2_ARM) 
				_asmInfo.set(equipItem.ID, equipItem);
			else if (equipItem.Kind == ItemType.IK2_GON) 
				_gunInfo.set(equipItem.ID, equipItem);
		}
	}
	
	/**更新滚动条*/
	private function setScroll(type:Int)
	{
		if (_unparent) return;
		if (_panel.numChildren > 0) 
			_panel.removeChildren();
		//未装备
		switch (type) 
		{
			case ItemType.IK2_ARM:
				updateEquipPanel(_asmInfo);
			case ItemType.IK2_GON:
				updateEquipPanel(_gunInfo);
			case ItemType.IK2_GON_PROMOTED:
				_equipPanel.visible = false;
				_materialPanel.visible = true;
				updateMaterialPanel();
		}
	}
	private function updateEquipPanel(itemMap:IntMap<ItemBaseInfo>)
	{
		_equipPanel.visible = true;
		_materialPanel.visible = false;
		//排序方式颜色品质
		var list:Array<ItemBaseInfo> = Lambda.array(itemMap);
		list.sort(function(a, b) {
			if (a.Color == b.Color)
				return 0;	
			if (a.Color > b.Color)
				return 1;
			else 
				return -1;
		});
		for (item in list) {
			if (item.vo != null) {
				//trace(item.vo.Equip);
				if (item.vo.Equip) 
				{
					trace(item.ID);
					equipGoods(item.ID, true);
					updataPad(item.ID);
				}else{
					equipGoods(item.ID);
				}
			}else {
				equipGoods(item.ID);
			}
		}
		/*for (item in itemMap) {
			if (item.vo != null) {
				//默认显示第一条项目
				if (item.vo.Equip) 
				{
					equipGoods(item.ID, true);
					updataPad(item.ID);
				}else{
					equipGoods(item.ID);
				}
			}else {
				equipGoods(item.ID);
			}
		}*/
	}
	/**材料栏*/
	private function updateMaterialPanel()
	{
		var item:ItemBaseInfo = _bagInfo.getItem(ItemType.AdvanceMaterial_1);
		_materialNum1.text = "X " + (item == null?0:item.itemNum);
		item= _bagInfo.getItem(ItemType.AdvanceMaterial_2);
		_materialNum2.text =  "X " + (item == null?0:item.itemNum);
		item= _bagInfo.getItem(ItemType.AdvanceMaterial_3);
		_materialNum3.text= "X " + (item == null?0:item.itemNum);
	}
	
	private function findItem(itemId:Int):ItemBaseInfo
	{
		var info:ItemBaseInfo; 
		switch(_openType) {
		case ItemType.IK2_ARM:	
			info = _asmInfo.get(itemId);
		case ItemType.IK2_GON:	
			info = _gunInfo.get(itemId);
		default:
			info = Lambda.find(_materialInfo, function(e){
				if (e.ID == itemId)
					return true;
				return false;
			});
		}
		return info;
	}
	/*更新滚动条一个项目*/
	private function equipGoods(itemId:Int,showDefault:Bool=false)
	{
		var _info:ItemBaseInfo = findItem(itemId);
		
		var oneGoods = UIBuilder.buildFn("ui/storehouse/OneList.xml")( );
		oneGoods.skinName = GoodsProtoManager.instance.getColorSrc(_info.ID, 4);
		var weaponRadio:Radio = oneGoods.getChildAs("weaponRadio", Radio);
		if (showDefault) weaponRadio.down();
		weaponRadio.onPress = function(e) {
			updataPad(itemId);
		};
		var text:Text = oneGoods.getChildAs("text", Text);
		if(_info.vo!=null)
			if (_info.vo.Equip || _info.vo.sortInt !=-1) 
				text.text = "已装备";
				
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + _info.ResId + '.png', x:0, y:0 } );
		img.mouseEnabled = false;
		
		var weaponShow:Widget = oneGoods.getChild("weaponBmp");
		weaponShow.addChild(img);
		//这里还差一个品质底图颜色
		_panel.addChild(oneGoods);
	}
	/**生成展示的XML信息映射*/
	private function getItem() {
		if (_weaponPanel==null) 
		{
			_weaponPanel = _widget.getChildAs("weaponPanel", HBox);
			_startWeapon = _widget.getChildAs("startWeapon", Button);
			_weapon1 = _widget.getChildAs("weapon1", Button);
			_weapon2 = _widget.getChildAs("weapon2", Button);
		}
		_itemName= _widget.getChildAs("weaponName", Text);
		_itemImg = _widget.getChild("weaponBmp");
		_itemList = _widget.getChildAs("itemList",VBox);		
		_description = _widget.getChildAs("description", Text);
		//按钮部分
		_dressBtn = _widget.getChildAs("dressBtn", Button);
		
		_maxStrengthenBmp = _widget.getChildAs("maxStrengthenBmp", Text);
		_strengthenBtn = _widget.getChildAs("strengthenBtn", Button);
		
		
		//_rechargeBtn=_widget.getChildAs("rechargeBtn", Button);
		_rechargeOneBtn=_widget.getChildAs("rechargeOneBtn", Button);
		_decomposeBtn=_widget.getChildAs("decomposeBtn", Button);
		_moneyBmp = _widget.getChildAs("moneyBmp", Bmp);
		
		_equipPanel=_widget.getChildAs("equipPanel", Widget);
		_materialPanel=_widget.getChildAs("materialPanel", Widget);
		_materialNum1=_widget.getChildAs("materialNum1", Text);
		_materialNum2=_widget.getChildAs("materialNum2", Text);
		_materialNum3=_widget.getChildAs("materialNum3", Text);
		
		_rechargeOneBtn.onPress = function(e) {
			trace("BuyOneClip");
			notifyRoot(MsgNet.BuyOneClip, _currentInfo);
		}
	}
	
	/**更新面板显示*/
	private function updataPad(itemId:Int)
	{
		var _info = findItem(itemId);
		_currentInfo = _info;
		var tempInfo:EquipInfo =  ProtoUtils.castType(_info);
		//_dressBtn.visible = !_dressedBmp.visible;		
		
		_itemName.resetFormat(EquipProp.levelColor(Std.string(tempInfo.Color)), 30);
		_itemName.text = tempInfo.Name;
		var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.ID,3) ,x:0,y:0} );
		var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.ID, 2),x:-18 ,y:-18} );
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/big/' + tempInfo.ResId + '.png', x:0, y:0, mouseEnabled:false } );
		//_itemImg.topPt = (tempInfo.ResId.substr(0, 2) == "g1")? 15:25;
		_itemImg.topPt = 18;
		_itemImg.freeChildren();
		//weaponImg.skinName = "storelvImg" + tempInfo.InitialQuality;//底纹		
		_itemImg.addChild(quality);
		_itemImg.addChild(img);
		_itemImg.addChild(quality_1);
		_description.text = tempInfo.Description;		
		
		if (tempInfo.Kind == ItemType.IK2_GON||tempInfo.Kind == ItemType.IK2_ARM) 
		{
			var weaponLv = EquipProp.Strengthen(tempInfo, (tempInfo.vo != null)?tempInfo.vo.strLv:0);
			var exp = _widget.getChildAs("expValue", Progress);
			var expTxt = _widget.getChildAs("strengthenLv", Text);
			if(tempInfo.vo!=null){
				//强化键
				if (tempInfo.vo.strLv >= tempInfo.MaxStrengthenLevel)
				{
					if (tempInfo.LevelUpItemID != -1) {
						_moneyBmp.visible = false;
						_strengthenBtn.text = "进阶";
						_maxStrengthenBmp.visible = false;
						_strengthenBtn.onPress = function (e) { 
							advanceItem(_currentInfo);
						}
						_widget.getChildAs("item4", Text).text = "进阶消耗";
						var materialInfo:AdvanceInfo = AdvanceManager.instance.getProtpAdvance(tempInfo.LevelUpItemID);
						trace(tempInfo.LevelUpItemID);
						var desti:DetailAnalysis = new DetailAnalysis();
						var materialArr:Array<Array<Int>> = desti.analysis(materialInfo.Mat);
						var needItem:ItemBaseInfo;
						var needList:String="";
						for (i in 0...materialArr.length) 
						{
							needItem = GoodsProtoManager.instance.getItemById(materialArr[i][0], false);
							needList += needItem.Name+" X" + materialArr[i][1]+"\n";
						}
						needList +="金币 X" +materialInfo.NeedGold;
						_widget.getChildAs("description4", Text).text = needList;
					}else {
						_moneyBmp.visible = false;
						_maxStrengthenBmp.visible = true;
						_strengthenBtn.onPress = function (e) { };
						_widget.getChildAs("item4", Text).text = "已满级满阶";
						_widget.getChildAs("description4", Text).text ="";
					}				
				}
				else //升级
				{
					_widget.getChildAs("item4", Text).text = "升级消耗";
					var subId = tempInfo.EquipType * 1000 + tempInfo.vo.strLv;
					var strengthenInfo = ForgeManager.instance.getProtoForge(subId);
					var nextStrengthenInfo = ForgeManager.instance.getProtoForge(subId + 1);
					strengthenMoney = (nextStrengthenInfo.MaxMoney - strengthenInfo.MaxMoney)*_currentInfo.Color;
					_widget.getChildAs("description4", Text).text = Std.string(strengthenMoney);
					
					_moneyBmp.visible = true;
					_maxStrengthenBmp.visible = false;
					_strengthenBtn.text = "升级";
					_strengthenBtn.onPress = function(e) {
						var playerInfo = PlayerUtils.getInfo();
						if (playerInfo.data.GOLD<strengthenMoney) 
						{
							sendMsg(MsgUI.Tips, { msg:"金币不足", type:TipsType.tipPopup } );
						}else 
						{
							notifyRoot(MsgPlayer.UpdateMoney, -strengthenMoney);
							var tempInfo =  ProtoUtils.castType(_currentInfo);
							tempInfo.vo.strLv++;
							updataPad(_currentInfo.ID);
							//notify(MsgUIUpdate.ForgeUpdate, { type:ForgeUpdate.Success, data:_currentInfo } );
							notifyRoot(MsgMission.Update, { type:"forge", data: { id:3, info:_currentInfo }} );
							notifyRoot(MsgMission.Forge, 6);
							//notify(MsgUIUpdate.UpdateModel);
							sendMsg(MsgUI.Tips, { msg:"强化成功", type:TipsType.tipPopup } );
							notifyRoot(MsgNet.UpdateBag, { type:2, data:tempInfo.vo } );
							/*if (_currentInfo.vo.Equip) {
								if (_currentInfo.Kind == ItemType.IK2_ARM) 
								{
									notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.ARMOR, data:_currentInfo } );
								}else if (_currentInfo.Kind == ItemType.IK2_GON) 
								{
									notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.WEAPON, data:_currentInfo } );
								}
							}*/
						}			
					}
				}
				_dressBtn.visible = true;
				_dressBtn.disabled = false;
				_strengthenBtn.visible = true;
				//_maxStrengthenBtn.visible=!_maxStrengthenBmp.visible;
				
				exp.visible = true;
				exp.max = tempInfo.MaxStrengthenLevel;
				exp.value = tempInfo.vo.strLv;
				expTxt.text = "" + tempInfo.vo.strLv + "/" + tempInfo.MaxStrengthenLevel;
			
				
				_decomposeBtn.visible = false;
				//装备键
				if (tempInfo.vo.Equip ||tempInfo.vo.sortInt!=-1) 
				{
					if (tempInfo.Kind == ItemType.IK2_GON && tempInfo.vo.sortInt !=-1) {
						_dressBtn.text = "卸下";
						_dressBtn.onPress = function(e) {
							_bagInfo.setBackup(null, tempInfo.vo.sortInt);
							finishChioce();
						}
					}else {
						_dressBtn.text = "已装备";
						_dressBtn.disabled = true;
					}
					//装备中，不可分解
					//_decomposeBtn.onPress=function (e) { sendMsg(MsgUI.Tips, { msg:"装备中,不可分解!", type:TipsType.tipPopup } ); };
				}else 
				{
					_dressBtn.text = "装备";
					_dressBtn.onPress = function(e) {	
						SfxManager.getAudio(AudioType.t001).play();
						if (_currentInfo.Kind == ItemType.IK2_GON) {
							changeWeapon(_currentInfo);	
							
						}else if (_currentInfo.Kind == ItemType.IK2_ARM){
							notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.ARMOR, data:_currentInfo } );
						}
						equipGoods(_currentInfo.ID, true);
					}
					//分解
					/*_decomposeBtn.onPress = function (e) { 
						sendMsg(MsgUI.Tips, { msg:"分解可获得进阶材料\n确定分解所选择的装备？", type:TipsType.buyTip, callback:callBackFun} );
					};*/
				}			
			}else {//未获得
				exp.visible = false;
				expTxt.text = "";
				_strengthenBtn.visible = false;
				_dressBtn.visible = false;
				_rechargeOneBtn.visible = false;
				_decomposeBtn.text = "100钻石获得";
				_decomposeBtn.visible = true;
				_decomposeBtn.onPress = function (e) { 
					var _playerInfo = PlayerUtils.getInfo();
					if (_playerInfo.data.GEM < 100)
					{
						sendMsg(MsgUI.Tips, { msg:"钻石不足", type:TipsType.tipPopup} );
						return;
					}
					sendMsg(MsgUI.Tips, { msg:"是否使用100钻石购买装备？", type:TipsType.buyTip, callback:buyCallBack} );
				};
			}
			if (tempInfo.Kind == ItemType.IK2_GON) {	
				//_rechargeBtn.visible = true;
				if(tempInfo.vo!=null)
					_rechargeOneBtn.visible = true;			
				_widget.getChildAs("item0", Text).text="武器伤害";
				_widget.getChildAs("description0", Text).text = Std.string(Math.floor(ProtoUtils.castType(_currentInfo).Att * weaponLv.Attack / 10000));
				
				_widget.getChildAs("item1", Text).text = "属性";
				_widget.getChildAs("item1", Text).visible = true;
				_widget.getChildAs("description1", Text).text = getPropertyString(_currentInfo.Property);
				
				_widget.getChildAs("item2", Text).text = "子弹数";
				_widget.getChildAs("item2", Text).visible = true;
				_widget.getChildAs("description2", Text).text = tempInfo.OneClip+"/"+tempInfo.StartClip;
				//_widget.getChildAs("description2", Text).text = tempInfo.vo.Bullets+"/"+tempInfo.vo.Clips;
				
				//_widget.getChildAs("item3", Text).text="特性";
				//_widget.getChildAs("description3", Text).text = Std.string(tempInfo.Characteristic);	
				_widget.getChildAs("item3", Text).visible = false;
				_widget.getChildAs("description3", Text).text = "";
			}
			else if (tempInfo.Kind == ItemType.IK2_ARM) 
			{
				//_rechargeBtn.visible = false;
				_rechargeOneBtn.visible = false;
				_widget.getChildAs("item0", Text).text="生命";
				_widget.getChildAs("description0", Text).text = Std.string(Math.floor(ProtoUtils.castType(_currentInfo).Hp * cast weaponLv.HPvalue / 10000));
				
				_widget.getChildAs("item1", Text).text = "防御";
				_widget.getChildAs("item1", Text).visible = false;
				_widget.getChildAs("description1", Text).text = "";
				
				_widget.getChildAs("item2", Text).text = "数量";
				_widget.getChildAs("item2", Text).visible = false;
				_widget.getChildAs("description2", Text).text = "";
				
				//_widget.getChildAs("item3", Text).text = "特性";
				_widget.getChildAs("item3", Text).visible = false;
				//_widget.getChildAs("description3", Text).text = Std.string(tempInfo.Characteristic);
				_widget.getChildAs("description3", Text).text = "";
			}	
			
		}
			
	}
	
	override function onClose():Void 
	{
		if(isClose != true)dispose();
		super.onClose();
	}
	
	/**武器栏*/
	private function changeWeapon(tempInfo:Dynamic)
	{
		if (!choicing) 
		{
			choicing = true;
			if(_startWeapon.tip==null){
				_startWeapon.tip = UIBuilder.create(Tip, { skinName:"TipBgImg1", padding:22, follow:false } );
				_startWeapon.tip.text = "请选择需要放置的装备栏";
			}
			_startWeapon.tip.showByPos(80, -50);
			setChiocing(_startWeapon, _startWeapon.y);
			setChiocing(_weapon1, _weapon1.y);
			setChiocing(_weapon2, _weapon1.y);
		}	
		
		_startWeapon.onPress = function (e)
		{			
			//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText11);
			var vo:GoodsVo = tempInfo.vo;
			vo.Equip = true;
			//trace("click _startWeapon:"+vo);
			notifyRoot(MsgNet.UpdateBag, { type:2, data:vo } );
			
			notify(MsgUIUpdate.UpdateModel);
			finishChioce();			
		};
		_weapon1.onPress = function (e)
		{
			_bagInfo.setBackup(tempInfo, 1);
			finishChioce();
		};
		_weapon2.onPress = function (e)
		{
			_bagInfo.setBackup(tempInfo, 2);
			finishChioce();
		};
	}
	/**结束选择*/
	private function finishChioce()
	{
		SfxManager.getAudio(AudioType.t001).play();
		choicing = false;
		if(_startWeapon.tip!=null)
			_startWeapon.tip.hide();
		setData();
		showWeaponPanel();
		//更新panal
		updataPad(_currentInfo.ID);
	}

	/**选择提示效果*/
	private function setChiocing(widget:Widget,originY:Float)
	{
		if (!choicing) {
			if (widget.y != originY) {
				widget.tweenStop();
				widget.y=originY;
			}
			return;
		}
		if (widget.y==originY) 
		{
			widget.tween(0.2, { y:originY - 10 }, "Quad.easeOut" ).onComplete(setChiocing, [widget, originY]);
		}else 
		{
			widget.tween(0.2, { y:originY }, "Quad.easeIn").onComplete(setChiocing, [widget, originY]);
		}		
	}
	/*显示装备栏**/
	private function showWeaponPanel()
	{
		//trace("showWeaponPanel");	
		_weaponPanel.visible = true;
		var equips = _bagInfo.getEquiped();
		var weapon = Lambda.find(equips, function(e) {
			if (e.Kind == ItemType.IK2_GON)
				return true;
			return false;
		});
		//trace(weapon.ID);
		setWeaponBmp(weapon, _startWeapon);
		setWeaponBmp(_bagInfo.backupWeaponArr.get(1) , _weapon1);
		setWeaponBmp(_bagInfo.backupWeaponArr.get(2), _weapon2);
	}
	/**武器图片*/
	public function setWeaponBmp(tempInfo:ItemBaseInfo,widget:Button)
	{
		widget.label.text = "";
		var weaponBmp = widget.getChild("weaponBmp");
		if (weaponBmp != null) 
			widget.removeChild(weaponBmp);
		if (tempInfo == null) 
			return;
		weaponBmp = UIBuilder.create(Bmp, {
			name:"weaponBmp",
			src:'icon/' + tempInfo.ResId + '.png', 
			leftPt:6,
			topPt:21
		});
		widget.label.text = tempInfo.ID + "";
		widget.addChild(weaponBmp);
		widget.onPress = function (e)
		{
			var btn:Button = e.currentTarget;
			trace(btn.label.text);
			if (btn.label.text != "")
			{
				var itemId = Std.parseInt(btn.label.text);
				updataPad(itemId);
			}
		};
	}
	/**购买物品*/
	private function buyCallBack(flag:Bool):Void
	{
		if (!flag) return;
		notifyRoot(MsgNet.UpdateBag, { type:1, data:[_currentInfo.ID]} );
		notifyRoot(MsgPlayer.UpdateGem, -100);
		notifyRoot(MsgMission.Update, { type:"forge", data: { id:16 }} );
		setData();
		updataPad(_currentInfo.ID);
	}
	private var txtStr:String;
	/**确定分解*/
	private function callBackFun(flag:Bool):Void
	{
		if (!flag) return;
		txtStr = "获得物品";
		var num:Int = _currentInfo.Property * 10 + _currentInfo.Color;
		trace("_currentInfo.Property: "+_currentInfo.Property);
		trace("_currentInfo.Color: " + _currentInfo.Color);
		trace("num: " + num);
		
		var decomInfo:DecompositionInfo = DecompositionManager.instance.getProtoDecom(num);
		decomData(decomInfo);
		
		notifyRoot(MsgNet.UpdateBag, { type:0, data:[_currentInfo.ID]} );
		sendMsg(MsgUI.Tips, { msg:txtStr, type:TipsType.tipPopup } );
		notifyRoot(MsgMission.Update, {type:"forge",data:{id:13 }} );
		notifyRoot(MsgMission.Forge, 9);
		
		
		setData();
		setScroll(_openType);
	}
	/*装备分解处理*/
	private function decomData(_decomInfo:DecompositionInfo):Void
	{
		var goods:Array<Int> = [];
		var num:Int;
		var itemInfo:ItemBaseInfo = null;
		for (data in _decomInfo.Items)
		{
			num= Math.floor(Math.random() * 100);
			if (num <= data[1])
			{
				if (data[0] != 10201)
				{
					for (i in 0...data[2])
					{
						itemInfo = GoodsProtoManager.instance.getItemById(data[0]);
						goods.push(data[0]);						
					}
					txtStr += itemInfo.Name+" x" + data[2] + "   ";
				}else
				{
					notifyRoot(MsgPlayer.UpdateMoney, data[2]);
					txtStr += "金钱 x" + data[2] + "   ";
				}
			}
		}
		trace("goods: "+goods);
		if(goods.length>0)
			notifyRoot(MsgNet.UpdateBag, { type:1, data:goods } );
	}
	
	/**进阶*/
	public function advanceItem(oldInfo:ItemBaseInfo)
	{
		var levelUpItemId:Int = oldInfo.LevelUpItemID;
		if (levelUpItemId == -1) return;
		var _playerInfo:PlayerInfo = PlayerUtils.getInfo();
		var materialInfo:AdvanceInfo = AdvanceManager.instance.getProtpAdvance(levelUpItemId);
		if (_playerInfo.data.GOLD < materialInfo.NeedGold)
		{
			sendMsg(MsgUI.Tips, { msg:"金币不足", type:TipsType.tipPopup } );
			return;
		}
		
		
		var desti:DetailAnalysis = new DetailAnalysis();
		var materialArr:Array<Array<Int>> = desti.analysis(materialInfo.Mat);	
		for (i in 0...materialArr.length)
		{	
			if (_bagInfo.getItem(materialArr[i][0])==null || _bagInfo.getItem(materialArr[i][0]).itemNum<materialArr[i][1])
			{
				sendMsg(MsgUI.Tips, { msg:"材料不足\n分解可获得进阶材料", type:TipsType.tipPopup } );
				return;
			}
		}		
		
		var newInfo = GoodsProtoManager.instance.getItemById(levelUpItemId);
		newInfo.vo.sortInt = oldInfo.vo.sortInt;
		_currentInfo = newInfo;
		
		if (newInfo.vo.Equip) 
		{
			if (newInfo.Kind == ItemType.IK2_GON)
			{
				notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.WEAPON, data:newInfo } );
				showWeaponPanel();
			}
			else if (newInfo.Kind == ItemType.IK2_ARM)
			{
				notifyRoot(MsgNet.UpdateInfo, {type:PlayerProp.ARMOR, data:newInfo});
			}
		}else 
		{
			notifyRoot(MsgNet.UpdateBag, { type:1, data:[newInfo.ID] } );
		}
		if (newInfo.vo.sortInt!=-1) 
		{
			_bagInfo.setBackup(newInfo,  newInfo.vo.sortInt);
			showWeaponPanel();
		}
			
			
		var removeMat:Array<Int> = [oldInfo.ID];
		for (j in 0...materialArr.length)
		{
			for (i in 0...materialArr[j][1]) 
			{
				removeMat.push(materialArr[j][0]);
			}			
		}
		notifyRoot(MsgNet.UpdateBag, { type:0, data:removeMat } );		
		notifyRoot(MsgPlayer.UpdateMoney, -materialInfo.NeedGold);
		notifyRoot(MsgMission.Update, { type:"forge", data: { id:12, info:oldInfo }} );
		notifyRoot(MsgMission.Forge, 8);
		notify(MsgUIUpdate.ForgeUpdate, { type:ForgeUpdate.Success } );
		
		setData();
		updataPad(_currentInfo.ID);
		sendMsg(MsgUI.Tips, { msg:"进阶成功", type:TipsType.tipPopup } );
	}
	private function getPropertyString(property:Int):String
	{
		var propertyString:String = "";
		switch (property) 
		{
			case PropertyType.Metal:
				propertyString = "金(克木)";
			case PropertyType.Wood:
				propertyString = "木(克土)";
			case PropertyType.Water:
				propertyString = "水(克火)";
			case PropertyType.Fire:
				propertyString = "火(克金)";
			case PropertyType.Earth:
				propertyString = "土(克水)";
			default:
				propertyString = "无";
		}
		return propertyString;
	}
}