package com.metal.ui.warehouse ;
import com.metal.component.GameSchedual;
import com.metal.config.BagType;
import com.metal.config.EquipProp;
import com.metal.config.FilesType;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.BagInfo;
import com.metal.enums.NoviceOpenType;
import com.metal.message.MsgNet;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.ui.BaseCmd;
import com.metal.utils.BagUtils;
import com.metal.utils.FileUtils;
import de.polygonal.core.event.IObservable;
import haxe.ds.IntMap;
import haxe.Serializer;
import haxe.Unserializer;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Box;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.HBox;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

/**
 * ...仓库
 * @author hyg
 */
class WarehouseCmd extends BaseCmd
{
	private var openType:Int = 0;
	private var infoMap:IntMap<WeaponInfo>;
	private var _bagInfo:BagInfo;
	private var _equipBagData:BagInfo;
	private var panel:VBox;
	
	private var mainStack:MainStack;
	private var isClose:Bool;
	
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
	public function new(data:Dynamic) 
	{
		if (data != null) openType = data;
		super();
	}
	
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.Btn).play();
		infoMap = new IntMap();
		
		_widget = UIBuilder.get("warehouse");
		if (_widget == null){
			var mainStack:MainStack = cast(UIBuilder.get("allView"), MainStack);
			mainStack.show('warehouse');
			_widget = UIBuilder.get("warehouse");
		}
		
		isClose = false;
		super.onInitComponent();
		_widget.getChild("Storehouse");
		initUI();
		
	}
	override public function onNotify(type:Int, sender:IObservable, userData:Dynamic):Void
	{
		if (_unparent)
			return;
	}
	private function initUI():Void
	{
		mainStack = UIBuilder.getAs("allView", MainStack);
		panel = _widget.getChildAs("scrollPanel", VBox);
		setData(null);
		//panel.addEventListener(MouseEvent.CLICK, panel_click);
	}
	private function panel_click(e:MouseEvent):Void 
	{
		var mainStack:MainStack = cast(UIBuilder.get("allView"),MainStack);
		mainStack.show('forge');
	}
	private function changeWeapon(tempInfo:Dynamic,oneGoods:Dynamic)
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
			
			notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText11);
			var schedual = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual);
			SfxManager.getAudio(AudioType.t001).play();
			if(tempInfo.Kind == ItemType.IK2_GON){
				BagUtils.changeEquip(cast tempInfo, ItemType.IK2_GON);
				notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.WEAPON, data:tempInfo});
			}else if (tempInfo.Kind == ItemType.IK2_ARM){
				BagUtils.changeEquip(cast tempInfo, ItemType.IK2_ARM);
				notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:tempInfo});
			}
			GameProcess.root.notify(MsgUIUpdate.UpdateModel);
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
		setData(null);
		_startWeapon.onPress = function (e) { };
		_weapon1.onPress = function (e) { };
		_weapon2.onPress = function (e) { };
		FileUtils.setFileData(null, FilesType.Bag);
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
	/*显示**/
	private function showWeaponPanel()
	{
		trace("showWeaponPanel");	
		_weaponPanel.visible = true;
		setWeaponBmp(_equipBagData.itemArr[0],_startWeapon);
		setWeaponBmp(_bagInfo.backupWeaponArr.get(1) , _weapon1);
		setWeaponBmp(_bagInfo.backupWeaponArr.get(2),_weapon2);		
	}
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
					leftPt:-2,
					topPt:-2,
					scaleX:1.2,
					scaleY:1.2
					})
			]
		});		
		widget.addChild(box);
		widget.setChildIndex(box, widget.numChildren - 1);
	}
	/**设置数据*/
	private function setData(data:Dynamic):Void
	{
		if (_unparent) return;
		
		if (panel.numChildren > 0) panel.removeChildren();
		
		_bagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
		_equipBagData = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).equipBagData;
		
		var _itemArr:Array<ItemBaseInfo> = [];		
		if (_weaponPanel==null) 
		{
			_weaponPanel = _widget.getChildAs("weaponPanel", HBox);
			_startWeapon = _widget.getChildAs("startWeapon", Button);
			_weapon1 = _widget.getChildAs("weapon1", Button);
			_weapon2 = _widget.getChildAs("weapon2", Button);
		}
		_weaponPanel.visible = false;
		if (openType==BagType.OPENTYPE_WEAPON ||openType==BagType.OPENTYPE_STORE) showWeaponPanel();
		if (openType == BagType.OPENTYPE_ARMS)//护甲
		{
			_itemArr = BagUtils.getItemArrByType(ItemType.IK2_ARM);
		}else if (openType == BagType.OPENTYPE_WEAPON)//枪械
		{
			_itemArr = BagUtils.getItemArrByType(ItemType.IK2_GON);
		}else//正常打开仓库
		{
			_itemArr = _bagInfo.itemArr;
		}
		
		//装备背包
		for (equipItem in _equipBagData.itemArr)
		{
			if ((openType == BagType.OPENTYPE_ARMS && equipItem.Kind == ItemType.IK2_ARM) || (openType == BagType.OPENTYPE_WEAPON && equipItem.Kind == ItemType.IK2_GON))
			{
				equipGoods(cast equipItem);
			}else if (openType != BagType.OPENTYPE_ARMS && openType != BagType.OPENTYPE_WEAPON)
			{
				equipGoods(cast equipItem);
			}
		}
		//普通背包
		for (i in 0..._itemArr.length)
		{	
			
			var tempInfo = cast _itemArr[i];
			if (openType == BagType.OPENTYPE_STR)
			{
				if (tempInfo.Kind == ItemType.IK2_GON_UPGRADE || tempInfo.Kind == ItemType.IK2_GON_PROMOTED) continue;
			}
			switch(tempInfo.Kind)
			{
				case ItemType.IK2_GON_UPGRADE :
					materialGoods(tempInfo);
				case ItemType.IK2_GON:
					equipGoods(cast tempInfo);
				case ItemType.IK2_GON_PROMOTED:
					materialGoods(cast tempInfo);
				case ItemType.IK2_ARM://护甲
					equipGoods(cast tempInfo);
			}
			
		}
		
		//cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).initBagInfo(_bagInfo, _bagInfo.bagType);
		
		
	}
	/**材料*/
	private function materialGoods(_info:Dynamic):Void
	{
		var tempInfo = cast _info;
		var oneGoods = UIBuilder.buildFn("ui/storehouse/oneList.xml")( );
			//infoMap.set(tempInfo.itemId, tempInfo);
			//oneGoods.name = "list" + i;
			var rechargeBtn:Button = oneGoods.getChildAs("rechargeBtn", Button);
			var bulletTxt:Text = oneGoods.getChildAs("bulletTxt", Text);
			rechargeBtn.visible = false;
			bulletTxt.visible = false;
			var rechargeOneBtn:Button = oneGoods.getChildAs("rechargeOneBtn", Button);
			rechargeOneBtn.visible = false;
			var buyBtn:Button = oneGoods.getChildAs("buyBtn", Button);
			if (openType == BagType.OPENTYPE_STR)//强化选择装备
			{
				buyBtn.text = "确定";				
				if (tempInfo.Kind == ItemType.IK2_GON_UPGRADE)
				{
					buyBtn.visible = false;
				}else
				{
					buyBtn.mouseEnabled = true;
					buyBtn.onPress = function(e) {
						trace("222222222222");
						SfxManager.getAudio(AudioType.Btn).play();
						var mainStack:MainStack = cast(UIBuilder.get("allView"), MainStack);
						mainStack.show("forge");
						sendMsg(MsgUI.Forge, tempInfo);
						dispose();
					};
				}
			}else if (openType == BagType.OPENTYPE_WEAPON||openType == BagType.OPENTYPE_ARMS||openType == BagType.OPENTYPE_STORE)//后面判断无用可删掉，材料不能装备
			{
				if (tempInfo.Kind == ItemType.IK2_GON_UPGRADE || tempInfo.Kind == ItemType.IK2_GON_PROMOTED|| tempInfo.Kind == ItemType.ARMS_TYPE)
				{
					buyBtn.visible = false;
				}else
				{
					buyBtn.text = "装备";
					if (tempInfo.Kind == ItemType.IK2_GON) {
						rechargeBtn.visible = true;
						rechargeOneBtn.visible = true;
						bulletTxt.visible = true;		
						bulletTxt.text = "子弹数 " + tempInfo.currentBullet + "/" + tempInfo.currentBackupBullet;
					}
					rechargeBtn.onPress = function(e) {
						trace("onPress1");
					}
					rechargeOneBtn.onPress = function(e) {
						trace("onPress11");
					}
					buyBtn.onPress = function(e) { 
							trace("onPress dress up111");
							trace("equip: "+tempInfo.Kind);
							SfxManager.getAudio(AudioType.t001).play();
							if (tempInfo.Kind == ItemType.IK2_GON) {
								BagUtils.changeEquip(cast tempInfo, ItemType.IK2_GON);
								notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.WEAPON, data:cast tempInfo});
							}
							else if (tempInfo.Kind == ItemType.IK2_ARM)
							{
								BagUtils.changeEquip(cast tempInfo, ItemType.IK2_ARM);
								notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:cast tempInfo});
							}
							
							GameProcess.root.notify(MsgUIUpdate.UpdataReturnBtn, true);
							
							if (mainStack.numChildren > 0) mainStack.removeChildren();
							dispose();
						};
				}
			}
			panel.addChild(oneGoods);
			
			//装备展示图
			var box = UIBuilder.create(Box, {
				skinName : "forgelvImg"+tempInfo.InitialQuality,
				children : [
					UIBuilder.create(Bmp, {
						src:'icon/' + tempInfo.ResId + '.png', 
						leftPt:-2,
						topPt:-2,
						scaleX:1.2,
						scaleY:1.2
						})
				]
			});
			oneGoods.getChild("color").skinName = "storelvImg" + tempInfo.InitialQuality;
			oneGoods.getChild("goodsImg").addChild(box);
			//var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png', x:0, y:0 } );
			//img.scaleX = 1.2;
			//img.scaleY = 1.2;
			//oneGoods.getChild("goodsImg").addChild(img);
			var t:Text = oneGoods.getChildAs("goodsName", Text);
			t.resetFormat(EquipProp.levelColor(tempInfo.InitialQuality), 30);
			t.text = tempInfo.itemName;
			oneGoods.getChildAs("description", Text).text = tempInfo.Description;
			//var strInfo:StrengthenInfo = ForgeManager.instance.getProtpForge(tempInfo.itemType * 1000 + tempInfo.strLv);
			//if (Std.is(tempInfo, WeaponInfo))
			//{
				//
				oneGoods.getChildAs("typeTxt", Text).text = "";
				oneGoods.getChildAs("material", Text).text = tempInfo.Detail;
				oneGoods.getChildAs("typeValue", Text).text ="";
				oneGoods.getChildAs("characterTxt", Text).text = "";
				oneGoods.getChildAs("characterDesc", Text).text = "";
				oneGoods.getChildAs("Lv", Text).text = "";
			//}
			//
			oneGoods.getChildAs("goodsNum", Text).text = "";//tempInfo.itemNum + "/10";
	}
	/*装备*/
	private function equipGoods(_info:ItemBaseInfo):Void
	{
		var tempInfo = cast _info;
		var oneGoods = UIBuilder.buildFn("ui/storehouse/oneList.xml")( );
			//infoMap.set(tempInfo.itemId, tempInfo);
			//oneGoods.name = "list" + i;
			var buyBtn:Button = oneGoods.getChildAs("buyBtn", Button);
			var rechargeBtn:Button = oneGoods.getChildAs("rechargeBtn", Button);
			var rechargeOneBtn:Button = oneGoods.getChildAs("rechargeOneBtn", Button);
			var bulletTxt:Text = oneGoods.getChildAs("bulletTxt", Text);
			rechargeBtn.visible = false;
			rechargeOneBtn.visible = false;
			bulletTxt.visible = false;
			if (openType == BagType.OPENTYPE_STR)//强化选择装备
			{
				buyBtn.text = "确定";
				buyBtn.mouseEnabled = true;
				buyBtn.onPress = function(e) {
					
					
					notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText22);//强化装备面板
						
					SfxManager.getAudio(AudioType.Btn).play();
					isClose = true;
					var mainStack:MainStack = cast(UIBuilder.get("allView"), MainStack);
					mainStack.show("forge");
					sendMsg(MsgUI.Forge, tempInfo);
					dispose();
				};
			}else if (openType == BagType.OPENTYPE_STORE||openType == BagType.OPENTYPE_WEAPON||openType == BagType.OPENTYPE_ARMS)
			{
				if (tempInfo.Kind == ItemType.IK2_GON_UPGRADE)
				{
					buyBtn.visible = false;
				}
				else
				{
					if (tempInfo.Kind == ItemType.IK2_GON) {
						rechargeBtn.visible = true;
						rechargeOneBtn.visible = true;
						bulletTxt.visible = true;
						bulletTxt.text = "子弹数 " + tempInfo.currentBullet + "/" + tempInfo.currentBackupBullet;
					}
					rechargeBtn.onPress = function(e) {
						//trace("BuyFullClip");
						notifyRoot(MsgNet.BuyFullClip, { weapon:tempInfo, text:bulletTxt});
					}
					rechargeOneBtn.onPress = function(e) {
						//trace("BuyOneClip");
						notifyRoot(MsgNet.BuyOneClip, { weapon:tempInfo, text:bulletTxt});
					}
					if (tempInfo.itemIndex >= 1000)
					{
						buyBtn.text = "已装备";
						buyBtn.disabled = true;
					}else if (tempInfo.backupIndex!=-1) 
					{
						buyBtn.text = "卸下";
						buyBtn.onPress = function(e) {
							_bagInfo.setBackup(null, tempInfo.backupIndex);
							setData(null);
						}
					}else{
						buyBtn.text = "装备";
						buyBtn.onPress = function(e) { 
							trace("onPress dress up");
							if (tempInfo.Kind == ItemType.IK2_GON) {
								changeWeapon(tempInfo,oneGoods);
							}else 
							{
								notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText11);
								var schedual = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual);
								SfxManager.getAudio(AudioType.t001).play();
								if(tempInfo.Kind == ItemType.IK2_GON){
									BagUtils.changeEquip(cast tempInfo, ItemType.IK2_GON);
									notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.WEAPON, data:tempInfo});
								}else if (tempInfo.Kind == ItemType.IK2_ARM){
									BagUtils.changeEquip(cast tempInfo, ItemType.IK2_ARM);
									notifyRoot(MsgNet.UpdateInfo, {type:PlayerPropType.ARMOR, data:tempInfo});
								}
								GameProcess.root.notify(MsgUIUpdate.UpdateModel);
							
								GameProcess.root.notify(MsgUIUpdate.UpdataReturnBtn, true);
								if (mainStack.numChildren > 0) mainStack.removeChildren();
								isClose = true;
								dispose();
							}
							
						};
					}
				}
			}
			panel.addChild(oneGoods);
			
			//装备展示图(护甲)
			var box = UIBuilder.create(Box, {
				skinName : "forgelvImg"+tempInfo.InitialQuality,
				children : [
					UIBuilder.create(Bmp, {
						src:'icon/' + tempInfo.ResId + '.png', 
						leftPt:-3,
						topPt:-3,
						scaleX:1.4,
						scaleY:1.4
						})
				]
			});
			oneGoods.getChild("color").skinName = "storelvImg" + tempInfo.InitialQuality;
			oneGoods.getChild("goodsImg").addChild(box);
			//var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png', x:0, y:0 } );
			//img.scaleX = 1.4;
			//img.scaleY = 1.4;
			//img.left = 5;
			//oneGoods.getChild("goodsImg").addChild(img);
			var t:Text = oneGoods.getChildAs("goodsName", Text);
			t.resetFormat(EquipProp.levelColor(tempInfo.InitialQuality), 30);
			t.text = tempInfo.itemName;
			//oneGoods.getChildAs("goodsName", Text).text = tempInfo.itemName;
			
			oneGoods.getChildAs("description", Text).text = tempInfo.Description;
			if(Std.is(tempInfo,WeaponInfo)||Std.is(tempInfo,ArmsInfo)){
				//var strInfo:StrengthenInfo = ForgeManager.instance.getProtpForge(tempInfo.itemType * 1000 + tempInfo.strLv);
				var weaponLv = EquipProp.Strengthen(cast tempInfo, tempInfo.strLv);
				var lvStrengthen:Int = 0;
				if (Std.is(tempInfo, WeaponInfo)) {
					lvStrengthen = Math.floor(weaponLv.Attack * tempInfo.Att / 10000);
				}else if (Std.is(tempInfo, ArmsInfo)) {
					lvStrengthen = Math.floor(weaponLv.HPvalue * tempInfo.Hp / 10000);
				}
				
				//if (Std.is(tempInfo, WeaponInfo))
				//{
					oneGoods.getChildAs("typeTxt", Text).text = tempInfo.Detail;
					oneGoods.getChildAs("typeValue", Text).text = Std.string(lvStrengthen);
					oneGoods.getChildAs("characterTxt", Text).text = "特性";
					oneGoods.getChildAs("characterDesc", Text).text = Std.string(tempInfo.Characteristic);
					oneGoods.getChildAs("Lv", Text).text = "Lv" + tempInfo.strLv + "/" + tempInfo.MaxStrengthenLevel;
				//}
			}
			oneGoods.getChildAs("goodsNum", Text).text = "";//tempInfo.itemNum + "/10";
	}
	
	override function onClose():Void 
	{
		//_widget.getChildAs("scrollPanel", VBox).removeChildren();
		//EntityManager.resolveEntity("UIManager").detach(this);
		//_widget = null;
		if(isClose != true)dispose();
		super.onClose();
	}
}