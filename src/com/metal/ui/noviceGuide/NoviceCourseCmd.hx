package com.metal.ui.noviceGuide;
import com.metal.enums.NoviceOpenType;
import com.metal.manager.UIManager;
import com.metal.message.MsgInput;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.DuplicateManager;
import com.metal.proto.manager.NoviceManager;
import com.metal.unit.actor.api.ActorState;
import com.metal.utils.LoginFileUtils;
import de.polygonal.core.event.IObservable;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Box;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.ViewStack;
/**
 * ...
 * @author cqm
 */
class NoviceCourseCmd extends BaseCmd
{
	private static var tip:Dynamic = null;
	private var num:Int;
	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onNotify(type, source, userData);
		switch(type) {
			case MsgUI2.GameNoviceCourse:
				cmd_GameNoviceCourse(userData);
		}
		
	}
	private function cmd_GameNoviceCourse(userData:Dynamic):Void 
	{
		notifyRoot(MsgUI.NewBie, {msg:Std.string(userData), type:"noviceCourse" } );
		_widget = UIBuilder.get("bieId");
		num = userData;
		initNoviceCourse();
	}
	
	private function initNoviceCourse():Void
	{
		switch(num)
		{
			case NoviceOpenType.NoviceText1://欢迎词
			noviceWelcome();
			case NoviceOpenType.NoviceText3://装备、护甲
			noviceArmor();
			case NoviceOpenType.NoviceText5://寻宝
			noviceTreasure();
			case NoviceOpenType.NoviceText6://战斗控制介绍
			noviceFigthing();
			case NoviceOpenType.NoviceText8://战斗技能介绍
			noviceFigthingSkill();
			case NoviceOpenType.NoviceText10://战斗奖品介绍
			noviceFigthingReward();
			case NoviceOpenType.NoviceText11,NoviceOpenType.NoviceText17://出战
			noviceChuzhan();
			case NoviceOpenType.NoviceText12,NoviceOpenType.NoviceText14://副本tip
			noviceThroughTip();
			case NoviceOpenType.NoviceText13://闯关
			noviceThrough();
			case NoviceOpenType.NoviceText15://副本
			noviceEndlessCopy();
			case NoviceOpenType.NoviceText16,NoviceOpenType.NoviceText33://胜利界面
			noviceVictory();
			case NoviceOpenType.NoviceText18://培养
			noviceTrain();
			case NoviceOpenType.NoviceText19,NoviceOpenType.NoviceText20,NoviceOpenType.NoviceText31,NoviceOpenType.NoviceText32://锻造(升级、进化、进阶、分解)
			noviceForge();
			case NoviceOpenType.NoviceText22://材料
			noviceMaterial();
			case NoviceOpenType.NoviceText23://材料
			noviceSelectMaterial();
			case NoviceOpenType.NoviceText24://仓库
			noviceWarehouse();
			case NoviceOpenType.NoviceText25://技能
			noviceSkill();
			case NoviceOpenType.NoviceText27://主界面奖励
			noviceActivitiesReward();
			case NoviceOpenType.NoviceText28,NoviceOpenType.NoviceText29://活动、奖励
			noviceReward();
		}
		
	}
	private function noviceWelcome():Void
	{
		//var data = LoginFileUtils.getLoginData();
		
		var playerInfo:PlayerInfo = PlayerUtils.getInfo();
		//trace("getinfo"+playerInfo.Name);
		var name:String;
		if (playerInfo.Name == null || playerInfo.Name == "")
			name = LoginFileUtils.getLoginData().id;
		else
			name = playerInfo.Name;
		_widget.getChildAs("noviceName", Text).text = "你好," + name+NoviceManager.instance.getProto(num).text;
		//if(data==null) {_widget.getChildAs("noviceName", Text).text = "你好," + playerInfo.Name+NoviceManager.instance.getProto(num).text;}
		//else { _widget.getChildAs("noviceName", Text).text = "你好," + data.id+NoviceManager.instance.getProto(num).text; }

		_widget.addEventListener(MouseEvent.CLICK, function(e)
		{
			num++;
			if (num > NoviceOpenType.NoviceText2)
			{
				_widget.free();
				UIBuilder.get("main").free();
				
				//打开新手引导关卡
				GameProcess.root.notify(MsgStartup.GameInit, DuplicateManager.instance.getProtoDuplicateByID(0));
				GameProcess.UIRoot.sendMsg(MsgUI2.Control, true);
				GameProcess.UIRoot.notify(MsgUIUpdate.NewBieUI);
				dispose();
			}
		});
	}
	private function noviceArmor():Void
	{
		_widget.getChildAs("noviceCourseView", Box).topPt = 25;
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("noviceName", Text).topPt = 30;
		_widget.getChildAs("leftBmp", Button).visible = true;
		_widget.getChildAs("rightBmp", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).topPt = -30;
		_widget.getChildAs("shouziBtn", Button).rightPt = 5;
		_widget.getChildAs("shouziBtn", Button).mouseEnabled = false;
		_widget.getChildAs("leftBmp", Button).onPress = UIBuilder.get("UIMain").getChildAs("leftEquipBtn", Button).onPress;
		_widget.getChildAs("rightBmp", Button).onPress = UIBuilder.get("UIMain").getChildAs("rightEquipBtn", Button).onPress;
	}
	private function noviceTreasure():Void
	{
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).mouseEnabled = false;
		_widget.getChildAs("shouziBtn", Button).topPt = 23;
		_widget.getChildAs("shouziBtn", Button).rightPt = -24;
		_widget.getChildAs("noviceCourseView", Box).leftPt = 0;
		_widget.getChildAs("payBmp", Button).visible = true; 
		_widget.getChildAs("payBmp", Button).topPt = 27;
		_widget.getChildAs("payBmp", Button).rightPt = -28;
		_widget.getChildAs("payBmp", Button).onRelease = function(e)
		{
			notifyRoot(MsgUIUpdate.NewBie, NoviceOpenType.NoviceText5);
			_widget.free();
		}
	}
	private function noviceFigthing():Void
	{
		GameProcess.instance.pauseGame(true);
		notifyRoot(MsgPlayer.UpdateBGM, false);
		notifyRoot(MsgPlayer.UpdateSounds, false);
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceCourseViewCopy", Box).topPt = 0;
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).visible = false;
		_widget.getChildAs("shouziBtnCopy", Button).topPt = 110; 
		_widget.getChildAs("shouziBtnCopy", Button).rightPt = -2;
		_widget.addEventListener(MouseEvent.CLICK, function(e)
		{
			num++;
			if (num > NoviceOpenType.NoviceText7)
				num = NoviceOpenType.NoviceText7;
			_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
			_widget.getChildAs("shouziBtnCopy", Button).visible = true;
			_widget.getChildAs("shouziBtnCopy2", Button).visible = true;
			_widget.getChildAs("shouziBtnCopy2", Button).onPress = function(e)
			{
				_widget.free();
				GameProcess.instance.pauseGame(false);
				notifyRoot(MsgPlayer.UpdateBGM, true);
				notifyRoot(MsgPlayer.UpdateSounds, true);
				dispose();
			}
			_widget.getChildAs("shouziBtnCopy", Button).onPress  = function(e)
			{
				_widget.free();
				GameProcess.instance.pauseGame(false);
				PlayerUtils.getPlayer().notify(MsgInput.UIInput, {type:ActorState.Jump});
				notifyRoot(MsgPlayer.UpdateBGM, true);
				notifyRoot(MsgPlayer.UpdateSounds, true);
				dispose();
			}
		});
	}
	private function noviceFigthingSkill():Void
	{
		GameProcess.instance.pauseGame(true);
		notifyRoot(MsgPlayer.UpdateBGM, false);
		notifyRoot(MsgPlayer.UpdateSounds, false);
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceCourseViewCopy", Box).topPt = 0;
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).visible = false;
		_widget.getChildAs("shouziBtnCopy", Button).topPt = 120; 
		_widget.getChildAs("shouziBtnCopy", Button).rightPt = 17;
		_widget.addEventListener(MouseEvent.CLICK, function(e)
		{
			num++;
			_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
			_widget.getChildAs("shouziBtnCopy", Button).visible = true;
			if(num>NoviceOpenType.NoviceText9)
			{
				_widget.free();
				GameProcess.instance.pauseGame(false);
				notifyRoot(MsgPlayer.UpdateBGM, true);
				notifyRoot(MsgPlayer.UpdateSounds, true);
				dispose();
			}
			_widget.getChildAs("shouziBtnCopy", Button).onPress = function(e)
			{
				_widget.free();
				GameProcess.instance.pauseGame(false);
				PlayerUtils.getPlayer().notify(MsgInput.UIInput, {type:ActorState.Skill});
				notifyRoot(MsgPlayer.UpdateBGM, true);
				notifyRoot(MsgPlayer.UpdateSounds, true);
				dispose();
			}
		});
	}
	private function noviceFigthingReward():Void
	{
		GameProcess.instance.pauseGame(true);
		notifyRoot(MsgPlayer.UpdateBGM, false);
		notifyRoot(MsgPlayer.UpdateSounds, false);
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceCourseViewCopy", Box).topPt = 0;
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).visible = false;
		_widget.addEventListener(MouseEvent.CLICK, function(e)
		{
			_widget.free();
			GameProcess.instance.pauseGame(false);
			notifyRoot(MsgPlayer.UpdateBGM, true);
			notifyRoot(MsgPlayer.UpdateSounds, true);
			dispose();
		});
	}
	
	private function noviceChuzhan():Void
	{
		
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("noviceName", Text).topPt = 30;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).rightPt = -35;
		if (num == 11)
		{
			_widget.getChildAs("shouziBtn", Button).topPt = 10;
			_widget.getChildAs("shouziBtn", Button).onPress  = function(e)
			{
				_widget.free();
				dispose();
				var viewStack:ViewStack = UIBuilder.getAs("mainFourBtn", ViewStack);
				viewStack.show("rightUpBtn");
				notifyRoot(MsgView.NewBie, 12);
			}
		}else 
		{
			_widget.getChildAs("shouziBtn", Button).rightPt = -30;
			_widget.getChildAs("shouziBtn", Button).topPt = 75;
			_widget.getChildAs("shouziBtn", Button).onPress  = function(e)
			{
				_widget.free();
				dispose();
				var viewStack:ViewStack = UIBuilder.getAs("mainFourBtn", ViewStack);
				viewStack.show("rightDownBtn");
				notifyRoot(MsgView.NewBie, 18);
			}
		}
	}
	private function noviceThroughTip():Void
	{
		if (num == 12)
		{
			_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
			_widget.getChildAs("noviceCourseView", Box).leftPt = 0;
			_widget.getChildAs("noviceName", Text).topPt = 30;
			_widget.getChildAs("shouziBtn", Button).visible = true;
			_widget.getChildAs("shouziBtn", Button).rightPt = -30;
			_widget.getChildAs("shouziBtn", Button).topPt = 35;
			_widget.getChildAs("shouziBtn", Button).onPress = UIBuilder.get("UIMain").getChildAs("battleBtn", Button).onPress;
		}else
		{
			_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
			_widget.getChildAs("noviceCourseView", Box).leftPt = -10;
			_widget.getChildAs("noviceName", Text).topPt = 30;
			_widget.getChildAs("shouziBtn", Button).visible = true;
			_widget.getChildAs("shouziBtn", Button).rightPt = -30;
			_widget.getChildAs("shouziBtn", Button).topPt = 50;
			UIBuilder.getAs("mainFourBtn", ViewStack).show("rightUpBtn");
			_widget.getChildAs("shouziBtn", Button).onPress = UIBuilder.get("UIMain").getChildAs("endlessBtn", Button).onPress;
		}
		_widget.getChildAs("shouziBtn", Button).onRelease  = function(e)
		{
			_widget.free();
		}
	}
	private function noviceThrough():Void
	{
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).topPt = 35; 
		_widget.getChildAs("shouziBtnCopy", Button).leftPt = -40; 
		_widget.getChildAs("shouziBtnCopy", Button).onPress=function(e)
		{
			_widget.free();
			dispose();
		}
	}
	private function noviceEndlessCopy():Void
	{
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).topPt = 40; 
		_widget.getChildAs("shouziBtnCopy", Button).leftPt = -10; 
		_widget.getChildAs("shouziBtnCopy", Button).onPress = UIBuilder.get("endless").getChildAs("weaponsBtn", Button).onPress;//武器副本
		_widget.getChildAs("shouziBtnCopy", Button).onRelease = function(e)
		{
			_widget.free();
			dispose();
		}
	}
	private function noviceVictory():Void
	{
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtn", Button).visible = false;
		_widget.getChildAs("shouziBtn", Button).rightPt = -25;
		_widget.getChildAs("shouziBtn", Button).topPt = 90;
		_widget.addEventListener(MouseEvent.CLICK, function(e)
		{
			_widget.free();
			dispose();
		});
	}
	private function noviceTrain():Void
	{
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("noviceCourseView", Box).leftPt = 0;
		_widget.getChildAs("noviceName", Text).topPt = 40;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).rightPt = -25;
		_widget.getChildAs("shouziBtn", Button).topPt = 40;
		_widget.getChildAs("shouziBtn", Button).onPress = UIBuilder.get("UIMain").getChildAs("strengthenBtn", Button).onPress;
		_widget.getChildAs("shouziBtn", Button).onRelease  = function(e)
		{
			_widget.free();
			dispose();
		}
	}
	private function noviceForge():Void
	{
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("noviceCourseView", Box).leftPt = 20;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).topPt = 35;
		_widget.getChildAs("shouziBtn", Button).leftPt = -30;
		_widget.getChildAs("shouziBtn", Button).onRelease = function(e){_widget.free();}
		if (num == 19) {
			_widget.getChildAs("shouziBtn", Button).onPress = function(e) { notifyRoot(MsgUIUpdate.NewBie, NoviceOpenType.NoviceText19); };
		}else if (num == 20) {
		}else if (num == 31) {
		}else {
			/*_widget.getChildAs("payBmp", Button).visible = true; 
			_widget.getChildAs("payBmp", Button).topPt = 26;
			_widget.getChildAs("payBmp", Button).leftPt = 0;
			_widget.getChildAs("payBmp", Button).scaleX = 1.6;
			_widget.getChildAs("payBmp", Button).scaleY = 2.1;
			_widget.getChildAs("shouziBtn", Button).topPt = 26;
			_widget.getChildAs("shouziBtn", Button).leftPt = 0;*/
			_widget.addEventListener(MouseEvent.CLICK, function(e)
			{
				_widget.free();
				dispose();
			});
		}
	}
	private function noviceMaterial():Void
	{
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("noviceCourseView", Box).leftPt = 0;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).topPt = 10;
		_widget.getChildAs("shouziBtn", Button).leftPt = 115;
		_widget.getChildAs("shouziBtn", Button).onPress = function(e)
		{
			_widget.free();
			dispose();
		}
	}
	private function noviceSelectMaterial():Void
	{
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceText", Text).text = "金币足够情况下,点击强化按钮即可强化!";
		_widget.getChildAs("shouziBtnCopy", Button).onPress = function(e)
		{
			_widget.free();
			dispose();
		}
	}
	private function noviceWarehouse():Void
	{
		_widget.getChildAs("noviceName", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("noviceCourseView", Box).leftPt = 0;
		_widget.getChildAs("shouziBtn", Button).visible = true;
		_widget.getChildAs("shouziBtn", Button).topPt = 20;
		_widget.getChildAs("shouziBtn", Button).leftPt = 100;
		_widget.getChildAs("shouziBtn", Button).onPress = function(e)
		{
			_widget.free();
			dispose();
		}
	}
	private function noviceSkill():Void
	{
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceCourseViewCopy", Box).topPt = 0;
		_widget.getChildAs("noviceCourseViewCopy", Box).leftPt = 30;
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).visible = false;
		_widget.getChildAs("shouziBtnCopy", Button).topPt = 80; 
		_widget.getChildAs("shouziBtnCopy", Button).leftPt = -32;
		_widget.addEventListener(MouseEvent.CLICK, function(e)
		{
			num++;
			_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
			_widget.getChildAs("shouziBtnCopy", Button).visible = true;
			_widget.getChildAs("shouziBtnCopy", Button).onPress = function(e)
			{
				_widget.free();
				dispose();
			}
		});
	}
	private function noviceActivitiesReward():Void
	{
		UIBuilder.getAs("mainFourBtn", ViewStack).show("leftUpBtn");
		var viewStack:ViewStack = UIBuilder.getAs("floatBie", ViewStack);
		viewStack.show("noviceCourseViewCopy");
		_widget.getChildAs("noviceCourseViewCopy", Box).topPt = 0;
		_widget.getChildAs("noviceText", Text).text = NoviceManager.instance.getProto(num).text;
		_widget.getChildAs("shouziBtnCopy", Button).topPt = 85;
		_widget.getChildAs("shouziBtnCopy", Button).leftPt = -20;
		_widget.getChildAs("shouziBtnCopy", Button).onPress = UIBuilder.get("UIMain").getChildAs("rewardBtn", Button).onPress;
		_widget.getChildAs("shouziBtnCopy", Button).onRelease = function(e)
		{
			_widget.free();
			dispose();
			notifyRoot(MsgView.NewBie, 28);
		}
	}
	private function noviceReward():Void
	{
		UIBuilder.getAs("floatBie", ViewStack).show("noviceCourseViewCopy2");
		var hintBtn:Button = _widget.getChildAs("payBmp3", Button);
		hintBtn.visible = true;
		hintBtn.scaleX = 0.8;
		hintBtn.scaleY = 1.4;
		hintBtn.topPt = 48;
		hintBtn.rightPt = -14;
		hintBtn.onRelease = function(e)
		{
			notifyRoot(MsgUIUpdate.NewBie, NoviceOpenType.NoviceText28);
			_widget.free();
			dispose();
		}
	}
}