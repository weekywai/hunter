package com.metal.ui.dialogue;
import com.metal.component.BattleComponent;
import com.metal.message.MsgUI2;
import com.metal.ui.BaseCmd;
import de.polygonal.core.event.IObservable;
import openfl.events.MouseEvent;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Floating;
import ru.stablex.ui.widgets.Text;

/**
 * ...
 * @author weeky
 */
class DialogueCmd extends BaseCmd
{
	private var _talk:Text;
	private var _index:Int;
	private var _count:Int;
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		_widget = UIBuilder.buildFn("ui/dialogue/dialogue.xml")({});
		//_widget = UIBuilder.get("dialogue");
		_talk = _widget.getChildAs("content", Text);
		_widget.getChild("guidL").visible = true;
		_widget.getChild("guidR").visible = false;
		_widget.getChild("lead").visible = false;
		_widget.getChild("boss").visible = false;
		
		super.onInitComponent();
		
	}
	
	override function onDispose():Void 
	{
		_talk = null;
		super.onDispose();
	}
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onNotify(type, source, userData);
		switch(type){
			case MsgUI2.Dilaogue:
				cmd_Dilaogue(userData);
		}
	}
	private function cmd_Dilaogue(userData:Dynamic)
	{
		var talkList:Array<String> = userData;
		_count = 0;
		
		if (_count >= talkList.length) {
			endTalk();
			return;
		}
		_talk.text = talkList[_count];
		
		_widget.addEventListener(MouseEvent.CLICK, function(e) {
			_count++;
			trace(talkList.length +">>"+_count);
			if (_count >= talkList.length) {
				endTalk();
				return;
			}
			_talk.text = talkList[_count];
		});
		cast(_widget, Floating).show();
		GameProcess.instance.pauseGame(true);
	}
	
	private function endTalk()
	{
		GameProcess.instance.pauseGame(false);
		trace("endTalk");
		cast(_widget, Floating).hide();
	}
}