package com.metal.ui.forge;

import com.metal.config.BagType;
import com.metal.config.EquipProp;
import com.metal.config.SfxManager;
import com.metal.enums.NoviceOpenType;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.StrengthenInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.ui.BaseCmd;
import de.polygonal.core.event.IObservable;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.TabPage;
import ru.stablex.ui.widgets.TabStack;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
/**
 * ...
 * @author hyg
 */
enum Forgetype {
	StrengThen;
	Advance;
	Decomposition;
}
enum ForgeUpdate {
	Price;
	Success;
}
class ForgeCmd extends BaseCmd
{
	public static var CurrentType:Forgetype = null;
	
	private var goodsData:Dynamic;
	
	private var _name:Text;
	private var _select:Button;
	private var _eff:Widget;
	private var _submit:Button;
	private var _submitBmp:Bmp;
	private var _goodsType:Text;
	private var _goodsValue:Text;
	private var _goodsLv:Text;
	private var _needGolds:Text;
	private var _goodsPanel:Widget;
	
	private var _strengThen:StrengthenCmd;
	private var _decompose:DecompositionCmd;
	private var _advance:AdvanceCmd;
	
	public function new(data:Dynamic) 
	{
		if (data != null) goodsData = data;
		super();
	}
	
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("forge");
		
		super.onInitComponent();
		
		_name = _widget.getChildAs("goodsName", Text);
		_select = _widget.getChildAs("selectStrEquip", Button);
		_eff = _widget.getChild("effPanel");
		_submit = _widget.getChildAs("submit", Button);
		_submitBmp = _widget.getChildAs("btnSkin", Bmp);
		_goodsType = _widget.getChildAs("typeName", Text);
		_goodsValue = _widget.getChildAs("typeValue", Text);
		_goodsLv = _widget.getChildAs("level", Text);
		_needGolds = _widget.getChildAs("needGolds", Text);
		
