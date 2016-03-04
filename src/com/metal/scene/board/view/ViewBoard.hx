package com.metal.scene.board.view;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.HXP;
import com.metal.component.BattleComponent;
import com.metal.config.MapLayerType;
import com.metal.config.SfxManager;
import com.metal.enums.MapVo;
import com.metal.enums.RunVo;
import com.metal.message.MsgBoard;
import com.metal.message.MsgStartup;
import com.metal.message.MsgView;
import com.metal.proto.impl.MapRoomInfo;
import com.metal.proto.manager.MapInfoManager;
import com.metal.scene.board.impl.GameBoard;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.time.Delay;
import haxe.Timer;
#if spriteRenderer
import openfl.tiled.TiledMap;
#end
import motion.Actuate;
/**
 * ...
 * @author weeky
 */
class ViewBoard extends Component
{
	private var _board:GameBoard;
	private var _curMap:MapVo;
	private var _bgSound:Dynamic;
	#if spriteRenderer
	private var _viewMap:TiledMap;
	#end
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_board = owner.getComponent(GameBoard);
	}
	
	override function onDispose():Void 
	{
		_bgSound = null;
		super.onDispose();
		_board = null;
		_curMap = null;
		HXP.scene.removeAll();
		#if spriteRenderer
		_viewMap.dispose();
		#end
	}
	
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgStartup.AssignMap:
				cmd_AssignMap(userData);
			case MsgStartup.Start:
				cmd_SetBattle(userData);
			case MsgStartup.Reset:
				cmd_Reset(userData);
			case MsgView.ChangeMapSpeed:
				cmd_ChangeMapSpeed(userData);
		}
		super.onNotify(type, source, userData);
	}
	
	private function cmd_SetBattle(userData:Dynamic):Void {
		notify(MsgStartup.LoadMap);
	}
	
	private function cmd_Reset(userData:Dynamic):Void
	{
		#if spriteRenderer
		if (_viewMap != null)
			_viewMap.dispose();
		_viewMap = null;
		#end
	}
	
	private function cmd_AssignMap(userData:Dynamic):Void
	{
		trace("assign map");
		_curMap = cast(userData, MapVo);
		HXP.scene.add(_curMap.floorTmx);
		HXP.scene.add(_curMap.collideLayer);
		//HXP.scene.add(new Explosion("yan"));
		#if spriteRenderer
			_viewMap = new TiledMap("", _curMap.map, _curMap.runKey);
			GameProcess.gameStage.addChildAt(_viewMap, 0);
		#else 
			//背景
			var image:String = _curMap.map.imageLayers.get("Background");
			if (image != null)
				HXP.scene.addGraphic(new Backdrop(image), MapLayerType.MapLayer);
			
			var layer:Int;
			for (total in 0...MapVo.nLen) {
				layer = MapVo.orderArr[total];
				var tempW:Int = _curMap.map.width * _curMap.map.tileWidth;
				var tempH:Int = _curMap.map.height * _curMap.map.tileHeight;
				_curMap.getEntityByLayer(layer).width = tempW;
				_curMap.getEntityByLayer(layer).height = tempH;
				
				HXP.scene.add(_curMap.getEntityByLayer(layer));
			}
		#end
		
		runLayer(_curMap.mapId);
		var battle:BattleComponent = GameProcess.root.getComponent(BattleComponent);
		var roomInfo:MapRoomInfo = MapInfoManager.instance.getRoomInfo(Std.parseInt(battle.currentRoomId()));
		_bgSound = SfxManager.getEnumType(roomInfo.Round);
		SfxManager.playBMG(_bgSound,2);
		//var bg:Backdrop = new Backdrop("map/Res/sky.png");
		//HXP.scene.addGraphic(bg);
		#if spriteRenderer
		notify(MsgBoard.AddViewMap, _viewMap);
		#end
		Actuate.tween(this,2,{}).onComplete(notify, [MsgBoard.StartAI]);
	}
	
	private function cmd_ChangeMapSpeed(userData:Dynamic):Void
	{
		var tempMapInfo:MapRoomInfo = MapInfoManager.instance.getRoomInfo(Std.parseInt(_curMap.mapId));
		for (index in 0...MapVo.nLen) {
			var speed:Dynamic = cast(tempMapInfo.runData.get(index), RunVo).runSpeed;
			if(speed != null){
				_curMap.getEntityByLayer(index).addSpeed = userData;
			}
		}
	}
	/**移除当前场景所有景层*/
	public function clearAllLayerByCurMap():Void
	{
		for (total in 0...MapVo.nLen) {
			HXP.scene.remove(_curMap.getEntityByLayer(total));
		}
	}
	
	/**滚动图层**/
	public function runLayer(mapId:String):Void
	{
		var tempMapInfo:MapRoomInfo = MapInfoManager.instance.getRoomInfo(Std.parseInt(mapId));
		#if !spriteRenderer
			for (index in 0...MapVo.nLen) {
				var speed:Dynamic = tempMapInfo.runData.get(index).runSpeed;
				if (speed != null && speed != 0) {
					_curMap.getEntityByLayer(index).startRunLayer(speed);
				}
			}
			
		#else
			_viewMap.startRoll(tempMapInfo.runData);
		#end
	}
	
	public function runLayerByIndex(layer:Int, speed:Int):Void
	{
		//越界直接返回
		//if (layer<0 || layer>=MapVo.nLen)return;
		switch (layer) {
			case 1, 2, 3:
				_curMap.getEntityByLayer(1).startRunLayer(speed);
				_curMap.getEntityByLayer(2).startRunLayer(speed);
				_curMap.getEntityByLayer(3).startRunLayer(speed);
			default:
				_curMap.getEntityByLayer(layer).startRunLayer(speed);
		}
	}
	
	
	public function stopLayer():Void
	{
		for (total in 0...MapVo.nLen) {
			_curMap.getEntityByLayer(total).stopRunLayer();
		}
	}
	
	
}