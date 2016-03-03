package com.metal.ui.battleResult;

import com.metal.component.BattleComponent;
import com.metal.config.SfxManager;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.ui.BaseCmd;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Button;

/**
 * 失败结算
 * @author hyg
 */
class BattleFailureCmd extends BaseCmd
{

	public function new() 
	{ 
		super(); 
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("failure");
		setData();
		_widget.getChildAs("suerBtn", Button).onRelease = suerBtn_click;
	}
	/*设置数据*/
	private function setData():Void
	{
		
	}
	
	private function suerBtn_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		var main = UIBuilder.buildFn('ui/mainIndex.xml')( { } );
		main.show();
		_widget.getParent("popup").free();
		sendMsg(MsgUI.MainPanel);
		var battle:BattleComponent = GameProcess.root.getComponent(BattleComponent);
		var duplicateInfo = battle.currentStage();
		if (duplicateInfo.DuplicateType == 9)
		{
			notify(MsgUIUpdate.OpenCopy);
		}else if(duplicateInfo.DuplicateType == 1){
			notify(MsgUIUpdate.OpenThrough);
		}
	}
	override function onClose():Void 
	{
		_widget = null;
		super.onClose();
	}
	override function onDispose():Void 
	{
		super.onDispose();
	}
}