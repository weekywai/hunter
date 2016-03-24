package com.metal.ui;

import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.GameProcess;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgNet;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.RandomNameManager;
import com.metal.utils.LoginFileUtils;
import de.polygonal.core.event.IObservable;
import openfl.Assets;
import openfl.events.Event;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Floating;
import ru.stablex.ui.widgets.InputText;
import ru.stablex.ui.widgets.Widget;
/**
 * ...
 * @author weeky
 */
class LoginRegistCmd extends BaseCmd
{
	//private var regist:Widget;
	private var createPlayer:Widget;
	
	private var nameTxt:InputText;
	
	
	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		parseProto(ResPath.getProto("randomlynamed"), RandomNameManager);
		
		_widget = UIBuilder.get("loginStart");
		super.onInitComponent();
		//regist = UIBuilder.get("regists");
		createPlayer = UIBuilder.get("createPlayer");
		nameTxt = createPlayer.getChildAs("inputName",InputText);
		//trace(_widget);
		createName();
		onEnabled();
	}
	
	override function onDispose():Void 
	{
		//regist = null;
		createPlayer = null;
		nameTxt = null;
		super.onDispose();
	}
	/*事件触发*/
	private var _main:Floating;
	private function onEnabled():Void
	{
		//注册
		_widget.getChildAs("loginBtn_1", Button).onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
			GMLogin();
			/*
			LoginFileUtils.Id = "null";
			notifyRoot(MsgNet.AssignAccount);
			_main = UIBuilder.buildFn('ui/mainIndex.xml')( { } );
			//_main = UIBuilder.getAs("main", Floating);
			_main.show();
			GameProcess.instance.initGame();
			dispose();
			*/
		}
		createPlayer.getChildAs("randName", Button).onPress = randName_click;//点击昵称界面的随机名字按钮
	}
	private function textInputHandler(e:Event):Void 
	{
		var charExp:EReg = ~/[A-Z0-9]/i;
		var str:String = e.currentTarget.text;
		var c = str.charAt(str.length-1);
		if (!charExp.match(c)){
			//trace("not eng::"+c+" match:"+charExp.match(c));
			sendMsg(MsgUI.Tips, { msg:"密码只能是英文或数字", type:TipsType.tipPopup} );
			e.currentTarget.text = str.substr(0, str.length - 1);
		}
	}
	
	/**点击随机名字*/
	private function randName_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		createName();
	}
	
	/**创建名字*/
	private function createName():Void
	{
		//暂时没分性别,男唯一
		var randomNum:Int = Math.floor(Math.random() * 495);
		if (randomNum == 0) randomNum = Math.floor(Math.random() * 495);
		var surname:String = RandomNameManager.instance.getRandomProtp(randomNum).Surname;
		var nameNum:Int = Math.floor(Math.random() * 495);
		if(nameNum==0)nameNum = Math.floor(Math.random() * 495);
		var name:String = RandomNameManager.instance.getRandomProtp(nameNum).Name;
		nameTxt.text = surname+name;
	}
	
	private function onLogin(loginData:Dynamic, ?name:String)
	{
		sendMsg(MsgUI2.Loading, true);
		LoginFileUtils.saveLogin(loginData, name);
		notifyRoot(MsgNet.AssignAccount);
		if(name!=null){
			PlayerUtils.getInfo().Name = name;
			//sendMsg(MsgUI2.Loading, true);
		}
		var main = UIBuilder.buildFn('ui/mainIndex.xml')( { } );
		main.show();
		GameProcess.instance.initGame();
		notifyRoot(MsgNet.UpdateInfo);
		dispose();
		//UIBuilder.get("loginStart").free(true);	
	}
	
	override public function onUpdate(type:Int, sender:IObservable, userData:Dynamic):Void
	{
		switch(type){
			case MsgUI2.GMLogin:
				GMLogin();
		}
	}
	override public function onTick(timeDelta:Float) 
	{
		//trace();
		super.onTick(timeDelta);
	}
	
	private function GMLogin():Void
	{
		LoginFileUtils.Id = "null";
		notifyRoot(MsgNet.AssignAccount);
		
		var main = UIBuilder.buildFn('ui/mainIndex.xml')( { } );
		main.show();
		GameProcess.instance.initGame();
		dispose();
		//UIBuilder.get("loginStart").free(true);
	}
	
	
	private function parseProto(source:String, manager:Dynamic)
	{
		var xml = Xml.parse(Assets.getText(source));
		manager.instance.appendXml(xml);
	}
}