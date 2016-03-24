package com.metal.ui.warehouse ;

import com.metal.component.GameSchedual;
import com.metal.config.EquipProp;
import com.metal.config.FilesType;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
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
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.AdvanceInfo;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.DecompositionInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.AdvanceManager;
import com.metal.proto.manager.DecompositionManager;
import com.metal.proto.manager.ForgeManager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.forge.ForgeCmd.ForgeUpdate;
import com.metal.ui.forge.component.DetailAnalysis;
import com.metal.ui.popup.TipCmd;
import com.metal.utils.BagUtils;
import com.metal.utils.FileUtils;
import de.polygonal.core.event.IObservable;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.ObjectMap;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.HBox;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Radio;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

/**
 * ...仓库
 * @author hyg
 */
class WarehouseCmd extends BaseCmd
{
	private var _openType:Int =ItemType.IK2_GON;
	private var _bagInfo:BagInfo;
	private var _equipBagData:BagInfo;
	private var _panel:VBox;
	/**枪*/
	private var _gunInfo:Array<ItemBaseInfo>;
	/**防具*/
	private var _asmInfo:Array<ItemBaseInfo>;
	/**进阶材料*/
	private var _materialInfo:Array<ItemBaseInfo>;
	
	private var _itemTextMap:ObjectMap<ItemBaseInfo,Text>;
	
