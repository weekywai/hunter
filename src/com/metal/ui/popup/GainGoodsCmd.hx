package com.metal.ui.popup;
import com.metal.config.EquipProp;
import com.metal.config.SfxManager;
import com.metal.message.MsgNet;
import com.metal.proto.manager.GoodsProtoManager;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Box;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.VBox;
import ru.stablex.ui.widgets.Widget;

/**
 * ...购买宝箱获得物品显示界面
 * @author hyg
 */
class GainGoodsCmd extends BaseCmd
{

	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_widget = UIBuilder.get("gainGoods");
		super.onInitComponent();
		_widget.getChildAs("suerBtn", Button).onPress = suerBtn_click;
		
	}
	/**点击确定，关闭界面*/
	private function suerBtn_click(e):Void
	{
		SfxManager.getAudio(AudioType.Btn).play();
		_widget.getParent('popup').free();
		dispose();
	}
	/**设置数据，显示获得物品*/
	public function setData(data:Array<Int>):Void
	{
		var panel = _widget.getChildAs("panel",Widget);
		if (panel.numChildren > 0) 
			panel.removeChildren();
		for (i in 0...data.length)
		{
			var id = data[i];
			var tempInfo = GoodsProtoManager.instance.getItemById(id);
			if (tempInfo != null) {
				
				var quality:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.ID), x:14, y:15 } );
				var quality_1:Bmp = UIBuilder.create(Bmp, { src:GoodsProtoManager.instance.getColorSrc(tempInfo.ID,0), x:7, y:8 } );
				
				var len:Int = data.length;
				if (data.length > 5)
				{
					len = 5;
				};
				
				var nameTxt:Text = UIBuilder.create(Text, {x:0,y:111 } );
				nameTxt.resetFormat(EquipProp.levelColor(""+tempInfo.Color), 24, true);
				nameTxt.text = tempInfo.Name;
				
				var bg:VBox = UIBuilder.create(VBox, {
					w:150,
					h:150,
					x:Std.int(panel.wparent.w) * 0.5 - ((len * 150) * 0.5) + 150 * (i % 5), 
					y:100+150*(Math.floor(i/5)),
					children : [
						UIBuilder.create(Box, { 
							skinName:'forgeImg12',
							children : [
								UIBuilder.create(Box, { skinName : "forgelvImg" + tempInfo.Color, children : [
									UIBuilder.create(Bmp, { src:'icon/' + tempInfo.ResId + '.png' } )
								] } )
							]
						} ),
						nameTxt
					]
				} );
				panel.addChild(bg);
			}
		}
		GameProcess.root.notify(MsgNet.UpdateBag, { type:1, data:data } );
	}
	override function onDispose():Void 
	{
		_widget = null;
		super.onDispose();
	}
	
}