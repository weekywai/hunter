package com.metal.ui.through;
import com.metal.config.PlayerPropType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgNet;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.manager.DuplicateManager;
import com.metal.ui.popup.BattleCmd;
import motion.Actuate;
import openfl.events.MouseEvent;
import openfl.filters.GlowFilter;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Scroll;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;


/**
 * ...
 * @author weeky
 */
class ThroughCmd extends BaseCmd
{
	public var checkpoint:Int = 0;
	private var _page:Int = 0;
	private var _maxPage:Int = 0;
	private var _duplicateArr:Array<Array<DuplicateInfo>>;
	private var _scroll:Scroll;
	private var _scrollPanel:Widget;
	private var _wordlMap:Widget;//2006*2020
	private var _pageTitle:Text;
	public var handlerBtn:Button = null;
	
	private var _openAll:Bool = true;
	
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		_widget = UIBuilder.get("through");
		_scroll = UIBuilder.getAs("throughTrun", Scroll);
		_pageTitle = _widget.getChildAs("tipsName", Text);
		_wordlMap = _widget.getChild("worldMap");
		super.onInitComponent();
		initHandler();
		notify(MsgUIUpdate.UpdataReturnBtn, false);
	}
	/**初始化关卡*/
	private function initHandler():Void
	{
		_duplicateArr = DuplicateManager.instance.getDuplicateArr().copy();
		_duplicateArr.shift();
		_scrollPanel = _widget.getChildAs("scrollPanel", Widget);
		if (_scrollPanel.numChildren > 0) _scrollPanel.removeChildren();
		trace(_duplicateArr.length);
		var playerInfo = PlayerUtils.getInfo();
		for (i in 0..._duplicateArr.length)
		{
			var oneHandler = UIBuilder.create(Widget,{widthPt:100, heightPt:100});
			_scrollPanel.addChild(oneHandler);
			
			oneHandler.x = _widget.w * i;
			
			for ( j in 0..._duplicateArr[i].length)
			{
				if (j == 3 || j == 4)
				{
					handlerBtn = UIBuilder.buildFn("ui/copy/handlerBtn1.xml")();
				}else {
					handlerBtn = UIBuilder.buildFn("ui/copy/handlerBtn3.xml")();
				}
				var oneInfo:DuplicateInfo = _duplicateArr[i][j];
				handlerBtn.x = (_widget.w * 0.8 * 0.2 * j) + _widget.w * 0.1;//(scrollPanel.w/5-50) * j+150;
				if (j == 0) { 
					handlerBtn.y = 290;
				}else {
					handlerBtn.y = Math.random() * (_widget.h * 0.35) + _widget.h * 0.15;
				}
				if (Main.config.get("console")=="true") {
					handlerBtn.getChild("lock").free();
					handlerBtn.onRelease = function(e){
						checkpoint = oneInfo.Id;
						handler();
					}
				}else {
					if (oneInfo.Id <= (playerInfo.data.THROUGH + 1))
					{
						if (oneInfo.Id == (playerInfo.data.THROUGH + 1)) {
							Actuate.effects(handlerBtn, 0.8).filter(GlowFilter, {color:0xFFFFCC, blurX:45,blurY:45, strength:1} ).repeat().reflect();
						}
						handlerBtn.getChild("lock").free();
						handlerBtn.onRelease = function(e)
						{
								checkpoint = oneInfo.Id;
								handler();
								//trace(checkpoint);
								//checkpoint = i*5+(j + 1);
						}
					}
				}
				
				handlerBtn.getChildAs("missionName", Text).text = oneInfo.DuplicateName;
				oneHandler.addChild(handlerBtn);
			}
			
			//scrollPanel.w = Lib.current.stage.stageWidth * (i+1);
			_scrollPanel.w = _scroll.wparent.w * (i + 1);
		}
		_scroll.widthPt = 100;
		_page = Math.floor(playerInfo.data.THROUGH / 5);
		if (Main.config.get("console")=="true")
			_maxPage = 12;
		else
			_maxPage = _page;
		setPage(0);
		_scroll.scrollX = -Std.int(_scroll.wparent.w) * _page;
		_widget.getChildAs("leftBtn", Button).onRelease = leftBtn_click;
		_widget.getChildAs("rightBtn", Button).onRelease = rightBtn_click;
	}
	/*左翻页点击*/
	private function leftBtn_click(e):Void
	{
		//_scroll.scrollX +=  Lib.current.stage.stageWidth;
		//_scroll.scrollX +=  _scroll.wparent.w;
		setPage(-1);
	}
	/*又翻页点击*/
	private function rightBtn_click(e):Void
	{
		//_scroll.scrollX -=  Lib.current.stage.stageWidth;
		//_scroll.scrollX -=  _scroll.wparent.w;
		setPage(1);
	}
	private function onT1Handler(e:MouseEvent):Void 
	{
		trace("=====" + e.target);
	}
	private function setPage(count:Int)
	{
		_page += count;
		if (_page > _maxPage || _page<0)
			return;
		_scroll.scrollX -=  _scroll.wparent.w * count;
		//var info = DuplicateManager.instance.getProtoDuplicateByID((_page+1) * 5);
		if (_duplicateArr[_page] == null) {
			_page -= count;
			return;
		}
		var info = _duplicateArr[_page][0];
		_pageTitle.text = info.StageName;
		_wordlMap.tween(0.3, { x: -Math.random() * (2006 - _scroll.wparent.w), y: -Math.random() * (2060 -_scroll.wparent.h) } );
		_scrollPanel.alpha = 0;
		_scrollPanel.tween(0.3, { alpha:1 } ).delay(0.3);
	}
	
	/*点击关卡*/
	public function handler():Void
	{
		sendMsg(MsgUI.Tips, { msg:"副本未开启", type:TipsType.onBattle} );
		
		var tipCmd:BattleCmd = new BattleCmd();
		tipCmd.onInitComponent();
		tipCmd.setData(DuplicateManager.instance.getProtoDuplicateByID(checkpoint));
		tipCmd.callbackFun.addOnce(callBackFun);
	}
	/*确定进入关卡*/
	private function callBackFun(flag:Bool):Void
	{
		if (flag)
		{
			var _playInfo = PlayerUtils.getInfo();
			var info:DuplicateInfo = DuplicateManager.instance.getProtoDuplicateByID(checkpoint);
			if (_playInfo.data.POWER >= info.NeedPower) {
				var power = _playInfo.data.POWER - info.NeedPower;
				notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.POWER, data:power } );
				notify(MsgUIUpdate.Vit, _playInfo);
				sendMsg(MsgUI.Battle, checkpoint);
				dispose();
			}else
			{
				sendMsg(MsgUI.Tips, { msg:"是否购买体力", type:TipsType.buyTip, callback:callBackFun_buy} );
			}
		}
	}
	/*需要购买体力，确定购买并进入关卡*/
	private function callBackFun_buy(flag:Bool):Void
	{
		if (flag)
		{
			var _playInfo = PlayerUtils.getInfo();
			if (_playInfo.data.GEM < 100)
			{
				sendMsg(MsgUI.Tips, { msg:"钻石不足", type:TipsType.tipPopup} );
				return;
			}
			var duplicate:DuplicateInfo = DuplicateManager.instance.getProtoDuplicateByID(checkpoint);
			notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.POWER, data:_playInfo.data.POWER + (100 - duplicate.NeedPower) } );
			notify( MsgUIUpdate.Vit, _playInfo);
			sendMsg(MsgUI.Battle, checkpoint);
			
			dispose();
		}
	}
	override function onClose():Void 
	{
		dispose();
		super.onClose();
	}
	override function onDispose():Void 
	{
		//scrollPanel.removeChildren();
		//checkpoint = 0;
		//_widget = null;
		//duplicateInfo  = null;
		//_duplicateArr = null;
		//_scroll = null;
		super.onDispose();
	}
}