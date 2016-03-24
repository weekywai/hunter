package com.metal.ui.gameSet;
import com.haxepunk.Sfx;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.SfxManager;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.player.utils.PlayerInfo;
import com.metal.ui.BaseCmd;
import com.metal.utils.FileUtils;
import de.polygonal.core.event.IObservable;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Switch;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.MainStack;
/**
 * ...
 * @author zxk
 */
class GameSetCmd extends BaseCmd
{
	private var mainStack:MainStack;
	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		//SfxManager.getAudio(AudioType.t001).play();
		mainStack = cast(UIBuilder.get("allView"),MainStack);
		_widget = UIBuilder.get("gameSet");
		super.onInitComponent();
		setData();
	}
	
	private function setData():Void
	{
		var soundSwitch:Switch = _widget.getChildAs("Sound",Switch);
		var bgmSwitch:Switch = _widget.getChildAs("BGM", Switch);
		
		soundSwitch.selected = SfxManager.StopSound;
		bgmSwitch.selected = SfxManager.StopBGM;
		soundSwitch.addEventListener(MouseEvent.CLICK, OnSound);
		bgmSwitch.addEventListener(MouseEvent.CLICK, OnBgm); 
		_widget.getChildAs("help", Button).onPress=onHelp;
	}
	private function onHelp(e):Void 
	{
		//SfxManager.getAudio(AudioType.Btn).play(); 
		//mainStack.show("helpText");
		
	}
	private function OnBgm(e:MouseEvent):Void 
	{
		var BGM:Bool = _widget.getChildAs("BGM", Switch).selected;
		notifyRoot(MsgPlayer.UpdateBGM, BGM);
		if (BGM)
		{
			//SfxManager.playBMG(BGMType.b001);
		}else {
			//SfxManager.getAudio(BGMType.b001).play(1,0,false);
			//Sfx.stopAllSound();
		}
	}
	
	private function OnSound(e:MouseEvent):Void 
	{
		var Sound:Bool = _widget.getChildAs("Sound", Switch).selected;
		notifyRoot(MsgPlayer.UpdateSounds, Sound);
	}
	override function onDispose():Void 
	{
		_widget.free();
		super.onDispose();
	}
	override function onClose():Void
	{
		dispose();
		super.onClose();
	}
}