package com.metal.ui.main;
import com.metal.component.GameSchedual;
import com.metal.config.PlayerPropType.PlayerProp;
import com.metal.config.SfxManager;
import com.metal.enums.NoviceOpenType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.GuideManager;
import com.metal.ui.BaseCmd;
import de.polygonal.core.event.IObservable;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author zxk
 */
class TopViewCmd extends BaseCmd
{
	/**金币值*/
	private var moneyNum:Int = 0;
	/**钻石值*/
	private var gemNum:Int = 0;
	
	private var vitFlag:Bool = false;
	private var currTime:Array<Int>;
	
	private var latestFahionBtn:Button;
	private var latestFlag:Bool = false;
	private var _filePath:String;
	private var _maxPower:Int = 100;
	private var main = new MainCmd();

	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		//trace("onInitComponent");
		_widget = UIBuilder.get("topview");
		notify(MsgUIUpdate.UpdateInfo);
		super.onInitComponent();
		vitFlag = false;
			
		currTime = new Array();
		initUI();
		upDate_Vit();
		readTime();
		
		notifyRoot(MsgView.NewBie, 1);//新手指引欢迎界面
		
	}
	
	override public function onUpdate(type:Int, sender:IObservable, userData:Dynamic):Void
	{
			
		if (_unparent)
			return;
		switch(type)
		{
			case MsgUIUpdate.UpdateInfo:
				cmd_update(userData);
			case MsgUIUpdate.Vit:
				latestFlag = true;
				upDate_Vit(userData);
			case MsgUIUpdate.UpdataReturnBtn:
				UpdataFashionBtn(userData);
				
		}
	}
	
	private function initUI():Void
	{
		SfxManager.playBMG(BGMType.b001);
		
		//返回
		_widget.getChildAs("leftBtn", Button).onPress = onBackBtn;
			
		//时装	
		_widget.getChildAs("rightBtn", Button).onPress = function(e)
			{
				trace("click fashion");
				latestFlag = false;
				if (!latestFlag)
				{
					SfxManager.getAudio(AudioType.Btn).play();
					latestFlag = true;
					sendMsg(MsgUI.LatestFashion);
					UpdataFashionBtn(false);
				}
			}
		
		setData(null);
		
		
		_widget.getChildAs("buyVitBtn", Button).onPress = buyVitBtn_click;
		_widget.getChildAs("BuyDiamondsBtn", Button).onPress = BuyDiamondsBtn_click;
		_widget.getChildAs("BuyGoldBtn", Button).onPress = BuyGoldBtn_click;
		_widget.getChildAs("huntBtn", Button).onPress = huntBtn_click;
		_widget.getChildAs("payBtn", Button).onPress = payBtn_click;
		
		if (!GuideManager.instance.checkGuide(NoviceOpenType.NoviceText5))
			_widget.getChildAs("hintBtn", Button).visible = true;
	}
	private function onBackBtn(e)
	{ 
		//trace("onBackBtn");
		SfxManager.getAudio(AudioType.Btn).play();
		sendMsg(MsgUIUpdate.ClearMainView);
		latestFlag = false;
		UpdataFashionBtn(true);
		notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText27);
	}
	/**是否显示时装按钮*/
	private function UpdataFashionBtn(data:Dynamic):Void
	{
		_widget.getChildAs("returnBtnBg", Widget).visible = data;
	}
	/**购买体力*/
	private function buyVitBtn_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		
		var _playInfo = cast(GameProcess.instance.getComponent(GameSchedual), GameSchedual).playerInfo;
		if (_playInfo.data.POWER >= _maxPower)
		{
			openTip("体力已达上限");
		}else {
			openTip("是否花费100颗钻石购买100体力", callBackFun);
		}
	}
	/**确定购买体力*/
	private function callBackFun(flag:Bool):Void
	{
		if (flag)
		{
			var _playerInfo = PlayerUtils.getInfo();
			if (_playerInfo.data.GEM < 100)
			{
				openTip("钻石不足");
				return;
			}
			notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.POWER, data:_maxPower } );
			upDate_Vit();
			notifyRoot(MsgPlayer.UpdateGem, -100);
			readTime();
			notifyRoot(MsgMission.Update, { type:"forge", data: { id:16 }} );
		}
	}
	
	/**打开购买金币界面*/
	private function BuyGoldBtn_click(e):Void
	{
		//trace("BuyGoldBtn_click" + MsgUI.BuyGold);
		sendMsg(MsgUI.BuyGolds);
		UpdataFashionBtn(false);
	}
	/**打开购买钻石界面*/
	private function BuyDiamondsBtn_click(e):Void
	{
		//trace("BuyDiamondsBtn_click" + MsgUI.BuyDiamonds);
		sendMsg(MsgUI.BuyDiamonds);
		UpdataFashionBtn(false);
		
	}
	/**打开购买宝箱界面*/
	public function huntBtn_click(e):Void
	{
		trace("huntBtn_click");
		sendMsg(MsgUI.TreasureHunt);
		UpdataFashionBtn(false);
		notifyRoot(MsgView.NewBie, NoviceOpenType.NoviceText5);
		_widget.getChildAs("hintBtn", Button).visible = false;
	}
	/**打开充值界面*/
	private function payBtn_click(e):Void
	{
		sendMsg(MsgUI2.Pay);
		//UpdataReturnBtn(false);
	}
	/**更新数据*/
	private function cmd_update(data:Dynamic):Void
	{
		//trace("cmd_update");
		//notifyRoot(MsgPlayer.UpdateInfo, obj);
		var playerInfo = PlayerUtils.getInfo();
		//trace("tviweplo.name="+playerInfo.Name);
		moneyNum = playerInfo.data.GOLD;
		gemNum = playerInfo.data.GEM;
		//trace(_widget.getChildAs("jinbikuang", Text).text);
		_widget.getChildAs("jinbikuang", Text).text = Std.string(moneyNum);
		_widget.getChildAs("zuanshikuang", Text).text = Std.string(gemNum);
		//trace(_widget.name);
		//notify(MsgUIUpdate.UpdateUI, _widget.getChildAs("jinbi", Text));
		
		//notifyRoot(MsgView.NewBie, 1);
	}
	/**更新体力*/
	private function upDate_Vit(data:Dynamic = null):Void
	{
		var _playInfo = PlayerUtils.getInfo();
		_widget.getChildAs("vitTxt", Text).text = _playInfo.data.POWER + "/" + _maxPower;
		if (latestFlag)
			notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.NOWTIME, data:Date.now()} );
	}
	override public function onTick(timeDelta:Float) 
	{
		isRecovery();
		super.onTick(timeDelta);
	}
	/**读取体力恢复时间*/
	private function readTime():Void
	{
		getCurrTimes(Date.fromString(PlayerUtils.getInfo().data.NOWTIME));
		//trace(PlayerUtils.getInfo().data.NOWTIME);
	}
	
	/**获取时间*/
	private function getCurrTimes(myDate:Date):String
	{
		var str:String = "";
		
		currTime = [];
		currTime.push(myDate.getFullYear());
		currTime.push(myDate.getMonth()+1);
		currTime.push(myDate.getDate());
		//currTime.push(myDate.getDay());
		currTime.push(myDate.getHours());
		currTime.push(myDate.getMinutes());
		currTime.push(myDate.getSeconds());
		for (i in 0...currTime.length)
		{
			if (i == currTime.length - 1)
			{
				str +=	currTime[i]+""	;
			}else {
				str +=	currTime[i]+","	;
			}
			
		}
		
		return str;
	}
	/**是否恢复体力*/
	private function isRecovery():Void
	{
		if (currTime != null && currTime.length > 0)
		{
			var _playInfo = PlayerUtils.getInfo();
			var nowDate = Date.now();
			if (currTime[0] >= nowDate.getFullYear())
			{
				if (currTime[1] >= nowDate.getMonth()+1)
				{
					if (currTime[2] <= nowDate.getDate())
					{
						if ((nowDate.getDate() - currTime[2]) < 1 )
						{
							if ((nowDate.getHours()-currTime[3])<16)
							{
								var hours =  nowDate.getHours() - currTime[3];
								var minutes =0 ;
								if (hours == 0)
								{
									minutes = nowDate.getMinutes() - currTime[4];
								}else
								{
									minutes = hours * 60 - (60 - nowDate.getMinutes()) + (60 - currTime[4]);
								}
								if (minutes / 5 >= 1)
								{
									var power = _playInfo.data.POWER + Math.floor(minutes / 5);
									if (power > _maxPower)
										power = _maxPower;
									notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.POWER, data:power } );
									latestFlag = true;
									upDate_Vit(null);
									
								}
							}else
							{
								//加满
								latestFlag = true;
								notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.POWER, data:_maxPower } );
								upDate_Vit(null);
							}
						}else
						{
							latestFlag = true;
							notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.POWER, data:_maxPower } );
							upDate_Vit(null);
							//加满体力
						}
					}
				}else
				{
					latestFlag = true;
					notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.POWER, data:_maxPower } );
					upDate_Vit(null);
					//加满体力
				}
			}
		}
	}
	private function setData(data:Dynamic):Void
	{
		if (_unparent) return;
	}
	
	override function onClose():Void 
	{
		notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerProp.NOWTIME, data:Date.now()} );
		_widget = null;
		//SfxManager.getAudio(BGMType.b001).stop();
		super.onClose();
		dispose();
	}
	override function onDispose():Void 
	{
		//SfxManager.getAudio(BGMType.b001).stop();
		super.onDispose();
	}
	
}