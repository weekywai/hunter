package com.metal.manager;
import com.haxepunk.utils.Input;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgView;
import com.metal.proto.manager.DuplicateManager;
import com.metal.ui.battleResult.BattleFailureCmd;
import com.metal.ui.battleResult.BattleResultCmd;
import com.metal.ui.buyDiamonds.BuyDiamondsCmd;
import com.metal.ui.buyGold.BuyGoldCmd;
import com.metal.ui.controller.ControllCmd;
import com.metal.ui.copy.EndlessCopyCmd;
import com.metal.ui.dialogue.DialogueCmd;
import com.metal.ui.forge.ForgeCmd;
import com.metal.ui.gameSet.GameSetCmd;
import com.metal.ui.latestFashion.LatestFahionCmd;
import com.metal.ui.LoginRegistCmd;
import com.metal.ui.main.MainCmd;
import com.metal.ui.main.TopViewCmd;
import com.metal.ui.news.NewsCmd;
import com.metal.ui.noviceGuide.NoviceCourseCmd;
import com.metal.ui.popup.ResurrectionCmd;
import com.metal.ui.popup.StopGame;
import com.metal.ui.popup.TipCmd;
import com.metal.ui.reward.RewardCmd;
import com.metal.ui.skill.SkillCmd;
import com.metal.ui.task.TaskCmd;
import com.metal.ui.through.ThroughCmd;
import com.metal.ui.treasureHunt.TreasureHuntCmd;
import com.metal.ui.warehouse.WarehouseCmd;
import com.metal.utils.effect.Animator;
import com.metal.utils.effect.component.EffectType;
import de.polygonal.core.es.Entity;
import de.polygonal.core.sys.SimEntity;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.system.System;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Floating;

enum TipsType
{
	none;
	tipPopup;
	onBattle;
	overcome;
	failure;
	buyTip;
	resurrection;
	gainGoods;
	loading;
}

/**
 * ...
 * @author weeky
 */
class UIManager extends SimEntity
{
	public static var NewBie: Dynamic->Floating;
	public var _popup:  Dynamic->Floating;
	public var _loading:  Floating;
	private var _stage:Stage;
	/**根*/
	private var root:Dynamic;
	/**界面最顶层 容器*/
	private var _root:Floating;
	/**特效层*/
	public var effLayer(default, null):Sprite;
	
	private var cotroller:ControllCmd;
	private var _showBossData:Dynamic;
	public function new() 
	{
		super("UIManager", true, true);
	}
	
