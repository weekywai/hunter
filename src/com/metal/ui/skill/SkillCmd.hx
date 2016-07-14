package com.metal.ui.skill;

import com.metal.component.GameSchedual;
import com.metal.config.GuideText;
import com.metal.config.SfxManager;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
/**
 * ...技能
 * @author zxk
 */
class SkillCmd extends BaseCmd
{
	//充值钱额
	private var moneyType:Int = 0;
	//技能显示
	private var visible:Bool = true;
	
	private var btnNum:Int = 0;

	public function new(data:Dynamic) 
	{
		if (data != null) moneyType = data;
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		super.onInitComponent();
		_widget = UIBuilder.get("skill");
		initUI();
		
		onEnabel();
	}
	
	private function initUI():Void
	{
		setData(null);
	}
	
	/**设置数据*/
	private function setData(data:Dynamic):Void
	{
		if (_unparent) return;
	}
	
	override public function onDispose():Void
	{
		super.onDispose();
	}
	
	private function onEnabel():Void
	{
		_widget.getChildAs("skillImg1", Button).onRelease = skillImg_Click1;
		_widget.getChildAs("skill_Btn1", Button).disabled = true;
		
		var skillshow = cast(GameProcess.instance.getComponent(GameSchedual), GameSchedual).skillData;
		var i:Int = 2;
		for (n in skillshow) 
		{
			skillEnabled(i, (n!=0));
			i++;
		}
	}
	private function skillEnabled(index:Int, unlock:Bool)
	{
		var w = _widget.getChild("skill" + index);
		var btn = w.getChildAs("skill_Btn" + index, Button);
		btn.disabled = unlock;
		btn.onRelease = Reflect.getProperty(this, "skill_Click" + index);
		w.getChildAs("lock", Bmp).visible = !unlock;
		if (unlock) w.getChildAs("intro", Text).text = "已解锁";
		_widget.getChildAs("skillImg" + index, Button).onRelease = (unlock)?Reflect.getProperty(this, "skillImg_Click" + index):Reflect.getProperty(this, "skill_Click" + index);
	}
	private function showDescript(index:Int)//skill1
	{
		for (i in 1...6)
		{
			var w = _widget.getChild("skill"+i);
			w.getChildAs("detail", VBox).visible = (index==i)?true:false;
		}
		
	}
	private function buy ():Void
	{
		var price:String = "";
		switch(btnNum) {
			case 2:
				price = GuideText.SkillPrice1;
			case 3:
				price = GuideText.SkillPrice2;
			case 4:
				price = GuideText.SkillPrice3;
			case 5:
				price = GuideText.SkillPrice4;
		}
		openTip(price, callBackFun);
	}
	
	private function callBackFun(flag:Bool):Void
	{
		if (flag)
		{
			var zuanshi:Int = 0;
			switch(btnNum){
				case 2:
					_widget.getChild("skill2").getChildAs("lock", Bmp).visible = false;
					_widget.getChildAs("skill_Btn2", Button).disabled = true;
					_widget.getChildAs("skillImg2", Button).onRelease = skillImg_Click2;
					zuanshi = 50;
				case 3:
					//_widget.getChildAs("skill3", Bmp).visible = false;
					_widget.getChild("skill3").getChildAs("lock", Bmp).visible = false;
					_widget.getChildAs("skill_Btn3", Button).disabled = true;
					_widget.getChildAs("skillImg3", Button).onRelease = skillImg_Click3;
					zuanshi = 100;
				case 4:
					//_widget.getChildAs("skill4", Bmp).visible = false;
					_widget.getChild("skill4").getChildAs("lock", Bmp).visible = false;
					_widget.getChildAs("skill_Btn4", Button).disabled = true;
					_widget.getChildAs("skillImg4", Button).onRelease = skillImg_Click4;
					zuanshi = 500;
				case 5:
					//_widget.getChildAs("skill5", Bmp).visible = false;
					_widget.getChild("skill5").getChildAs("lock", Bmp).visible = false;
					_widget.getChildAs("skill_Btn5", Button).disabled = true;
					_widget.getChildAs("skillImg5", Button).onRelease = skillImg_Click5;
					zuanshi = 1000;
			}
			notifyRoot(MsgPlayer.UpdateGem, zuanshi);
			notifyRoot(MsgPlayer.UpdateSkill, btnNum);
		}
	}
	
	private function skillImg_Click1(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.t001).play();
		//trace(e.currentTarget.name);
		showDescript(1);
		//AlertTips.openTip("能量消耗:30\n冷却时间:30\n手榴弹，对敌人造成5000伤害！", "tipPupup");
	}
	private function skillImg_Click2(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.t001).play();
		showDescript(2);
		//AlertTips.openTip("能量消耗:40\n冷却时间:40\n一次击杀屏幕全部怪物！\n充值任意金额可解锁？", "tipPupup");
	}
	private function skillImg_Click3(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.t001).play();
		showDescript(3);
		//AlertTips.openTip("能量消耗:60\n冷却时间:50\n超级火力，增强武器攻击速度和伤害持续10秒！\n充值10元解锁？", "tipPupup");
	}
	private function skillImg_Click4(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.t001).play();
		showDescript(4);
		//AlertTips.openTip("能量消耗:85\n冷却时间:50\n终极防御，消除怪物伤害，持续10秒！\n充值50元解锁？", "tipPupup");
	}
	private function skillImg_Click5(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.t001).play();
		showDescript(5);
		//AlertTips.openTip("能量消耗:100\n冷却时间:50\n治愈，补充主角50%血量！\n充值100元解锁？", "tipPupup");
	}
	
	private function skill_Click2(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		showDescript(2);
		btnNum = 2;
		buy();
	}
	
	private function skill_Click3(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		showDescript(3);
		btnNum = 3;
		buy();
	}
	private function skill_Click4(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		showDescript(4);
		btnNum = 4;
		buy();
	}
	
	private function skill_Click5(e:MouseEvent) :Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		showDescript(5);
		btnNum = 5;
		buy();
	}
	
	override function onClose():Void 
	{
		//_widget = null;
		dispose();
		super.onClose();
	}
}