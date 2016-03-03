package com.metal.ui.main;
import com.metal.component.GameSchedual;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.enums.NoviceOpenType;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerUtils;
import com.metal.ui.BaseCmd;
import com.metal.ui.popup.TipCmd;
import com.metal.utils.FileUtils;
import com.metal.utils.LoginFileUtils;
import de.polygonal.core.event.IObservable;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

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
	
	private var mainStack:MainStack;
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
		trace("onInitComponent");
		_widget = UIBuilder.get("topview");
		//playerInfo = FileUtils.getPlayerInfos();
		notify(MsgUIUpdate.UpdateInfo);
		super.onInitComponent();
		vitFlag = false;
		var _bagInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).bagData;
			
		currTime = new Array();
		mainStack = cast(UIBuilder.get("allView"),MainStack);
		initUI();
		upDate_Vit();
		readTime();
		
		notifyRoot(MsgView.NewBie, 1);//新手指引欢迎界面
		
	}
	
	override public function onNotify(type:Int, sender:IObservable, userData:Dynamic):Void
	{
			
		if (_unparent)
			return;
		switch(type)
		{
			case MsgUIUpdate.UpdateInfo:
				cmd_update(userData);
			/*case MsgUI.MainPanel:
				cmd_update(userData);
				trace("user000");*/
			case MsgUIUpdate.Vit:
				latestFlag = true;
				upDate_Vit(userData);
			case MsgUIUpdate.UpdataReturnBtn:
				UpdataReturnBtn(userData);
				
		}
	}
	
	private function initUI():Void
	{
		SfxManager.playBMG(BGMType.b001);
		//_widget.getChildAs("backBtn", Button);
		
		//返回
		_widget.getChildAs("leftBtn", Button).onPress = function(e)
			{ 
				SfxManager.getAudio(AudioType.Btn).play();
				if (mainStack.numChildren > 0)
				mainStack.clear();
				latestFlag = false;
				UpdataReturnBtn(true);
				//notifyRoot(MsgView.NewBie, 17);
				notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText27);
			}
		//时装	
		_widget.getChildAs("rightBtn", Button).onPress = function(e)
			{
				//if (mainStack.numChildren > 0) 
				//{
					//latestFlag = true;
				//}
			//else { latestFlag = false; }
				latestFlag = false;
				if (!latestFlag)
				{
					SfxManager.getAudio(AudioType.Btn).play();
					latestFlag = true;
					mainStack.show('latestFashion');
					sendMsg(MsgUI.LatestFashion);
					UpdataReturnBtn(false);
				}
			}
		
		setData(null);
		
		
		_widget.getChildAs("buyVitBtn", Button).onPress = buyVitBtn_click;
		_widget.getChildAs("BuyDiamondsBtn", Button).onPress = BuyDiamondsBtn_click;
		_widget.getChildAs("BuyGoldBtn", Button).onPress = BuyGoldBtn_click;
		_widget.getChildAs("huntBtn", Button).onPress = huntBtn_click;
		_widget.getChildAs("payBtn", Button).onPress = payBtn_click;
		if (LoginFileUtils.Id != "null"){
			var newbieList:Array<Int> = GameProcess.root.getComponent(GameSchedual).newbieList;
			if (!Lambda.has(newbieList, NoviceOpenType.NoviceText5))
				_widget.getChildAs("hintBtn", Button).visible = true;
		}
	}
	/**是否显示时装按钮*/
	private function UpdataReturnBtn(data:Dynamic):Void
	{
		_widget.getChildAs("returnBtnBg", Widget).visible = data;
	}
	/**购买体力*/
	private function buyVitBtn_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		
		var _playInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).playerInfo;
		if (_playInfo.getProperty(PlayerPropType.POWER) >= _maxPower)
		{
			sendMsg(MsgUI.Tips, { msg:"体力已达上限", type:TipsType.tipPopup} );
		}else{
			sendMsg(MsgUI.Tips, { msg:"是否花费100颗钻石购买100体力", type:TipsType.buyTip} );
			var tipCmd:TipCmd = new TipCmd();
			tipCmd.onInitComponent();
			tipCmd.callbackFun.addOnce(callBackFun);
		}
	}
	/**确定购买体力*/
	private function callBackFun(flag:Bool):Void
	{
		if (flag)
		{
			var _playerInfo = PlayerUtils.getInfo();
			if (_playerInfo.getProperty(PlayerPropType.GEM) < 100)
			{
				sendMsg(MsgUI.Tips, { msg:"钻石不足", type:TipsType.tipPopup} );
				return;
			}
			notifyRoot(MsgNet.UpdateInfo, { type:PlayerPropType.POWER, data:_maxPower } );
			upDate_Vit();
			notifyRoot(MsgPlayer.UpdateGem, -100);
			readTime();
			notifyRoot(MsgMission.Update, { type:"forge", data: { id:16 }} );
			//FileUtils.setFileData(_playerInfo, FilesType.player);
		}
	}
	
	/**打开购买金币界面*/
	private function BuyGoldBtn_click(e):Void
	{
		
		mainStack.show('gold');
		sendMsg(MsgUI.BuyGold);
		UpdataReturnBtn(false);
	}
	/**打开购买钻石界面*/
	private function BuyDiamondsBtn_click(e):Void
	{
		mainStack.show('diamonds');
		sendMsg(MsgUI.BuyDiamonds);
		UpdataReturnBtn(false);
		
	}
	/**打开购买宝箱界面*/
	public function huntBtn_click(e):Void
	{
		mainStack.show('treasureHunt');
		sendMsg(MsgUI.TreasureHunt);
		UpdataReturnBtn(false);
		notifyRoot(MsgView.NewBie, NoviceOpenType.NoviceText5);
		_widget.getChildAs("hintBtn", Button).visible = false;
	}
	/**打开充值界面*/
	private function payBtn_click(e):Void
	{
		//mainStack.show('pay'); 
		//sendMsg(MsgUI.Pay);
		
		//UpdataReturnBtn(false);
	}
	/**更新数据*/
	private function cmd_update(data:Dynamic):Void
	{
		//trace("cmd_update");
		//notifyRoot(MsgPlayer.UpdateInfo, obj);
		var playerInfo = PlayerUtils.getInfo();
		//trace("tviweplo.name="+playerInfo.Name);
		moneyNum = playerInfo.getProperty(PlayerPropType.GOLD);
		gemNum = playerInfo.getProperty(PlayerPropType.GEM);
		//trace(_widget.getChildAs("jinbikuang", Text).text);
		_widget.getChildAs("jinbikuang", Text).text = Std.string(moneyNum);
		_widget.getChildAs("zuanshikuang", Text).text = Std.string(gemNum);
		//trace(_widget.name);
		//notify(MsgUIUpdate.UpdateUI, _widget.getChildAs("jinbi", Text));
		FileUtils.setFileData(playerInfo, FilesType.Player);
		
		//notifyRoot(MsgView.NewBie, 1);
	}
	/**更新体力*/
	private function upDate_Vit(data:Dynamic = null):Void
	{
		var _playInfo = PlayerUtils.getInfo();
		if (_playInfo.getProperty(PlayerPropType.POWER) > _maxPower)
			notifyRoot(MsgPlayer.UpdateInfo, { type:PlayerPropType.POWER, data:_maxPower } );
		_widget.getChildAs("vitTxt", Text).text = _playInfo.getProperty(PlayerPropType.POWER) + "/" + _maxPower;
		if (latestFlag)
		{
			saveFile(_filePath);
		}else
		{
			
		}
	}
	override public function onTick(timeDelta:Float) 
	{
		isRecovery();
		super.onTick(timeDelta);
	}
	/**读取体力恢复时间*/
	private function readTime():Void
	{
		#if sys
		var path:String = FileUtils.getPath() + "proto/";
		_filePath = path + "asdf.txt";
		if (!FileSystem.exists(path))
		{
			FileSystem.createDirectory(path);
		}
		if (!FileSystem.exists(_filePath)) {
			saveFile(_filePath);
		}
		
		//read the message
		var sanityCheck:String = File.getContent(_filePath);
		
		var fin = File.read(_filePath, false);
		var lineNum = 0;
		var str:String = fin.readLine();
		currTime = [];
		var strArr = str.split(",");
		for (i in 0...strArr.length)
		{
			currTime.push(Std.parseInt(strArr[i]));
		}
		fin.close();
		#end
	}
	/**保存体力提升时当前的时间*/
	private function saveFile(filePath:String)
	{
		var f:FileOutput = File.write( filePath, false );
		f.writeString(getCurrTimes());
		f.close();
	}
	/**获取时间*/
	private function getCurrTimes():String
	{
		var myDate = Date.now();
		
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
			var _playInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).playerInfo;
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
									notifyRoot(MsgPlayer.UpdateInfo,{type:PlayerPropType.POWER,data:_playInfo.getProperty(PlayerPropType.POWER) + Math.floor(minutes / 5)});
									latestFlag = true;
									upDate_Vit(null);
									
								}
							}else
							{
								//加满
								latestFlag = true;
								notifyRoot(MsgPlayer.UpdateInfo,{type:PlayerPropType.POWER,data:_maxPower});
								upDate_Vit(null);
							}
						}else
						{
							latestFlag = true;
							notifyRoot(MsgPlayer.UpdateInfo,{type:PlayerPropType.POWER,data:_maxPower});
							upDate_Vit(null);
							//加满体力
						}
					}
				}else
				{
					latestFlag = true;
					notifyRoot(MsgPlayer.UpdateInfo,{type:PlayerPropType.POWER,data:_maxPower});
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
		saveFile(_filePath);
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