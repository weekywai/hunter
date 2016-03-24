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
	public var txt(default, set):String;
	public function new() 
	{
		super();
		
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("flagTip");
		callbackFun = new Signal1();
		super.onInitComponent();
		
		
		onEnabel();
	}
	/**设置标题*/
	private function set_txt(text:String):String
	{
		return _widget.getChildAs("tipTxt", Text).text = text;
	}
	private function onEnabel():Void
	{
		_widget.getChildAs("noBtn", Button).onPress = noBtn_click;
		_widget.getChildAs("yesBtn", Button).onPress = yesBtn_click;
	}
	/*否*/
	private function noBtn_click(e):Void
	{	
		SfxManager.getAudio(AudioType.Btn).play();
		_widget.getParent('popup').free(); callbackFun.dispatch(false);
		dispose();
		
	}
	/*是*/
	private function yesBtn_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		_widget.getParent('popup').free(); callbackFun.dispatch(true);
		dispose();
	}
	override function onClose():Void 
	{
		super.onClose();
	}
	override function onDispose():Void 
	{
		callbackFun = null;
		_widget = null;
		super.onDispose();
	}
}