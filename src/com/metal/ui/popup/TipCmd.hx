package com.metal.ui.popup;

import com.metal.config.SfxManager;
import com.metal.ui.BaseCmd;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import signals.Signal1;

/**
 * ...通用确认提示框
 * @author hyg
 */
class TipCmd extends BaseCmd
{
	public var callbackFun:Signal1<Dynamic>;
	private var _data:Dynamic;
	public function new() 
	{
		super();
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("tipPopup");
		callbackFun = new Signal1();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_widget.getChildAs("noBtn", Button).onPress = noBtn_click;
		_widget.getChildAs("yesBtn", Button).onPress = yesBtn_click;
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
		SfxManager.getAudio(AudioType.Btn).play();
		callbackFun.dispatch(true);
		dispose();
	}
	
	override function onDispose():Void 
	{
		UIBuilder.get("popup").free(); 
		callbackFun.removeAll();
		callbackFun = null;
		_widget = null;
		super.onDispose();
	}
}