	private function initUI():Void 
	{
		UIBuilder.setTheme('ru.stablex.ui.themes.gui');
		
		UIBuilder.regClass('ru.stablex.Err');
		UIBuilder.regClass('com.metal.GameProcess');
		UIBuilder.regClass('com.metal.message.MsgUI');
		UIBuilder.regClass('com.metal.config.SfxManager');
		UIBuilder.regClass('com.metal.config.AudioType');
		
		
		//注册自定义事件
		UIBuilder.regEvent('textChange',  'openfl.events.Event.CHANGE',                        'openfl.events.Event');
        UIBuilder.regEvent('textInput',   'openfl.events.Event.TEXT_INPUT',                    'openfl.events.Event');
        UIBuilder.regEvent('notify',      'ru.stablex.ui.events.CustomEvent.NOTIFY',        'ru.stablex.ui.events.CustomEvent');
		UIBuilder.regEvent('unparent',    'openfl.events.Event.REMOVED_FROM_STAGE');
		
		UIBuilder.init('ui/defaults.xml');
		UIBuilder.regSkins('ui/skins.xml');
		
		//_root = UIBuilder.create(Widget, { id:"UIRoot", w:1280, h:720 } );
		//root.addChild(_root);
		
		if (_root == null){
			_root = UIBuilder.buildFn('ui/root.xml')();
			_root.show();
		}
		_popup = UIBuilder.buildFn('ui/alert.xml');
		_loading = UIBuilder.buildFn('ui/loading.xml')({msg:"加载中"});
		NewBie = UIBuilder.buildFn('ui/noviceGuide/noviceCourse.xml');
		
        UIBuilder.buildFn('ui/index.xml')().show();
		addComponent(new LoginRegistCmd());
		addComponent(new DialogueCmd());
		#if android
		Input.onAndroidBack = onAndroidBack;
		#end
	}
	override function onMsg(type:Int, sender:Entity) 
	{
		var userData = (incomingMessage.hasObject())? incomingMessage.o:null;
		switch(type) {
			case MsgView.SetParent:
				cmd_SetParent(userData);
			case MsgUI2.Control:
				cmd_Control(userData);
			case MsgUI.MainPanel:
				cmd_MainPanel(userData);
			case MsgUI.Warehouse:
				cmd_WarehousePanel(userData);
			case MsgUI.Forge:
				cmd_Forge(userData);
			case MsgUI.LatestFashion:
				cmd_LatestFashion(userData);
			case MsgUI.BuyGold:
				cmd_BuyGold(userData);
			case MsgUI.BuyDiamonds:
				cmd_BuyDiamonds(userData);
			case MsgUI.Through:
				cmd_Through(userData);
			case MsgUI.EndlessCopy:
				cmd_EndlessCopy(userData);
			case MsgUI.TreasureHunt:
				cmd_TreasureHunt(userData);
			case MsgUI.BattleResult:
				cmd_BattleResult(userData);
			case MsgUI.BattleFailure:
				cmd_BattleFailure(userData);
			case MsgUI.RevivePanel:
				cmd_RevivePanel(userData);
			case MsgUI2.StopGame:
				cmd_StopGame(userData);
			case MsgUI.Skill:
				cmd_Skill(userData);
			case MsgUI.Reward:
				cmd_Reward(userData);
			case MsgUI.Battle:
				cmd_Battle(userData);
			case MsgUI2.Task:
				cmd_Task(userData);
			case MsgUI2.Loading:
				cmd_Loading(userData);
			case MsgUI2.GameSet:
				cmd_GameSet();
			case MsgUI.BossPanel:
				cmd_BossPanel(userData);
			case MsgUI2.oneNews:
				cmd_oneNews(userData);
			case MsgUI2.GameNoviceCourse:
				cmd_GameNoviceCourse(userData);
			case MsgUI2.ScreenMessage:
				cmd_ScreenMessage(userData);
			case MsgUI.Tips:
				cmd_Tips(userData);
			case MsgUI.NewBie:
				cmd_Newbie(userData);
		}
	}
	private function cmd_SetParent(data:Dynamic):Void
	{
		//trace(data);
		root = data;
		initUI();
		
		effLayer = new Sprite();
		root.addChild(effLayer);
	}
	private function cmd_oneNews(data:Dynamic):Void
	{
		addComponent(new NewsCmd());
	}
	private function cmd_GameNoviceCourse(data:Dynamic):Void
	{
		trace("cmd_GameNoviceCourse");
		addComponent(new NoviceCourseCmd());
	}
	/**闯关*/
	private function cmd_Through(data:Dynamic):Void
	{
		addComponent(new ThroughCmd());
	}
	/**无尽副本（无尽、护甲、武器、金钱）*/
	private function cmd_EndlessCopy(data:Dynamic):Void
	{
		addComponent(new EndlessCopyCmd());
	}
	/**购买宝箱*/
	private function cmd_TreasureHunt(data:Dynamic):Void
	{
		addComponent(new TreasureHuntCmd());
	}
	/**购买钻石*/
	private function cmd_BuyDiamonds(data:Dynamic):Void
	{
		addComponent(new BuyDiamondsCmd());
	}
	/**购买金币*/
	private function cmd_BuyGold(data:Dynamic):Void
	{
		addComponent(new BuyGoldCmd());
	}
	/*时装*/
	private function cmd_LatestFashion(data:Dynamic):Void
	{
		addComponent(new LatestFahionCmd());
	}
	private function cmd_Forge(data:Dynamic):Void
	{
		addComponent(new ForgeCmd(data));
	}
	
