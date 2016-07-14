package com.metal.ui.popup;

import com.metal.config.BattleGradeConditionType;
import com.metal.config.SfxManager;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.impl.GradeConditionInfo;
import com.metal.proto.impl.MapStarInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.GradeConditionManager;
import com.metal.ui.BaseCmd;
import com.metal.utils.CountDown;
import com.metal.utils.DropItemUtils;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.HBox;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
import signals.Signal1;

/**
 * ...进入关卡副本前的关卡信息提示界面
 * @author hyg
 */
class BattleCmd extends BaseCmd
{
	public var callbackFun:Signal1<Bool>;
	private var _data:Dynamic;
	public function new() 
	{
		super();
		callbackFun = new Signal1();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("onBattle");
		onEnabel();
		super.onInitComponent();
	}
	public function setGradeCondition(data:DuplicateInfo)
	{
		var gradeCondition:GradeConditionInfo;
		var num:String= "";
		for (i in 0...data.GradeCondition.length) 
		{
			gradeCondition = GradeConditionManager.instance.getGradeConditionInfo(Std.parseInt(data.GradeCondition[i]));
			switch (gradeCondition.ConditionType) 
			{
				case BattleGradeConditionType.Hp:
					num = gradeCondition.Condition*100 +"";					
				case BattleGradeConditionType.RebornTime:					
					num = gradeCondition.Condition +"";	
				case BattleGradeConditionType.TimeCost:
					num = CountDown.changeSenForTxt(Std.int(gradeCondition.Condition));					
				default:	
					trace("There is no this type, please check the xml");
			}
			_widget.getChildAs("condition" + i, Text).text = gradeCondition.Txt1 +num+ gradeCondition.Txt2;
		}		
	}
	public function setStar(data:DuplicateInfo)
	{
		var star:Bmp;
		for (i in 0...MapStarInfo.instance.getMapStar(data.Id)) 
		{
			star = _widget.getChildAs("star" + (i + 1), Bmp);
			star.visible = true;
		}
	}
	/*显示数据*/
	public function setData(data:DuplicateInfo):Void
	{
		_widget.getChildAs("throughName", Text).text = data.DuplicateName;
		_widget.getChildAs("desc", Text).text = data.Description;
		_widget.getChildAs("vit", Text).text = "消耗体力："+data.NeedPower;
		_widget.getChildAs("bossName", Text).text = "";// "BOSS:" + data.BossName;
		_widget.getChildAs("bossFeature", Text).text = "";//"BOSS特性:" + data.BossFeatures;
		setGradeCondition(data);
		setStar(data);
		
		var panel = _widget.getChildAs("drop", HBox);
		if (panel.numChildren > 0) panel.removeChildren();
		//trace(data.PreDuplicateId);
		
		if (data.Id > 9000 && data.Id < 9004) {
			var list = data.DropItem3;
			if (data.DropItem3.length > 4){
				list = data.DropItem3.copy();
				list.shift();
				list.pop();
			}
			for (j in list) 
			{
				var tempInfo = GoodsProtoManager.instance.getItemById(Std.parseInt(j[0]));
				var oneGoods = createGoods(tempInfo, Std.parseInt(j[1]));
				panel.addChild(oneGoods);
			}
			return;
		}
		
		var oneGoods:Widget = null;
		var dropArr:Array<Array<Int>> = DropItemUtils.ordinaryDrop(data,true);
		//trace("dropArr.length: "+dropArr.length);
		
		for (i in 0...dropArr.length)
		{
			var tempInfo = GoodsProtoManager.instance.getItemById(dropArr[i][0], false);
			oneGoods = createGoods(tempInfo, dropArr[i][1]);
			panel.addChild(oneGoods);
		}
	}
	private function createGoods(tempInfo:Dynamic, num:Int):Widget
	{
		var img:Bmp = UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png' , x:10, y:10 } );
		//品质
		var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.ID), x:13, y:13 } );
		var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.ID, 0), x:5, y:5 } );
		var oneGoods:Widget = UIBuilder.buildFn('ui/popup/oneGoods.xml')( { } );
		var ico = oneGoods.getChild("img");
		ico.addChild(quality);
		ico.addChild(img);
		ico.addChild(quality_1);
		
		oneGoods.getChildAs("goodsName", Text).text = tempInfo.Name;
		oneGoods.getChildAs("goodsNum", Text).text = "x" + num;
		return oneGoods;
	}
	private function onEnabel():Void
	{
		_widget.getChildAs("close", Button).onPress = noBtn_click;
		_widget.getChildAs("submit", Button).onPress = yesBtn_click;
	}
	/*否*/
	private function noBtn_click(e):Void
	{	
		SfxManager.getAudio(AudioType.Btn).play();
		callbackFun.dispatch(false);
		dispose();
	}
	/*是*/
	private function yesBtn_click(e):Void
	{
		//trace("click yesBtn_click");
		SfxManager.getAudio(AudioType.Btn).play();
		//sendMsg(MsgUI2.Loading, true);
		//trace(callbackFun.numListeners);
		callbackFun.dispatch(true);
		//trace(callbackFun.numListeners);
		dispose();
	}
	
	override function onDispose():Void 
	{
		UIBuilder.get("popup").free();
		callbackFun = null;
		_widget = null;
		super.onDispose();
	}
}