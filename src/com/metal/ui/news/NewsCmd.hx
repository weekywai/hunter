package com.metal.ui.news;

import com.metal.component.GameSchedual;
import com.metal.config.FilesType;
import com.metal.config.SfxManager;
import com.metal.config.TableType;
import com.metal.message.MsgPlayer;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.NewsInfo;
import com.metal.utils.FileUtils;
import haxe.ds.IntMap;
import ru.stablex.ui.widgets.Text;
import com.metal.ui.BaseCmd;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Button;

/**
 * ...
 * @author cqm
 */
class NewsCmd extends BaseCmd
{
	private var newsInfo:NewsInfo = new NewsInfo();
	
	public function new() 
	{
		super();
		
	}
	override function onInitComponent():Void 
	{
		_widget = UIBuilder.get("news");
		super.onInitComponent();
		initNews();
	}
	private function initNews():Void
	{
		var newMapInfo = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual).newMapInfo;
		//trace(_newMapInfo);
		var newsVBox = _widget.getChildAs("newsVBox", VBox);
		if (newsVBox.numChildren > 0) newsVBox.removeChildren();
		for (key in newMapInfo.keys())
		{
			var news:NewsInfo = newMapInfo.get(key);
			var oneNews = UIBuilder.buildFn("ui/news/oneNews.xml")();
			newsVBox.addChild(oneNews); 
			oneNews.getChildAs("Characteristic", Text).text = news.Num + "金币"; 
			if (news.isDraw == 0)
			{
				oneNews.getChildAs("newsBtn", Button).onPress = function(e)
				{
					SfxManager.getAudio(AudioType.t001).play();
					notifyRoot(MsgPlayer.UpdateMoney, news.Num);
					oneNews.getChildAs("newsBtn", Button).disabled = true;
					oneNews.getChildAs("newsBtn", Button).text = "已领取";
					news.isDraw = 1;
					RemoteSqlite.instance.updateProfile(TableType.P_News, news, { Id:news.Id } );
					//封测奖励10000
				}
			}else
			{
				oneNews.getChildAs("newsBtn", Button).disabled = true;
				oneNews.getChildAs("newsBtn", Button).text = "已领取";
			}
		}
	}
	
}