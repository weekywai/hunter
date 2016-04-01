package ru.stablex.ui.widgets;
import flash.display.DisplayObject;
import ru.stablex.ui.events.WidgetEvent;
/**
 * ...
 * @author hyg
 */
class MainStack extends ViewStack
{
	private var openType:String;
	private var _hideIndex:Int = -1;
	public function new()  
	{
		super();
	}

	override public function show(name:String, cb:Void->Void = null, ignoreHistory:Bool = true):Void 
	{
		if (openType == name)
			return;
		openType = name;
		var toHide : DisplayObject = (currentIdx==-1)?null:this.getChildAt(this.currentIdx);
        var toShow : DisplayObject = UIBuilder.get(name);
		if (toShow != null)
		{
			toShow.visible = false;
			addChild(toShow);
		} else {
			toShow = openView(name);
		}
        if( toShow != null ){
            if( !ignoreHistory ){
                this._history.push( this.getChildIndex(toShow) );
            }else {
				if(toHide!=null){
					_hideIndex = this.getChildIndex(toHide);
					cb = clearCB;
				}
			}

            if( toHide != toShow && this.trans != null ){
                this.trans.change(this, toHide, toShow, cb);
            }else{
                toHide.visible = false;
                toShow.visible = true;
                if( cb != null ) cb();
            }
            this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
        }
	}
	
	private function clearCB()
	{
		removeChildAt(_hideIndex);
		_hideIndex =-1;
	}
	private function openView(name:String):DisplayObject
	{
		var loadXml:Dynamic = null;
		switch(name)
		{
			case "activity":	//商店
				loadXml = UIBuilder.buildFn('ui/task/activity.xml');
			case "news":	//消息
				loadXml = UIBuilder.buildFn('ui/news/news.xml');
			case "golds":	//购买金币
				loadXml = UIBuilder.buildFn('ui/buyGoldOrDiamonds/gold.xml');
			case "diamonds":	//钻石
				loadXml = UIBuilder.buildFn('ui/buyGoldOrDiamonds/diamonds.xml');
			case "reward":	//奖励
				loadXml = UIBuilder.buildFn('ui/reward/reward.xml');
			case "gameSet":	//游戏设置
				loadXml = UIBuilder.buildFn('ui/gameSet/gameSet.xml');
			case "helpText":	//游戏设置
				loadXml = UIBuilder.buildFn('ui/gameSet/helpText.xml');
			case "through":	//闯关
				loadXml = UIBuilder.buildFn('ui/copy/through.xml');
			case "treasureHunt":	//寻宝
				loadXml = UIBuilder.buildFn('ui/treasureHunt/treasureHunt.xml');
			case "pay":	//充值8
				loadXml = UIBuilder.buildFn('ui/pay/pay.xml');
			case "warehouse":	//仓库
				loadXml = UIBuilder.buildFn('ui/storehouse/warehouse.xml');
			case "task":	//任务
				loadXml = UIBuilder.buildFn('ui/task/task.xml');
			case "forge"://锻造
				loadXml = UIBuilder.buildFn('ui/forge/forge.xml');
			case "endless"://无尽
				loadXml = UIBuilder.buildFn('ui/endless/endless.xml');
			case "latestFashion":	//时装
				loadXml = UIBuilder.buildFn('ui/latestFashion/latestFashion.xml');
			case "skill":			//技能
				loadXml = UIBuilder.buildFn('ui/skill/skill.xml');
			default:
				trace("请在MainStack类中导入相应xml！");
		}
		if (loadXml != null) {
			var child = addChild(loadXml( { } ));
			child.visible = false;
			return child;
		}
		return null;
	}
	public function clear():Void
	{
		if (numChildren > 0) {
			if (numChildren > 1) {
				back(backCallback);
			}else{
				var toHide = getChildAt(numChildren-1);
				trans.change(this, toHide, null, transCallback, true);
			}
		}
	}
	private function transCallback()
	{
		clearHistory();
		removeChildren();
		openType = "";
	}
	/**
	 * back to ui
	*/
	private function backCallback()
	{
		removeChildAt(numChildren - 1);
		openType = getChildAt(numChildren - 1).name;
	}
	/**
	 * 
	 * @param	name 检测界面是否打开 true 是   false 否
	 * @return
	 */
	public function getType(UIName:String):Bool
	{
		if (openType != "")
		{
			
			openType == UIName?return true:return false;
		}else 
		{
			return false; 
		}
	}

}