		if (CurrentType == null) 
			CurrentType = Forgetype.StrengThen;
		selectTab();
		_widget.getChildAs("strengthenTab", TabPage).title.onRelease = onStrengthenTab;//升级
		_widget.getChildAs("advancedTab", TabPage).title.onRelease = onAdvancedTab;//进化
		//_widget.getChildAs("evolutionTab", TabPage).title.onRelease = selectTab;//进阶
		_widget.getChildAs("decompositionTab", TabPage).title.onRelease = onDecompositionTab;//分解
		if (goodsData!=null)
			showGoods();
	}
	override function onDispose():Void 
	{
		goodsData = null;
		if (_strengThen != null)_strengThen.dispose();
		_strengThen = null;
		if (_decompose != null)_decompose.dispose();
		_decompose = null;
		if (_strengThen != null)_advance.dispose();
		_advance = null;
		super.onDispose();
	}
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgUIUpdate.NewBie:
				cmd_NewBie(userData);
			case MsgUIUpdate.ForgeUpdate:
				cmd_ForgeUpdate(userData);
		}
	}
	private function cmd_NewBie(data:Dynamic):Void
	{
		if (data == NoviceOpenType.NoviceText19) {
			selectEquip(null);
		}
	}
	private function cmd_ForgeUpdate(userData:Dynamic)
	{
		switch(userData.type){
			case ForgeUpdate.Price:
				//trace(userData.data);
				_needGolds.text = userData.data;
			case ForgeUpdate.Success:
				onEffect();
				if (userData.data != null){
					goodsData = userData.data;
					showGoods();
				}
		}
	}
	
	private function showGoods()
	{
		if (_goodsPanel != null)
			_goodsPanel.free(true);
		_goodsPanel = new Widget();
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/big/' + goodsData.ResId + '.png' ,x:-173,y:-87} );
		var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(goodsData.itemId,3) ,x:-183,y:-94} );
		var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(goodsData.itemId, 2), x: -201 , y: -112 } );
		_goodsPanel.addChild(quality);
		_goodsPanel.addChild(img);
		_goodsPanel.addChild(quality_1);
		_name.text = goodsData.itemName;
		_select.addChild(_goodsPanel);
	
		var equipLv:StrengthenInfo = EquipProp.Strengthen(goodsData, goodsData.strLv);
		if (Std.is(goodsData, WeaponInfo))
		{
			_goodsType.text = "攻击";
			_goodsValue.text = "+" + Math.floor(goodsData.Att * equipLv.Attack / 10000);
		}else if (Std.is(goodsData, ArmsInfo))
		{
			_goodsType.text = "生命";
			_goodsValue.text = "+" + Math.floor(goodsData.Hp * equipLv.HPvalue / 10000);
			
		}
		_goodsLv.resetFormat(EquipProp.levelColor(goodsData.InitialQuality), 24);
		_goodsLv.text = "LV:"+goodsData.strLv;
	}
	
	private function selectTab():Void
	{
		var tab = _widget.getChildAs("tabForge", TabStack);
		switch(CurrentType)
		{
			case Forgetype.StrengThen:
				tab.showByName("strengthenTab");
				if (_strengThen == null){
					_strengThen = new StrengthenCmd();
					_strengThen.onInitComponent(owner);
				}
				//notifyRoot(MsgView.NewBie, 20);//强化新手指引界面
				_strengThen.setData(goodsData);
				_select.text = "点击选择装备";
				_submitBmp.skinName = "forgeImg16";
				_select.onRelease = selectEquip;
				_submit.onRelease = _strengThen.submit;
			case Forgetype.Advance:
				tab.showByName("advancedTab");
				if (_advance == null){
					_advance = new AdvanceCmd();
					_advance.onInitComponent(owner);
				}
				notifyRoot(MsgView.NewBie, 20);//进化新手指引界面
				_advance.setData(goodsData);
				_select.text = "点击选择装备";
				_submitBmp.skinName = "forgeImg24";
				_select.onRelease = selectEquip;
				_submit.onRelease = _advance.submit;
			case Forgetype.Decomposition:
				tab.showByName("decompositionTab");
				if (_decompose == null){
					_decompose = new DecompositionCmd();
					_decompose.onInitComponent(owner);
				}
				notifyRoot(MsgView.NewBie, 32);//分解新手指引界面
				_decompose.setData(goodsData);
				_select.text = "分解后道具将\n消失，同时获\n得对应品质的\n材料";
				_submitBmp.skinName = "forgeImg25";
				_select.onRelease = function(e){};
				_submit.onRelease = _decompose.submit;
			/*case "evolution":
				tab.showByName("evolutionTab");
				if (_evolution == null){
					_evolution = new EvolutionCmd();
					_evolution.onInitComponent(this);
				}
				notifyRoot(MsgView.NewBie, 31);//进阶新手指引界面
			*/
		}
		_needGolds.text = "";
		_goodsLv.text = "";
		_goodsType.text = "";
		_goodsValue.text = "";
		if (_goodsPanel != null)
			_goodsPanel.free(true);
	}
	/**
	 * @param	e
	 *点击选需择强化的装备*/
	private function selectEquip(e:MouseEvent):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_STR);
		//notifyRoot(MsgView.NewBie, NoviceOpenType.NoviceText24);
	}
	
	/**
	 *强化
	 * */
	private function onStrengthenTab(e:MouseEvent):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		goodsData = null;
		if (CurrentType == Forgetype.StrengThen) return;
		CurrentType = Forgetype.StrengThen;
		selectTab();
	}
	/**
	 *进化
	 * */
	private function onAdvancedTab(e:MouseEvent):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		goodsData = null;
		if (CurrentType == Forgetype.Advance) return;
		ForgeCmd.CurrentType = Forgetype.Advance;
		notifyRoot(MsgView.NewBie, 20);//进化新手指引界面
		selectTab();
	}
	/**
	 *分解*/
	private function onDecompositionTab(e:MouseEvent):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		goodsData = null;
		if (CurrentType == Forgetype.Decomposition) return;
		CurrentType = Forgetype.Decomposition;
		notifyRoot(MsgView.NewBie, 32);//分解新手指引界面
		selectTab();
	}
	private function onEffect()
	{
		_eff.removeChildren();
		var eff:TexturePackerPlay = new TexturePackerPlay();
		eff.effectPlay("effect/T001", "T00100");
		_eff.addChild(eff);
		eff.onPlay();
		SfxManager.getAudio(AudioType.UpGrade).play();
	}
	
	override function onClose():Void
	{
		dispose();
		super.onClose();
	}
}