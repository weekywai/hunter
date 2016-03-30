package ru.stablex.ui.widgets;
import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
import sys.FileSystem;
import sys.io.File;
#else
import ru.stablex.ui.skins.Skin;
import Type;
import ru.stablex.ui.widgets.Widget;
#end
/**
 * ...
 * @author hyg
 */
class MainStack extends Widget
{
	private var openType:String;
	public function new()  
	{
		super();
	}

	public function show(name:String):Void
	{
		openType = name;
		if (this.numChildren > 0) this.removeChildren();
		var current = UIBuilder.get(name);
		if (current != null)
		{
			this.addChild(current);
		}else
		{
			openView(name);
		}
		
	}
	private function openView(name:String):Void
	{
		var loadXml:Dynamic = null;
		switch(name)
		{
			case "activity":	//商店
				loadXml = UIBuilder.buildFn('ui/task/activity.xml');
			case "news":	//消息
				loadXml = UIBuilder.buildFn('ui/news/news.xml');
			case "gold":	//购买金币
				loadXml = UIBuilder.buildFn('ui/buyGoldOrDiamonds/gold.xml');
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
			case "pay":	//充值
				loadXml = UIBuilder.buildFn('ui/pay/pay.xml');
			case "warehouse":	//仓库
				loadXml = UIBuilder.buildFn('ui/storehouse/warehouse.xml');
			case "task":	//任务
				loadXml = UIBuilder.buildFn('ui/task/task.xml');
			case "forge"://锻造
				loadXml = UIBuilder.buildFn('ui/forge/forge.xml');
			case "endless"://无尽
				loadXml = UIBuilder.buildFn('ui/endless/endless.xml');
			case "diamonds":	//钻石
				loadXml = UIBuilder.buildFn('ui/buyGoldOrDiamonds/diamonds.xml');
			case "latestFashion":	//时装
				loadXml = UIBuilder.buildFn('ui/latestFashion/latestFashion.xml');
			case "skill":			//技能
				loadXml = UIBuilder.buildFn('ui/skill/skill.xml');
			case "noviceCourse":	
				loadXml = UIBuilder.buildFn('ui/noviceGuide/noviceCourse.xml');
			default:
				trace("请在MainStack类中导入相应xml！");
		}
		if (loadXml != null) this.addChild(loadXml({}));
		
	}
	public function clear():Void
	{
		this.removeChildren();
		openType = "";
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