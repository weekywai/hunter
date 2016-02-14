package com.haxepunk.gui;

import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.TextureAtlas;
import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

#if flash
typedef Skin = BitmapData;
#else
typedef Skin = AtlasRegion;
#end

/**
 * Parent class for every controls. Manage default skin and control composition.
 * When using a control as child of a container, only use localX and localY to have relative coordinates.
 * @author PigMess
 * @author AClockWorkLemon
 * @author Rolpege
 * @author Lythom
 * @author MattTuttle
 */
#if haxe3
class Control extends Entity implements IEventDispatcher
#else
class Control extends Entity, implements IEventDispatcher
#end
{
	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "shown";
	static public inline var RESIZED:String = "resized";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";

	/**
	 * Default layer where new Controls are placed.
	 */
	public static var defaultLayer:Int = 100;
	public static var skinSliceSize:Int = 8;
	
	/**
	 * Getter to the current skin BitmapData
	 */
	public static var currentSkin(get_currentSkin, null):Skin;
	private static function get_currentSkin() {
		if (_currentSkin != null)
			return _currentSkin;

		return useSkin("gfx/ui/greyDefault.png");
	}
	/**
	 * Change the skin to use for future Controls.
	 * @param	source	BitmapData or resource name of the skin.
	 */
	public static function useSkin(source:Dynamic):Skin {
#if flash
		if (Std.is(source, BitmapData)) _currentSkin = source;
		else _currentSkin = HXP.getBitmap(source);
#else
		var atlasSkin:TextureAtlas = TextureAtlas.loadTexturePacker("atlas/assets.xml");
		_currentSkin = atlasSkin.getRegion(source);
#end
		return _currentSkin;
	}
	private static var _currentSkin:Skin;
	
	/**
	 * store the Control under the mouse from the last update.
	 */
	private static var controlUnderMouse:Control = null;
	private static var blankControl:Control = null;

	/** Parent class for every controls. Manage default skin and control composition.
	 * When using a control as child of a container, only use localX and localY to have relative coordinates.
	 * @param x x/localX position of the component
	 * @param y y.localY position of the component
	 * @param width Width of the component
	 * @param height Height of the component
	 */
	public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0) {
		super(x, y);
		this.type = "control";
		_localX = x;
		_localY = y;
		this.width = width;
		this.height = height;
		//_skin = currentSkin;
		_children = new Array<Control>();
		_eventDispatcher = new EventDispatcher();
		layer = defaultLayer;
		_lastWidth = width;
		_lastHeight = height;
		_toAddToWorld = new Array<Control>();
	}

	/**
	 * Method called by the framework when the component is added to the scene.
	 */
	public override function added()
	{
		_lastX = x;
		_lastY = y;

		// add the children to the parent scene (container view)
		for (child in _children) {
			// if the child is from another scene, remove itself from his former scene
			if (child.scene != null && child.scene != this.scene ) {
				child.scene.remove(child);
			}
			// add the child to his container scene
			if (child.scene != this.scene) {
				_toAddToWorld.push(child);
			}
		}

		dispatchEvent(new ControlEvent(this, ADDED_TO_WORLD));
	}

	/**
	 * Method called by framwork when the component is removed from scene
	 */
	override public function removed():Void
	{
		for (child in _children) {
			if (child.scene != null) {
				child.scene.remove(child);
			}
		}
		super.removed();

		dispatchEvent(new ControlEvent(this, REMOVED_FROM_WORLD));
	}

	/**
	 * recursively update children layers
	 * @param	value	new layer position to use for this component
	 * @return
	 */
	override private function set_layer(value:Int):Int
	{
		var lay:Int = super.set_layer(value);
		if (_children != null) {
			for (child in _children) {
				child.layer = lay - 1;
			}
		}
		return lay;
	}

	/**
	 * Number of layers needed to display every level of child in the hierarchy.
	 * Equals to the deeper subchild position.
	 * @return
	 */
	public var depth(get_depth, null):Int;
	private function get_depth():Int
	{
		var maxDepth:Int = 1;
		for (child in _children) {
			maxDepth = Math.floor(Math.max(maxDepth, child.get_depth()+1));
		}
		return maxDepth;
	}

	/**
	 * Number of child and subchilds contained in this Control.
	 * @return
	 */
	public var controlCount(get_controlCount, null):Int;
	private function get_controlCount():Int
	{
		var count:Int = 1;
		for (child in _children) {
			count += child.controlCount;
		}
		return count;
	}

	/**
	 * Called when the Control is added to a container.
	 * Override to catch event.
	 * @param	container
	 */
	public function addedToContainer(container:Control)
	{
		dispatchEvent(new ControlEvent(this, ADDED_TO_CONTAINER));
	}

	/**
	 * Called when the Control is removed from a container.
	 * Override to catch event.
	 * @param	container
	 */
	public function removedFromContainer(container:Control)
	{
		dispatchEvent(new ControlEvent(this, REMOVED_FROM_CONTAINER));
	}

	/**
	 * Update this component position and its children ones.
	 * Keep trace of lastX, lastY, lastWidth and lastHeight. A Resized event is fired on width or height change.
	 */
	override public function update()
	{
		if (x != _lastX) _lastX = x;
		if (y != _lastY) _lastY = y;
		if ((_lastWidth != width) || (_lastHeight != height)) {
			if (_lastWidth != width) _lastWidth = width;
			if (_lastHeight != height) _lastHeight = height;
			dispatchEvent(new ControlEvent(this, RESIZED));
		}

		if (_enabled) {
			// MOUSE_HOVER and MOUSE_OUT for any control
			if (scene != null && isChild(Control.getControlUnderMouse())) {
				if(!_overCalled){
					dispatchEvent(new ControlEvent(this, MOUSE_HOVER));
					_overCalled = true;
					_outCalled = false;
				}
			} else {
				if (!_outCalled) {
					dispatchEvent(new ControlEvent(this, MOUSE_OUT));
					_overCalled = false;
					_outCalled = true;
				}
			}
		}

		// follow camera
		if (stickToCamera) {
			this.x = _localX + HXP.camera.x;
			this.y = _localY + HXP.camera.y;
		}

		super.update();

		// within a container, move using local coordinates
		updateChildPosition();
		// really add new children
		doAddChildren();
	}
	
	
	static function getControlUnderMouse():Control
	{
		if (Control.controlUnderMouse == null) {
			var entity:Entity = HXP.scene.collidePoint("control", Input.mouseX + HXP.camera.x, Input.mouseY + HXP.camera.y);
			if (entity != null && Std.is(entity, Control)) {
				Control.controlUnderMouse = cast(entity, Control);
			} else {
				if (Control.blankControl == null) Control.blankControl = new Control();
				Control.controlUnderMouse = Control.blankControl;
			}
		}
		return Control.controlUnderMouse;
	}
	
	override public function render():Void 
	{
		Control.controlUnderMouse = null;
		super.render();
	}

	private function doAddChildren() {
		//check if new children are to be added
		if (this.scene != null) {
			for (toAdd in _toAddToWorld) {
				// check if it as not been removed in the mean time
				if (contains(toAdd) && toAdd.scene != this.scene) {
					this.scene.add(toAdd);
				}
			}
			_toAddToWorld.splice(0, _toAddToWorld.length);
		}
	}

	/**
	 * Update children position recursively.
	 */
	private function updateChildPosition()
	{
		for (c in _children) {
			c.x = c.absoluteX;
			c.y = c.absoluteY;
			c.updateChildPosition();
		}
	}

	/**
	 * Is the control a children of this control ?
	 * @param	control	The control to test
	 * @return true if the control is a child of this
	 */
	public function contains(control:Control):Bool {
		return Lambda.has(children, control);
	}

	/**
	 * Add another Control as a child.
	 * ONLY use localX and localY to move a child. Coordinates are relative to the container.
	 * @param	child
	 * @param 	position	position of the child in the container's childs collection.
	 */
	public function addControl(child:Control, ?position:Int):Void {
		if (child._container != this) {
			if (!Lambda.has(_children, child)) {
				if (position == null) {
					_children.push(child);
				} else {
					_children.insert(position, child);
				}
			}
			// remove the child properly from the other container if not done
			if (child._container != null && child._container.children != null) {
				child._container.children.remove(child);
				child.removedFromContainer(child._container);
			}
			child._container = this;
			child.addedToContainer(this);

			// if the child is from another scene, remove itself from his former scene
			if (child.scene != null && this.scene != null && child.scene != this.scene ) {
				child.scene.remove(child);
			}
			// add the child to his container scene
			if (!Lambda.has(_toAddToWorld, child)) {
				_toAddToWorld.push(child);
			}
			child.layer = layer - 1;
		}
	}

	/**
	 * remove a children.
	 * @param	c
	 */
	public function removeControl(child:Control):Void {
		if (_children.remove(child)) {
			child._container = null;
			child.removedFromContainer(this);

			if (child.scene != null) {
				child.scene.remove(child);
			}
			_toAddToWorld.remove(child);
		}
	}
	
	public function removeAllControls():Void {
		var childs = children.copy();
		for (c in childs) {
			removeControl(c);
		}
	}

	/**
	 * Hide this control and its children
	 * @param	?e
	 */
	public function hide(?e:Event):Void
	{
		this.visible = false;
		this.active = false;
		this.type = "inactivecontrol";
		for (c in _children) {
			c.hide();
		}
		dispatchEvent(new ControlEvent(this, HIDDEN));
	}

	/**
	 * Show this control and its children
	 * @param	?e
	 */
	public function show(?e:Event):Void
	{
		this.visible = true;
		this.active = true;
		this.type = "control";
		for (c in _children) {
			c.show();
		}
		dispatchEvent(new ControlEvent(this, SHOWN));
	}

	/**
	 * X position relative to his container. Use this instead of "x" attribute !
	 */
	public var localX(get_localX, set_localX):Float;
	private function get_localX():Float
	{
		return (_container == null) ? x : _localX;
	}
	private function set_localX(value:Float):Float
	{
		_localX = value;
		if (_container == null) this.x = _localX + (stickToCamera?HXP.camera.x:0);
		return _localX = value;
	}

	/**
	 * Y position relative to his container. Use this instead of "y" attribute !
	 */
	public var localY(get_localY, set_localY):Float;
	private function get_localY():Float
	{
		return (_container == null) ? y : _localY;
	}
	private function set_localY(value:Float):Float
	{
		_localY = value;
		if (_container == null) this.y = _localY + (stickToCamera?HXP.camera.y:0);
		return value;
	}

	/**
	 * X position on the scene
	 */
	public var absoluteX(get_absoluteX, null):Float;
	private function get_absoluteX():Float
	{
		return (_container == null) ? x : _container.absoluteX + this.localX;
	}

	/**
	 * Y position on the scene
	 */
	public var absoluteY(get_absoluteY, null):Float;
	private function get_absoluteY():Float
	{
		return (_container == null) ? y : _container.absoluteY + this.localY;
	}

	/**
	 * Control container.
	 */
	public var container(get_container, null):Control;
	private function get_container():Control
	{
		return _container;
	}

	private function get_children():Array<Control>
	{
		return _children;
	}
	private function set_children(value:Array<Control>):Array<Control>
	{
		return _children = value;
	}
	/**
	 * List of all the children of this component
	 */
	public var children(get_children, set_children):Array<Control>;

	/**
	 * Recursively check if the control is the component itself or a child.
	 * @param	control
	 * @return
	 */
	public function isChild(control:Control):Bool {
		if (control == this) {
			return true;
		}
		for (c in children) {
			if (c.isChild(control)) {
				return true;
			}
		}
		return false;
	}

	private function get_enabled():Bool
	{
		return _enabled;
	}
	private function set_enabled(value:Bool):Bool
	{
		//active = value;
		return _enabled = value;
	}
	/**
	 * Component state. A disabled component don't react to user interaction and have a specific visual.
	 * It can still be programmatically updated and moved.
	 */
	public var enabled(get_enabled, set_enabled):Bool;

	private function get_stickToCamera():Bool
	{
		return _stickToCamera;
	}
	private function set_stickToCamera(value:Bool):Bool
	{
		_stickToCamera = value;
		if (_stickToCamera) {
			localX = _localX;
			localY = _localY;
		}
		return _stickToCamera;
	}
	/**
	 * Must the component automatically follow the camera ?
	 * Set to TRUE, localX and localY should give the position ON THE SCREEN.
	 * Set to FALSE, localX and localY should give the position ON TE WORLD.
	 * In a hierarchy, this attribute is ignored for childs. Only the top parent element must set followCamera to "true".
	 * Default value is false.
	 */
	public var stickToCamera(get_stickToCamera, set_stickToCamera):Bool;


	/* INTERFACE flash.events.IEventDispatcher */
	public function addEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void
	{
		_eventDispatcher.addEventListener(type, listener, useCapture, priority,useWeakReference);
	}

	public function dispatchEvent(event:Event):Bool
	{
		if (_eventDispatcher != null) {
			return _eventDispatcher.dispatchEvent(event);
		} else {
			return false;
		}
	}

	public function hasEventListener(type:String):Bool
	{
		return _eventDispatcher.hasEventListener(type);
	}

	public function removeEventListener(type:String, listener:Dynamic -> Void, useCapture:Bool = false):Void
	{
		_eventDispatcher.removeEventListener(type, listener, useCapture);
	}

	public function willTrigger(type:String):Bool
	{
		return _eventDispatcher.willTrigger(type);
	}


	private var _lastX:Float;
	private var _lastY:Float;
	private var _lastWidth:Float;
	private var _lastHeight:Float;
	private var _skin:Skin;
	private var _localX:Float = 0;
	private var _localY:Float = 0;
	private var _container:Control = null;
	private var _children:Array<Control>;
	private var _eventDispatcher:EventDispatcher;
	private var _enabled:Bool;
	private var _toAddToWorld:Array<Control>;
	private var _overCalled:Bool = false;
	private var _outCalled:Bool = true;
	private var _stickToCamera:Bool = false;
}