	private var mainStack:MainStack;
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
	/**已装备图片*/
	private var _dressedBmp:Text;
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
		super();
	}
	
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.Btn).play();
		_itemTextMap = new ObjectMap();
		_widget = UIBuilder.get("warehouse");
		if (_widget == null){
			var mainStack:MainStack = cast(UIBuilder.get("allView"), MainStack);
			mainStack.show('warehouse');
			_widget = UIBuilder.get("warehouse");
		}
		
		isClose = false;
		super.onInitComponent();
		initUI();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgUIUpdate.Warehouse:
				updataPad(userData);
		}
	}
	
	private function initUI():Void
	{
		mainStack = UIBuilder.getAs("allView", MainStack);
		_panel = _widget.getChildAs("scrollPanel", VBox);
		_bagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		_equipBagData = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData;
		
		getItem();		
		setType();
		//setTabListen("knifeTab");
		setTabListen("gunTab",ItemType.IK2_GON);
		setTabListen("armorTab",ItemType.IK2_ARM);
		//setTabListen("petTab");
		setTabListen("propTab",ItemType.IK2_GON_PROMOTED);		
		
		//默认显示类型
		_widget.getChildAs("gunTab", Radio).down();
		setScroll(ItemType.IK2_GON);
		showWeaponPanel();
		notifyRoot(MsgView.NewBie, NoviceOpenType.NoviceText34);
	}
	
	/**设置tab的监听*/
	private function setTabListen(tabName:String,type:Int=0)
	{
		_widget.getChildAs(tabName, Radio).onPress = function(e) 
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
	}
	
	/**更新展示类型数据*/
	private function setType():Void
	{
		_asmInfo = []; 
		_gunInfo = []; 
		_materialInfo = []; 
		//已装备
		for (equipItem in _equipBagData.itemArr)
		{
			if (equipItem.Kind == ItemType.IK2_ARM) 
			{
				_asmInfo.push(equipItem);
			}else if (equipItem.Kind == ItemType.IK2_GON) 
			{
				_gunInfo.push(equipItem);
			}
		}
		_asmInfo = _asmInfo.concat(BagUtils.getItemArrByType(ItemType.IK2_ARM));
		_gunInfo = _gunInfo.concat(BagUtils.getItemArrByType(ItemType.IK2_GON));
		_materialInfo = BagUtils.getItemArrByType(ItemType.IK2_GON_PROMOTED);
	}
	
	/**更新滚动条*/
	private function setScroll(type:Int,isUpdataPad:Bool=true)
	{
		if (_unparent) return;
		if (_panel.numChildren > 0) _panel.removeChildren();
		var itemArr:Array<ItemBaseInfo> = [];		
		//未装备
		switch (type) 
		{
			case ItemType.IK2_ARM:
				itemArr = _asmInfo;
			case ItemType.IK2_GON:
				itemArr = _gunInfo;
		}
		if (type==ItemType.IK2_GON_PROMOTED) 
		{
			_equipPanel.visible = false;
			_materialPanel.visible = true;
			updateMaterialPanel();
		}else 
		{
			_equipPanel.visible = true;
			_materialPanel.visible = false;
			for (i in 0...itemArr.length) {
				//默认显示第一条项目
				if (itemArr[i].itemIndex >= 1000 && isUpdataPad) 
				{
					_itemTextMap.set(itemArr[i],equipGoods(itemArr[i], true));
					updataPad(itemArr[i]);
				}else if (itemArr[i].keyId ==_currentInfo.keyId && !isUpdataPad) 
				{
					_itemTextMap.set(itemArr[i],equipGoods(itemArr[i], true));
					updataPad(itemArr[i]);
				}else 
				{
					_itemTextMap.set(itemArr[i],equipGoods(itemArr[i]));
				}			
			}
		}
		
	}
	/**材料栏*/
	private function updateMaterialPanel()
	{
		var bagData = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		var item:ItemBaseInfo = bagData.getItem(ItemType.AdvanceMaterial_1);
		_materialNum1.text = "X " + (item == null?0:item.itemNum);
		item= bagData.getItem(ItemType.AdvanceMaterial_2);
		_materialNum2.text =  "X " + (item == null?0:item.itemNum);
		item= bagData.getItem(ItemType.AdvanceMaterial_3);
		_materialNum3.text= "X " + (item == null?0:item.itemNum);
	}
	/**滚动条*/
	private function updateScroll()
	{
		for (obj in _itemTextMap.keys()) 
		{
			if (obj.itemIndex >= 1000 || obj.backupIndex!=-1) 
			{
				_itemTextMap.get(obj).text = "已装备";
			}else 
			{
				_itemTextMap.get(obj).text = "";
			}
		}
	}
	
	/*更新滚动条一个项目*/
	private function equipGoods(_info:ItemBaseInfo,showDefault:Bool=false):Text
	{
		var oneGoods = UIBuilder.buildFn("ui/storehouse/oneList.xml")( );
		var weaponRadio:Radio = oneGoods.getChildAs("weaponRadio", Radio);
		if (showDefault) weaponRadio.down();
		weaponRadio.onPress = function(e) {
			updataPad(_info);
		};		
		var text:Text = oneGoods.getChildAs("text", Text);
		if (_info.itemIndex >= 1000 ||_info.backupIndex!=-1) text.text = "已装备";
		//weaponRadio.skinName = "";
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + _info.ResId + '.png', x:0, y:0 } );
		img.mouseEnabled = false;
		
		var weaponShow:Widget = oneGoods.getChild("weaponBmp");
		weaponShow.addChild(img);
		//这里还差一个品质底图颜色
		_panel.addChild(oneGoods);
		return text;
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
		
		_dressedBmp = _widget.getChildAs("dressedBmp", Text);
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
		
		//_rechargeBtn.onPress = function(e) {
			//trace("BuyFullClip");
			//notifyRoot(MsgNet.BuyFullClip, { weapon:_currentInfo, text:_widget.getChildAs("description2", Text)});
		//}
		_rechargeOneBtn.onPress = function(e) {
			trace("BuyOneClip");
			notifyRoot(MsgNet.BuyOneClip, _currentInfo);
		}

		//_maxStrengthenBtn = _widget.getChildAs("maxStrengthenBtn", Button);
		//_maxStrengthenBtn.onPress = function(e) {
			//var playerInfo = PlayerUtils.getInfo();
			//
			//if (playerInfo.getProperty(PlayerPropType.GOLD)<maxStrengthenMoney) 
			//{
				//AlertTips.openTip("金币不足", "tipPopup");
			//}else 
			//{
				//notifyRoot(MsgPlayer.UpdateMoney, -maxStrengthenMoney);
				//var tempInfo = cast _currentInfo;
				//tempInfo.strLv=tempInfo.MaxStrengthenLevel;
				//updataPad(_currentInfo);
				//notify(MsgUIUpdate.ForgeUpdate, {type:ForgeUpdate.Success, data:_currentInfo});
			//}			
		//}
		
	}
	
	//private function addmsg(labelText:String, descriptionText:String) {
		//var label:Text=new Text();
		//label.text = labelText;
		//label.defaults = "Tip";
		//
		//var description:Text=new Text();
		//description.text = descriptionText;
		//description.defaults = "Gold2";
	//}
	
	/**更新面板显示*/
	private function updataPad(_info:ItemBaseInfo)
	{
		this._currentInfo = _info;
		var tempInfo = cast _info;
		_dressedBmp.visible = (_info.itemIndex >= 1000 ||_info.backupIndex!=-1);
		//_dressBtn.visible = !_dressedBmp.visible;		
		
		_itemName.resetFormat(EquipProp.levelColor(cast tempInfo.InitialQuality), 30);
		_itemName.text = tempInfo.itemName;
		
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/big/' + tempInfo.ResId + '.png', x:0, y:0 } );
		img.mouseEnabled = false;	
		_itemImg.topPt = (tempInfo.ResId.substr(0, 2) == "g1")? 15:25;
		_itemImg.freeChildren();
		//weaponImg.skinName = "storelvImg" + tempInfo.InitialQuality;//底纹		
		_itemImg.addChild(img);
		_description.text = tempInfo.Description;		
		
		if (Std.is(tempInfo, WeaponInfo)||Std.is(tempInfo,ArmsInfo)) 
		{
			var weaponLv = EquipProp.Strengthen(cast tempInfo, tempInfo.strLv);
			//强化键
			if (tempInfo.strLv == tempInfo.MaxStrengthenLevel)
			{
				if (tempInfo.LevelUpItemID != -1) {
					_moneyBmp.visible = false;
					_strengthenBtn.text = "进阶";
					_maxStrengthenBmp.visible = false;
					_strengthenBtn.onPress = function (e) { 
						advanceItem(_currentInfo);
					};
					_widget.getChildAs("item4", Text).text = "进阶消耗";
					var materialInfo:AdvanceInfo = AdvanceManager.instance.getProtpAdvance(tempInfo.LevelUpItemID);
					var desti:DetailAnalysis = new DetailAnalysis();
					var materialArr:Array<Array<Int>> = desti.analysis(materialInfo.Mat);
					var needItem:ItemBaseInfo;
					var needList:String="";
					for (i in 0...materialArr.length) 
					{
						needItem = GoodsProtoManager.instance.getItemById(materialArr[i][0], false);
						needList += needItem.itemName+" X" + materialArr[i][1]+"\n";
					}
					needList +="金币 X" +materialInfo.NeedGold;
					trace("materialArr: "+materialArr);
					_widget.getChildAs("description4", Text).text = needList;
				}else {
					_moneyBmp.visible = false;
					_maxStrengthenBmp.visible = true;
					_strengthenBtn.onPress = function (e) { };
					_widget.getChildAs("item4", Text).text = "已满级满阶";
					_widget.getChildAs("description4", Text).text ="";
				}				
			}else 
			{
				_widget.getChildAs("item4", Text).text = "强化消耗";
				var subId=tempInfo.equipType * 1000 + tempInfo.strLv;
				var strengthenInfo = ForgeManager.instance.getProtoForge(subId);
				var nextStrengthenInfo = ForgeManager.instance.getProtoForge(subId + 1);
				strengthenMoney = (nextStrengthenInfo.MaxMoney - strengthenInfo.MaxMoney)*_currentInfo.InitialQuality;
				//trace("nextStrengthenInfo.MaxMoney: "+nextStrengthenInfo.MaxMoney);
				//trace("strengthenInfo.MaxMoney: "+strengthenInfo.MaxMoney);
				//trace("subId: "+subId);
				_widget.getChildAs("description4", Text).text = Std.string(strengthenMoney);
				
				_moneyBmp.visible = true;
				_maxStrengthenBmp.visible = false;
				_strengthenBtn.text = "强化";
				_strengthenBtn.onPress = function(e) {
					var playerInfo = PlayerUtils.getInfo();
					if (playerInfo.getProperty(PlayerPropType.GOLD)<strengthenMoney) 
					{
						sendMsg(MsgUI.Tips, { msg:"金币不足", type:TipsType.tipPopup } );
					}else 
					{
						notifyRoot(MsgPlayer.UpdateMoney, -strengthenMoney);
						var tempInfo = cast _currentInfo;
						tempInfo.strLv++;
						updataPad(_currentInfo);
						//notify(MsgUIUpdate.ForgeUpdate, { type:ForgeUpdate.Success, data:_currentInfo } );
						FileUtils.setFileData(null, FilesType.Bag);
						FileUtils.setFileData(null, FilesType.EquipBag);
						notifyRoot(MsgMission.Update, { type:"forge", data: { id:3, info:_currentInfo }} );
						notifyRoot(MsgMission.Forge, 6);
						notify(MsgUIUpdate.UpdateModel);
						sendMsg(MsgUI.Tips, { msg:"强化成功", type:TipsType.tipPopup } );
						if (_currentInfo.itemIndex >= 1000) {
							if (_currentInfo.Kind == ItemType.IK2_ARM) 
							{
								notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.ARMOR, data:_currentInfo } );
							}else if (_currentInfo.Kind == ItemType.IK2_GON) 
							{
								notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.WEAPON, data:_currentInfo } );
							}
						}
					}			
				}
				
			}
			//_strengthenBtn.visible = !_maxStrengthenBmp.visible;
			//_maxStrengthenBtn.visible=!_maxStrengthenBmp.visible;
			_widget.getChildAs("strengthenLv", Text).text = "" + tempInfo.strLv + "/" + tempInfo.MaxStrengthenLevel;
			
			
			_decomposeBtn.visible = true;
			//装备键
			if (tempInfo.itemIndex>=1000 ||tempInfo.backupIndex!=-1) 
			{
				_dressBtn.onPress = function (e) { };
				//装备中，不可分解
				_decomposeBtn.onPress=function (e) { sendMsg(MsgUI.Tips, { msg:"装备中,不可分解!", type:TipsType.tipPopup } ); };
			}else 
			{
				_dressBtn.text = "装备";
				_dressBtn.onPress = function(e) {	
					SfxManager.getAudio(AudioType.t001).play();
					if (_currentInfo.Kind == ItemType.IK2_GON) {
						changeWeapon(_currentInfo);	
						
					}else if (_currentInfo.Kind == ItemType.IK2_ARM){
						BagUtils.changeEquip(cast _currentInfo, ItemType.IK2_ARM);
						notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.ARMOR, data:_currentInfo } );
						updateScroll();
					}			
				}
				//分解
				_decomposeBtn.onPress = function (e) { 
					sendMsg(MsgUI.Tips, { msg:"分解可获得进阶材料\n确定分解所选择的装备？", type:TipsType.buyTip } );
					var tipCmd:TipCmd = new TipCmd();
					tipCmd.initComponent(null);
					tipCmd.callbackFun.addOnce(callBackFun);					
				};
			}			
			
			if (Std.is(tempInfo, WeaponInfo)) {	
				//_rechargeBtn.visible = true;
				_rechargeOneBtn.visible = true;				
				_widget.getChildAs("item0", Text).text="武器伤害";
				_widget.getChildAs("description0", Text).text = Std.string(Math.floor(cast(_currentInfo,WeaponInfo).Att * cast weaponLv.Attack / 10000));
				
				_widget.getChildAs("item1", Text).text = "属性";
				_widget.getChildAs("item1", Text).visible = true;
				_widget.getChildAs("description1", Text).text = getPropertyString(_currentInfo.Property);
				
				_widget.getChildAs("item2", Text).text = "子弹数";
				_widget.getChildAs("item2", Text).visible = true;
				_widget.getChildAs("description2", Text).text = tempInfo.currentBullet+"/"+tempInfo.currentBackupBullet;
				
				//_widget.getChildAs("item3", Text).text="特性";
				//_widget.getChildAs("description3", Text).text = Std.string(tempInfo.Characteristic);	
				_widget.getChildAs("item3", Text).visible = false;
				_widget.getChildAs("description3", Text).text = "";
			}else if (Std.is(tempInfo,ArmsInfo)) 
			{
				//_rechargeBtn.visible = false;
				_rechargeOneBtn.visible = false;
				_widget.getChildAs("item0", Text).text="生命";
				_widget.getChildAs("description0", Text).text = Std.string(Math.floor(cast(_currentInfo,ArmsInfo).Hp * cast weaponLv.HPvalue / 10000));
				
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
		//_widget.getChildAs("scrollPanel", VBox).removeChildren();
		//EntityManager.resolveEntity("UIManager").detach(this);
		//_widget = null;
		if(isClose != true)dispose();
		super.onClose();
	}
	
	/**武器栏*/
	private function changeWeapon(tempInfo:Dynamic)
	{
		if (!choicing) 
		{
			choicing = true;
			setChiocing(_startWeapon,_startWeapon.y);
			setChiocing(_weapon1,_weapon1.y);
			setChiocing(_weapon2,_weapon1.y);
		}		
		_startWeapon.onPress = function (e)
		{			
			//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText11);
			var schedual = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual);
			SfxManager.getAudio(AudioType.t001).play();
			if(tempInfo.Kind == ItemType.IK2_GON){
				BagUtils.changeEquip(cast tempInfo, ItemType.IK2_GON);
				notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.WEAPON, data:tempInfo});
			}else if (tempInfo.Kind == ItemType.IK2_ARM){
				BagUtils.changeEquip(cast tempInfo, ItemType.IK2_ARM);
				notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:tempInfo});
			}
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
		choicing = false;
		//setData(null);
		_startWeapon.onPress = function (e) { };
		_weapon1.onPress = function (e) { };
		_weapon2.onPress = function (e) { };
		FileUtils.setFileData(null, FilesType.Bag);
		showWeaponPanel();
		//更新scroll
		updateScroll();
		//更新panal
		updataPad(_currentInfo);
		//_dressedBmp.visible = true;		
		//_dressBtn.onPress = function (e) { };
	}

	/**选择提示效果*/
	private function setChiocing(widget:Dynamic,originY:Float)
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
			widget.tween(0.2, { y:originY-10 },"Quad.easeOut" ).onComplete(function () {
				setChiocing(widget,originY);
			});
		}else 
		{
			widget.tween(0.2, { y:originY },"Quad.easeIn").onComplete(function () {
				setChiocing(widget,originY);
			});
		}		
	}
	/*显示装备栏**/
	private function showWeaponPanel()
	{
		//trace("showWeaponPanel");	
		_weaponPanel.visible = true;
		setWeaponBmp(_equipBagData.itemArr[0],_startWeapon);
		setWeaponBmp(_bagInfo.backupWeaponArr.get(1) , _weapon1);
		setWeaponBmp(_bagInfo.backupWeaponArr.get(2),_weapon2);		
	}
	/**武器图片*/
	public static function setWeaponBmp(tempInfo:ItemBaseInfo,widget:Button)
	{
		if (widget.getChild("weaponBmp") != null) widget.removeChild(widget.getChild("weaponBmp"));
		if (tempInfo == null) return; 
		//trace("widget.name: "+widget.name);
		var box = UIBuilder.create(Widget, {
			name:"weaponBmp",
			skinName : "forgelvImg"+tempInfo.InitialQuality,
			children : [
				UIBuilder.create(Bmp, {
					src:'icon/' + tempInfo.ResId + '.png', 
					leftPt:0,
					topPt:(tempInfo.ResId.substr(0,2)!="g1")?20:5,
					scaleX:0.9,
					scaleY:0.9
					})
			]
		});		
		widget.addChild(box);
		widget.setChildIndex(box, widget.numChildren - 1);
	}
	private var txtStr:String;
	/**确定分解*/
	private function callBackFun(flag:Bool):Void
	{
		if (!flag) return;
		txtStr = "获得物品：";
		var itemArr:Array<ItemBaseInfo> = [];
		itemArr.push(_currentInfo);
		var num:Int = _currentInfo.Property * 10 + _currentInfo.InitialQuality;
		trace("_currentInfo.Property: "+_currentInfo.Property);
		trace("_currentInfo.InitialQuality: " + _currentInfo.InitialQuality);
		trace("num: " + num);
		
		var decomInfo:DecompositionInfo = DecompositionManager.instance.getProtoDecom(num);
		decomData(decomInfo);
		
		notifyRoot(MsgNet.UpdateBag, { type:0, data:itemArr } );
		sendMsg(MsgUI.Tips, { msg:txtStr, type:TipsType.tipPopup } );
		notifyRoot(MsgMission.Update, {type:"forge",data:{id:13 }} );
		notifyRoot(MsgMission.Forge, 9);
		
		
		setType();
		setScroll(_openType);
	}
	/*装备分解处理*/
	private function decomData(_decomInfo:DecompositionInfo):Void
	{
		var goods:Array<ItemBaseInfo> = [];
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
						itemInfo = Unserializer.run(Serializer.run(GoodsProtoManager.instance.getItemById(data[0])));
						goods.push(itemInfo);						
					}
					txtStr += itemInfo.itemName+" x" + data[2] + "   ";
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
		if (_playerInfo.getProperty(PlayerPropType.GOLD) < materialInfo.NeedGold)
		{
			sendMsg(MsgUI.Tips, { msg:"金币不足", type:TipsType.tipPopup } );
			return;
		}
		
		
		var desti:DetailAnalysis = new DetailAnalysis();
		var materialArr:Array<Array<Int>> = desti.analysis(materialInfo.Mat);			
		var bagData = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;		
		for (i in 0...materialArr.length)
		{	
			if (bagData.getItem(materialArr[i][0])==null || bagData.getItem(materialArr[i][0]).itemNum<materialArr[i][1])
			{
				sendMsg(MsgUI.Tips, { msg:"材料不足\n分解可获得进阶材料", type:TipsType.tipPopup } );
				return;
			}
		}		
		
		var newInfo = GoodsProtoManager.instance.getItemById(levelUpItemId);
		newInfo.backupIndex = oldInfo.backupIndex;
		newInfo.itemIndex = oldInfo.itemIndex;
		_currentInfo = newInfo;
		
		if (newInfo.itemIndex>=1000) 
		{
			if (newInfo.Kind == ItemType.IK2_GON)
			{
				notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.WEAPON, data:newInfo } );
				showWeaponPanel();
			}
			else if (newInfo.Kind == ItemType.IK2_ARM)
			{
				notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:newInfo});
			}
		}else 
		{
			notifyRoot(MsgNet.UpdateBag, { type:1, data:[newInfo] } );
		}
		if (newInfo.backupIndex!=-1) 
		{
			var gameSchedual:GameSchedual = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual);
			gameSchedual.bagData.setBackup(newInfo,  newInfo.backupIndex);
			showWeaponPanel();
		}
			
			
		var removeMat:Array<ItemBaseInfo> = [oldInfo];
		for (j in 0...materialArr.length)
		{
			for (i in 0...materialArr[j][1]) 
			{
				removeMat.push(BagUtils.getOneBagInfo(materialArr[j][0]));
			}			
		}
		notifyRoot(MsgNet.UpdateBag, { type:0, data:removeMat } );		
		notifyRoot(MsgPlayer.UpdateMoney, -materialInfo.NeedGold);
		notifyRoot(MsgMission.Update, { type:"forge", data: { id:12, info:oldInfo }} );
		notifyRoot(MsgMission.Forge, 8);
		notify(MsgUIUpdate.ForgeUpdate, { type:ForgeUpdate.Success } );
		
		setType();
		setScroll(_openType, false);
		updataPad(_currentInfo);
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