	private function cmd_Control(data:Dynamic):Void
	{
		//trace("cmd_Control");
		var show:Bool = data;
		if (show)
		{
			//getObservable().clear();
			var comps = compMap.toArray();
			var dialog = getComponent(DialogueCmd);
			for (comp in comps) 
			{
				if (comp != dialog) 
					removeComponent(comp);
			}
			var control = UIBuilder.getAs("controller", Floating);
			if(control==null)
				control = UIBuilder.buildFn('ui/fight/fight.xml')();
			control.show();
			cotroller = new ControllCmd();
			addComponent(cotroller);
			cotroller.showBossPanel(_showBossData);
		}else {
			var control = UIBuilder.get("controller");
			if(control!=null) control.free();
				cotroller.dispose();
		}
	}
	private function cmd_playInfo(data:Dynamic=null):Void
	{
		//cast(GameProcess.root.getComponent(PlayShowCmd), PlayShowCmd).onNotify();
		//GameProcess.root.notify(MsgNet.QuestList, packet);
		//GameProcess.root.notify(MsgCreate.Player);
	}
	/*主界面*/
	private function cmd_MainPanel(data:Dynamic):Void
	{
		addComponent(new TopViewCmd());
		addComponent(new MainCmd());
	}
	/**仓库*/
	private function cmd_WarehousePanel(data:Dynamic):Void
	{
		
		addComponent(new WarehouseCmd(data));
	}
	/**技能解锁*/
	private function cmd_Skill(data:Dynamic):Void
	{
		addComponent(new SkillCmd(data));
	}
	/**胜利结算界面*/
	private function cmd_BattleResult(data:Dynamic):Void
	{
		cmd_Tips( { type:TipsType.overcome, msg:""} );
		addComponent(new BattleResultCmd(data));
	}
	/**失败结算界面*/
	private function cmd_BattleFailure(data:Dynamic):Void
	{
		cmd_Tips( { type:TipsType.failure, msg:"" } );
		addComponent(new BattleFailureCmd());
	}
	/*买活*/
	private function cmd_RevivePanel(data:Dynamic):Void
	{
		var count = Std.int(data * 10);
		cmd_Tips( { type:TipsType.resurrection, msg:"是否花费" + count + "钻石购买复活？" } );
		var repawn = new ResurrectionCmd(count);
		addComponent(repawn);
	}
	/**暂停游戏*/
	private function cmd_StopGame(data:Dynamic):Void
	{
		cmd_Tips( { type:TipsType.resurrection, msg:"是否继续游戏" } );
		addComponent(new StopGame());
	}
	/**奖励界面*/
	private function cmd_Reward(data:Dynamic):Void
	{
		addComponent(new RewardCmd(data));
	}
	/**任务界面*/
	private function cmd_Task(data:Dynamic):Void
	{
		addComponent(new TaskCmd(data));
	}
	/**游戏设置*/
	private function cmd_GameSet():Void
	{
		addComponent(new GameSetCmd());
	}
	
	private function cmd_Battle(data:Dynamic):Void
	{
		
		var duplicate = DuplicateManager.instance.getProtoDuplicateByID(data);
		GameProcess.root.notify(MsgStartup.GameInit, duplicate);
		cmd_Control(true);
		UIBuilder.get("main").free();
	}
	
	private function cmd_Loading(data:Dynamic):Void 
	{
		if (data) {
			//cmd_Tips( { type:TipsType.loading, msg:"加载中" } );
			_loading.show();
			
		}else {
			_loading.hide();
			//cmd_Tips( { type:TipsType.none} );
		}
	}
	private function cmd_BossPanel(data:Dynamic):Void 
	{
		_showBossData = data;
		if (cotroller != null && !cotroller.isDisposed){
			cotroller.showBossPanel(_showBossData);
			_showBossData = null;
		}
	}
	
	private function cmd_ScreenMessage(data:Dynamic):Void 
	{
		Animator.start(this, "", EffectType.MESSAGE_FADE, data, false);
	}
	
	private function cmd_Tips(data:Dynamic):Void {
		var alert:Floating = UIBuilder.getAs("popup", Floating);
		if (alert != null) 
			alert.free(true);
		
		//trace(alert + "" +data.type + UIBuilder.get(Std.string(data.type)));
		if (data.type == TipsType.none)
			return;
		alert = _popup( {
			msg:data.msg,
			content:Std.string(data.type)
		});
		alert.show();
	}
	private function cmd_Newbie(data:Dynamic):Void {
		var newbie = UIBuilder.getAs("bieId", Floating);
		if (newbie != null) newbie.free();
		newbie = NewBie( {
			msg:data.msg,
			content:data.type
		});
		newbie.show();
	}
	
	private function onAndroidBack(){
		cmd_Tips( { type:TipsType.tipPopup, msg:"是否退出游戏" } );
		var tipCmd:TipCmd = new TipCmd();
		addComponent(tipCmd);
		tipCmd.callbackFun.addOnce(exitApp);
	}
	private function exitApp(e:Bool)
	{
		if (e)
			System.exit(0);
	}
	
	override function onTick(dt:Float, post:Bool):Void 
	{
		super.onTick(dt, post);
	}
	
}