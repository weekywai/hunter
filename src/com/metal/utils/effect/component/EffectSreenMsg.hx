package com.metal.utils.effect.component;
import com.haxepunk.HXP;
import com.metal.config.MsgType;
import com.metal.manager.UIManager;
import openfl.filters.DropShadowFilter;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Text;

/**
 * 金币飞行
 * @author weeky
 */
class EffectSreenMsg extends BaseEffect
{
	private var _txt:Text;
	public function new(target:Dynamic=null, params:Dynamic=null,src:String = "")
	{
		super(target, params,src);
	}
	
	override public function play(endFunc:BaseEffect->Void):Void
	{
		super.play(endFunc);
		_txt = UIBuilder.create(Text, {
			x:HXP.halfWidth,
			y:HXP.halfHeight,
			filters:[new DropShadowFilter(2, 45, 0x000000, 1, 3, 3, 1)],
			mouseEnabled:false
		});
		//_txt.resetFormat(0xff0000, 34);
		_txt.resetFormat(0x11c9ff, 34);
		_txt.text = MsgType.getGameMsg(param);
		_txt.x -= _txt.w * 0.5;
		cast(GameProcess.UIRoot, UIManager).effLayer.addChild(_txt);
		_txt.tween(2,{ y:HXP.height * 0.2, alpha:0}).onComplete(finish);
	}
	
	override public function finish():Void
	{
		_txt.free(true);
		super.finish();
	}
	
	
	
}