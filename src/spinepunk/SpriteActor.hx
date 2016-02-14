package spinepunk;
import de.polygonal.core.time.Timebase;
import openfl.display.Sprite;
import openfl.events.Event;
import spinehaxe.animation.AnimationState;
import spinehaxe.animation.AnimationStateData;
import spinehaxe.platform.nme.renderers.SkeletonRenderer;
import spinehaxe.platform.nme.renderers.SkeletonRendererDebug;
import spinehaxe.Skeleton;
import spinehaxe.SkeletonData;


class SpriteActor extends Sprite{

	private var _id:String;
	private var _UnitModelType:String;
	private var _actor:SkeletonInfo;
	private var _skeletonData:SkeletonData;
	private var lastTime:Float = 0.0;
	private var mode:Int = 1;

    public function new(path:String, name:String, scale:Float = 1,id:Int=1) {
        super();
		
		lastTime = haxe.Timer.stamp();
		_actor = createActor(path, name,scale,id);
		addEventListener(Event.ENTER_FRAME, render);
        addEventListener(Event.ADDED_TO_STAGE, added);
        addEventListener(Event.REMOVED_FROM_STAGE, remove);
    }
	
	public function setAction(action:String, loop:Bool = true):Void
	{
		if (_actor != null) {
			_actor.state.setAnimationByName(0, action, loop);
		}
	}
	private function createActor(path:String, name:String, scale:Float = 1,id:Int=1):SkeletonInfo
	{
		//trace(id);
		_skeletonData = SpinePunk.readSkeletonData(name, path, 1, id);
        
		//for (skin in _skeletonData.skins)
		//{
			//
			//if (skin.name == "clips" + id)
			//{
				//_skeletonData.defaultSkin = skin;
			//}
		//}
		
		var stateData = new AnimationStateData(_skeletonData);
		//stateData.setMixByName("idle_1", "walk_1", 0.2);
        //stateData.setMixByName("walk_1", "idle_1", 0.4);
        //stateData.setMixByName("walk_1", "walk_1", 0.2);
		
		
		var info = new SkeletonInfo();
		info.state = new AnimationState(stateData);
		info.state.setAnimationByName(0, "idle_1", true);
		info.skeleton = new Skeleton(_skeletonData);
		info.skeleton.x = 0;
        info.skeleton.y = 0;
		info.skeleton.flipY = true;
		
		info.skeleton.updateWorldTransform();
		info.skeleton.setBonesToSetupPose();
		info.renderer = new SkeletonRenderer(info.skeleton);
		//info.debugRenderer = new SkeletonRendererDebug(info.skeleton);
		info.renderer.scaleX = info.renderer.scaleY = scale;
		addChild(info.renderer);
		//addChild(info.debugRenderer);
		
		
		return info;
	}
	private function render(e:Event):Void {
        var delta = (haxe.Timer.stamp() - lastTime) / 2;
        lastTime = haxe.Timer.stamp();
        _actor.state.update(delta);
        _actor.state.apply(_actor.skeleton);
        //if (state.getAnimation().getName() == "stand") {
             //After one second, change the current animation. Mixing is done by AnimationState for you.
            //if (state.getTime() > 2) state.setAnimationByName("walk", false);
        //} else {
            //if (state.getTime() > 1) state.setAnimationByName("stand", true);
        //}

        _actor.skeleton.updateWorldTransform();
        if(mode == 0 || mode == 1){
            _actor.renderer.visible = true;
            _actor.renderer.draw();
        } else _actor.renderer.visible = false;
        //if(mode == 0 || mode == 2){
            //_actor.debugRenderer.visible = true;
            //_actor.debugRenderer.draw();
        //} else _actor.debugRenderer.visible = false;

    }
	private function added(e:Event):Void
	{
		this.mouseChildren = false;
		//HXP.engine.addUpdate(this);
        //stage.addEventListener(MouseEvent.CLICK, onClick);
	}
	private function remove(e:Event):Void
	{
		removeEventListener(Event.ENTER_FRAME, render);
        removeEventListener(Event.ADDED_TO_STAGE, added);
        removeEventListener(Event.REMOVED_FROM_STAGE, remove);
		_id = null;
		_UnitModelType = null;
		_actor = null;
		_skeletonData = null;
	}
	public function setSkin(id:Int):Void
	{
		//var skin = skeletonData.skins[0];
		for (skin in _skeletonData.skins)
		{
			trace(skin.name +">>" + id);
			if (skin.name == "clips" + id)
			{
				trace(skin.name+"   =="+id);
				_skeletonData.defaultSkin = skin;
			}
		}
		//update();
		//_actor.skeleton.set_skinName("clips"+id);
	}
	
	public function update():Void
	{
		if (_actor != null) {
			_actor.state.update(Timebase.timeDelta);
			_actor.state.apply(_actor.skeleton);
			_actor.skeleton.updateWorldTransform();
			_actor.renderer.visible = true;
			_actor.renderer.draw();
		}
	}
	public function setAttachment(slotName:String, attachName:String):Void
	{
		var index = _actor.skeleton.data.findSlotIndex(slotName);
		_actor.skeleton.data.slots[index].attachmentName = attachName;
		_actor.skeleton.setToSetupPose();
	}
	public function setAnimation(animation:String):Void 
	{
		_actor.state.setAnimationByName(0, animation, true);
		_actor.skeleton.setBonesToSetupPose();
	}
	public function point(_x:Float,_y:Float ):Void
	{
		_actor.skeleton.x = _x;
        _actor.skeleton.y = _y;
	}
}
class SkeletonInfo {
	public var state:AnimationState;
	public var skeleton:Skeleton;
	public var renderer:SkeletonRenderer;
	public var debugRenderer:SkeletonRendererDebug;
	public function new(){}
}
