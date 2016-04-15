package com.metal.unit.avatar;

import com.haxepunk.Graphic;
import com.haxepunk.Mask;
import com.haxepunk.Tween.TweenType;
import com.haxepunk.tweens.TweenEvent;
import com.haxepunk.tweens.misc.ColorTween;
import com.metal.config.MapLayerType;
import com.metal.enums.Direction;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgEffect;
import com.metal.message.MsgStat;
import com.metal.proto.impl.ModelInfo;
import com.metal.unit.render.ViewDisplay;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.MsgCore;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class AbstractAvatar extends ViewDisplay
{
	private var _model:IAttach;
	private var _info:ModelInfo;
	private var _recolor:Int;
	private var _colorT:ColorTween;
	
	
	public function new(x:Float=0, y:Float=0, graphic:Graphic=null, mask:Mask=null) 
	{
		super(x, y, graphic, mask);
		layer = MapLayerType.ActorLayer;
	}
	
	override public function removed():Void 
	{
		//ResourceManager.instance.recycleGraphic(_model.as(Graphic));
		super.removed();
	}
	
	private function preload():Void { }
	private function createAvatar(name:String, type:String):Dynamic { return null; }
	public function setDirAction(action:String, dir:Direction, loop:Bool = true):Void { }
	public var flip(get, set):Bool;
	private function get_flip():Bool { return false; }
	private function set_flip(value:Bool):Bool { return value; }
	
	override private function onDispose():Void
	{
		_info = null;
		//if(_model!=null)
			//_model.destroy();
		_model = null;
		super.onDispose();
	}
	public function setCallback(fun:Dynamic) { }
	public function startChangeColor():Void
	{
		if (_colorT != null)
			_colorT.start();
	}
	//设置受击闪红
	private function changeColor(tune:Int = 0xff0000):Void
	{
		var _tuneColor:Int = tune;
		_recolor = _model.color;
		_colorT = new ColorTween(TweenType.Persist);
		_colorT.tween(0.1, _recolor, _tuneColor, 0, 0.6);
		_colorT.addEventListener(TweenEvent.FINISH, function(e){
			_colorT.color = -1;
		});
		_colorT.cancel();
		addTween(_colorT);
	}
	
	//{Notify
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgCore.PROCESS:
				Notify_PostBoot(userData);
			case MsgCore.FREE:
				Notify_FREE(userData);
			case MsgActor.EnterBoard:
				Notify_EnterBoard(userData);
			case MsgActor.BornPos:
				Notify_BornPos(userData);
			case MsgActor.Stand:
				Notify_Stand(userData);
			case MsgActor.Move:
				Notify_Move(userData);
			case MsgActor.Jump:
				Notify_Jump(userData);
			case MsgActor.Attack:
				Notify_Attack(userData);
			case MsgActor.Skill:
				Notify_Skill(userData);
			case MsgActor.Injured:
				Notify_Injured(userData);
			case MsgActor.Destroy:
				Notify_Destory(userData);
			case MsgActor.Destroying:
				Notify_Destorying(userData);
			case MsgActor.Respawn:
				Notify_Respawn(userData);
			case MsgEffect.EffectStart:
				Notify_EffectStart(userData);
			case MsgEffect.EffectEnd:
				Notify_EffectEnd(userData);
			case MsgStat.ChangeSpeed:
				Notify_ChangeSpeed(userData);
			case MsgActor.Soul:
				Notify_Soul(userData);
		}
	}
	/* entity notify internal component */
	function Notify_PostBoot(userData:Dynamic) { }
	
	private function Notify_FREE(userData:Dynamic):Void { 
		_isFree = true; 
	}
	private function Notify_Stand(userData:Dynamic):Void {}
	private function Notify_Move(userData:Dynamic):Void {}
	private function Notify_Skill(userData:Dynamic):Void {}
	private function Notify_Jump(userData:Dynamic):Void {}
	private function Notify_Creep(userData:Dynamic):Void {}
	private function Notify_Soul(userData:Dynamic):Void { }
	private function Notify_ChangeSpeed(userData:Dynamic):Void {}
	private function Notify_EffectStart(userData:Dynamic):Void { }
	private function Notify_Attack(userData:Dynamic):Void {}
	private function Notify_Respawn(userData:Dynamic):Void { }
	private function Notify_EffectEnd(userData:Dynamic):Void { }
	private function Notify_Injured(userData:Dynamic):Void { startChangeColor(); }
	private function Notify_Destorying(userData:Dynamic):Void { }
	private function Notify_Destory(userData:Dynamic):Void { }
	private function Notify_EnterBoard(userData:Dynamic):Void { }
	private function Notify_BornPos(userData:Dynamic):Void { }
//}
}