package ru.stablex.ui.widgets;

import com.haxepunk.utils.Input;
import openfl.display.DisplayObject;
import openfl.events.TouchEvent;
import ru.stablex.ui.skins.Skin;
import ru.stablex.ui.UIBuilder;
import openfl.events.MouseEvent;


/**
* Simple button
*/
class Button extends Text{

    //whether button is currently pressed
    public var pressed (default,null) : Bool = false;
    //Wether mouse pointer is currently over this button
    public var hovered (default,null) : Bool = false;
    //whether button is currently disabled
    public var disabled (default,set_disabled) : Bool = false;
    /** this.mouseChildren value before this.disabled was set to true */
    private var _mouseChildrenBeforeDisabled : Bool = false;
    //default icon for button
    public var ico (get_ico,set_ico): Bmp;
    private var _ico : Bmp;
    //icon for hovered state
    public var icoHovered (get_icoHovered,set_icoHovered) : Bmp;
    private var _icoHovered : Bmp;
    //icon for pressed state
    public var icoPressed (get_icoPressed,set_icoPressed) : Bmp;
    private var _icoPressed : Bmp;
    //icon for disabled state
    public var icoDisabled (get_icoDisabled,set_icoDisabled) : Bmp;
    private var _icoDisabled : Bmp;
    /**
    * Whether icon should appear before text (on left or on top of text), set to false to move icon to the right (or below) text
    * If you want icon to appear on top of label (or below) you also need to set button.vertical = true.
    */
    public var icoBeforeLabel (default,set_icoBeforeLabel) : Bool = true;
    //skin name for hovered state (skin must be registered with <type>UIBuilder</type>.regSkins() )
    public var skinHoveredName (default,set_skinHoveredName) : String;
    //skin for hovered state
    public var skinHovered : Skin;
    //skin name for pressed state (skin must be registered with <type>UIBuilder</type>.regSkins() )
    public var skinPressedName (default,set_skinPressedName) : String;
    //skin for pressed state
    public var skinPressed : Skin;
    //skin name for disabled state (skin must be registered with <type>UIBuilder</type>.regSkins() )
    public var skinDisabledName (default,set_skinDisabledName) : String;
    //skin for disabled state
    public var skinDisabled : Skin;
    //stick ico and text to opposite borders
    public var apart : Bool = false;
	//触摸ID
	public var touchId:Int = -1;
	

    /**
    * We use wrappers so if we assign another functions to instance methods like .onPress, we don't need to reaply eventListeners
    * {
    */
        /**
        * wrapper for hover
        *
        */
        static private function _onHover (e:MouseEvent) : Void {
            var btn : Button = cast(e.currentTarget, Button);
            if (btn.disabled) {
                return;
            }

            //if button is already hovered, do nothing
            if( btn.hovered ) return;

            //switch icon
            btn._switchIco(btn._icoHovered);

            //switch skin
            btn._switchSkin(btn.skinHovered);

            btn.hovered = true;
            btn.onHover(e);
        }//function _onHover()


        /**
        * wrapper for hout
        *
        */
        static private function _onHout (e:MouseEvent) : Void {
            var btn : Button = cast(e.currentTarget, Button);
			btn.touchId = -1;
            if (btn.disabled) {
                return;
            }

            //if button is not hovered, do nothing
            if( !btn.hovered ) return;

            //switch icon
            btn._switchIco(btn._ico);

            //switch skin
            btn._switchSkin(btn.skin);

            btn.hovered = false;
            btn.onHout(e);
        }//function _onHout()


        /**
        * wrapper for press
        *
        */
        static private function _onPress (e:#if mobile TouchEvent #else MouseEvent #end) : Void {
            var btn : Button = cast(e.currentTarget, Button);
            if (btn.disabled) {
                return;
            }

            //if button is already pressed, do nothing
            if( btn.pressed ) return;

            //switch icon
            btn._switchIco(btn._icoPressed);

            //switch skin
            btn._switchSkin(btn.skinPressed);

            btn.pressed = true;
            btn.onPress(cast e);
        }//function _onPress()


        /**
        * wrapper for release
        *
        */
        static private function _onRelease (e:MouseEvent) : Void {
			
            var btn : Button = cast(e.currentTarget, Button);
			btn.removeOrder();
			btn.touchId = -1;
            if (btn.disabled) {
                return;
            }

            //if button is not pressed, do nothing
            if( !btn.pressed ) return;

            //switch icon
            if( btn.hovered ){
                btn._switchIco(btn._icoHovered);
            }else{
                btn._switchIco(btn._ico);
            }

            //switch skin
            if( btn.hovered ){
                btn._switchSkin(btn.skinHovered);
            }else{
                btn._switchSkin(btn.skin);
            }

            btn.pressed = false;
            btn.onRelease(e);
        }//function _onRelease()
    /*
    * } wrappers
    **/
	
		
	static private function _onTouchBegin(e:TouchEvent):Void 
	{
		//trace(Input.touchOrder+">>"+e.touchPointID);
		if (Lambda.has(Input.touchOrder, e.touchPointID))
			return;
		Input.touchOrder.push(e.touchPointID);
		var btn : Button = cast(e.currentTarget, Button);
		if (btn.touchId == -1) btn.touchId = e.touchPointID;
		if (btn.touchId != e.touchPointID) return;
		
		//if (Input.touches.exists(btn.touchId))
			//return;
		if (btn.disabled) {
			return;
		}
		if ( btn.pressed ) return;
		btn._switchIco(btn._icoPressed);
		btn._switchSkin(btn.skinPressed);
		btn.pressed = true;
		//var event = new MouseEvent(MouseEvent.MOUSE_DOWN, e.bubbles, e.cancelable, e.localX, e.localY, e.relatedObject);
		btn.onPress(cast e);
	}
	
	override public function free(recursive:Bool = true):Void 
	{
		removeOrder();
		super.free(recursive);
	}
	private function removeOrder()
	{
		if(touchId!=-1)
			Input.touchOrder.remove(touchId);
	}
    /**
    * Constructor
    * By default `.padding` = 2, `.childPadding` = 5 and `.mouseChildren` = false
    */
    public function new () : Void{
        super();

        this.vertical = false;

        this.padding          = 2;
        this.childPadding     = 5;
        this.label.selectable = false;

        this.buttonMode    = this.useHandCursor = true;
        this.mouseChildren = false;

        //process interactions with mouse pointer
        
        #if mobile
            this.addEventListener(TouchEvent.TOUCH_ROLL_OUT, Button._onHout);
            this.addEventListener(TouchEvent.TOUCH_OUT, Button._onRelease);
			this.addEventListener(TouchEvent.TOUCH_BEGIN, Button._onTouchBegin);
			this.addEventListener(TouchEvent.TOUCH_END, Button._onRelease);
		#else
		this.addEventListener(MouseEvent.MOUSE_OVER, Button._onHover);
		this.addEventListener(MouseEvent.MOUSE_OUT, Button._onHout);
		this.addEventListener(MouseEvent.MOUSE_DOWN, Button._onPress);
		this.addEventListener(MouseEvent.MOUSE_OUT, Button._onRelease);
		this.addEventListener(MouseEvent.MOUSE_UP, Button._onRelease);
		#end
		

        this.pressed  = false;
        this.hovered  = false;
        this.disabled = false;

        this.align = "center,middle";
    }//function new()


    /**
    * Process pressing. By defualt moves widget by 1px down
    *
    */
	
	#if mobile
    public dynamic function onPress (e:TouchEvent) : Void {
	#else 
    public dynamic function onPress (e:MouseEvent) : Void {
	#end
        // var btn : Button = cast(e.currentTarget, Button);

        // btn.y ++;
    }//function onPress()


    /**
    * Process releasing. By defualt moves widget by 1px up
    *
    */
    public dynamic function onRelease (e) : Void {
        // var btn : Button = cast(e.currentTarget, Button);

        // btn.y --;
    }//function onRelease()


    /**
    * Process hover. By default does nothing
    *
    */
    public dynamic function onHover (e) : Void {

    }//function ononHover()


    /**
    * Process hout. By default does nothing
    *
    */
    public dynamic function onHout (e) : Void {

    }//function onHout()


    /**
    * Setter for `.disabled`
    *
    */
    @:noCompletion private function set_disabled(disabled:Bool) : Bool {
        if (disabled) {   //switch icon
            if (!this.disabled) {
                this._mouseChildrenBeforeDisabled = this.mouseChildren;
            }
            this.mouseEnabled = false;
            this._switchIco(this._icoDisabled);
            this._switchSkin(this.skinDisabled);
        } else {
            if (this.disabled) {
                this.mouseChildren = this._mouseChildrenBeforeDisabled;
            }
            this.mouseEnabled = true;
            this._switchIco(this._ico);
            this._switchSkin(this.skin);
        }

        return this.disabled = disabled;
    }//function set_disabled()


    /**
    * Setter for `.icoBeforeLabel`
    *
    */
    @:noCompletion private function set_icoBeforeLabel(ibl:Bool) : Bool {
        if( ibl ){
            this.setChildIndex(this.label, this.numChildren - 1);
        }else{
            this.setChildIndex(this.label, 0);
        }

        return this.icoBeforeLabel = ibl;
    }//function set_icoBeforeLabel()


    /**
    * Getter for ico
    *
    */
    @:noCompletion private function get_ico () : Bmp {
        //if ico is still not created, create it
        if( this._ico == null ){
            this._ico = UIBuilder.create(Bmp);
            this._addIco(this._ico);
        }

        return this._ico;
    }//function get_ico()


    /**
    * Setter for ico
    *
    */
    @:noCompletion private function set_ico (ico:Bmp) : Bmp {
        //destroy old ico
        if( this._ico != null ){
            this._ico.free();
        }
        //add new ico
        if( ico != null ){
            this._addIco(ico);
        }

        return this._ico = ico;
    }//function set_ico()


    /**
    * Getter for icoHovered
    *
    */
    @:noCompletion private function get_icoHovered () : Bmp {
        //if ico is still not created, create it
        if( this._icoHovered == null ){
            this._icoHovered = UIBuilder.create(Bmp);
            this._icoHovered.visible = false;
            this._addIco(this._icoHovered);
        }

        return this._icoHovered;
    }//function get_icoHovered()


    /**
    * Setter for icoHovered
    *
    */
    @:noCompletion private function set_icoHovered (ico:Bmp) : Bmp {
        //destroy old ico
        if( this._icoHovered != null ){
            this._icoHovered.free();
        }
        //add new ico
        if( ico != null ){
            this._addIco(ico);
        }

        return this._icoHovered = ico;
    }//function set_icoHovered()


    /**
    * Getter for icoPressed
    *
    */
    @:noCompletion private function get_icoPressed () : Bmp {
        //if ico is still not created, create it
        if( this._icoPressed == null ){
            this._icoPressed = UIBuilder.create(Bmp);
            this._icoPressed.visible = false;
            this._addIco(this._icoPressed);
        }

        return this._icoPressed;
    }//function get_icoPressed()


    /**
    * Setter for icoPressed
    *
    */
    @:noCompletion private function set_icoPressed (ico:Bmp) : Bmp {
        //destroy old ico
        if( this._icoPressed != null ){
            this._icoPressed.free();
        }
        //add new ico
        if( ico != null ){
            this._addIco(ico);
        }

        return this._icoPressed = ico;
    }//function set_icoPressed()


    /**
    * Getter for icoDisabled
    *
    */
    @:noCompletion private function get_icoDisabled () : Bmp {
        //if ico is still not created, create it
        if( this._icoDisabled == null ){
            this._icoDisabled = UIBuilder.create(Bmp);
            this._icoDisabled.visible = false;
            this._addIco(this._icoDisabled);
        }

        return this._icoDisabled;
    }//function get_icoDisabled()


    /**
    * Setter for icoDisabled
    *
    */
    @:noCompletion private function set_icoDisabled (ico:Bmp) : Bmp {
        //destroy old ico
        if( this._icoDisabled != null ){
            this._icoDisabled.free();
        }
        //add new ico
        if( ico != null ){
            this._addIco(ico);
        }
        return this._icoDisabled = ico;
    }//function set_icoDisabled()


    /**
    * Setter for skinHoveredName
    *
    */
    @:noCompletion private function set_skinHoveredName (s:String) : String {
        this.skinHovered = UIBuilder.skin(s)();
        return this.skinHoveredName = s;
    }//function set_skinHoveredName()


    /**
    * Setter for skinPressedName
    *
    */
    @:noCompletion private function set_skinPressedName (s:String) : String {
        this.skinPressed = UIBuilder.skin(s)();
        return this.skinPressedName = s;
    }//function set_skinPressedName()

    /**
    * Setter for skinDisabledName
    *
    */
    @:noCompletion private function set_skinDisabledName (s:String) : String {
        this.skinDisabled = UIBuilder.skin(s)();
        return this.skinDisabledName = s;
    }//function set_skinDisabledName()

    /**
    * Adds icon object to the button's display list according to `icoBeforeLabel` property
    *
    */
    private inline function _addIco (ico:Bmp) : Void {
        if( this.icoBeforeLabel ){
            this.addChildAt(ico, 0);
        }else{
            this.addChild(ico);
        }
    }//function _addIco()


    /**
    * Switches visibility of icons
    *
    */
    private inline function _switchIco (ico:Bmp) : Void {
        if( this._ico         != null ) this._ico.visible = false;
        if( this._icoHovered  != null ) this._icoHovered.visible = false;
        if( this._icoPressed  != null ) this._icoPressed.visible = false;
        if( this._icoDisabled != null ) this._icoDisabled.visible = false;

        if( ico != null ){
            ico.visible = true;
        }else if( this._ico != null ){
            this._ico.visible = true;
        }

        this.alignElements();
    }//function _switchIco()


    /**
    * Apply provided skin to this button
    *
    */
    private inline function _switchSkin (skin:Skin) : Void {
        if( /* this._appliedSkin != skin && */ skin != null ){
            skin.apply(this);
        }else if( skin == null && this.skin != null ){
            this.skin.apply(this);
        }
    }//function _switchSkin()


    /**
    * Refresh widget. Also refreshes icons
    *
    */
    override public function refresh () : Void {
        if( this._ico         != null ) this._ico.refresh();
        if( this._icoHovered  != null ) this._icoHovered.refresh();
        if( this._icoPressed  != null ) this._icoPressed.refresh();
        if( this._icoDisabled != null ) this._icoDisabled.refresh();

        super.refresh();
    }//function refresh()

    /**
    * Apply skin defined by `.skin*` properties
    *
    */
    override public function applySkin () : Void {
        if( this.initialized){
            if (this.disabled) {
                this._switchSkin(this.skinDisabled);
                return;
            }
            if (this.pressed) {
                this._switchSkin(this.skinPressed);
                return;
            }
            if (this.hovered) {
                this._switchSkin(this.skinHovered);
                return;
            }
            // Default, super function
            super.applySkin();
        }
    }//function applySkin()


    /**
    * Align elements according to this.align
    *
    */
    override public function alignElements () : Void {
        super.alignElements();

        if( this.apart ){
            this._moveApart();
        }
    }//function alignElements()


    /**
    * Move ico and label to opposite borders
    *
    */
    private inline function _moveApart () : Void {
        var child : DisplayObject;

        //ico to the left border, label to the right border
        if( this.icoBeforeLabel ){
            //there can be several icons for different states
            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                //if this is Bmp, consider it icon
                if( Std.is(child, Bmp) ){
                    cast(child, Bmp).left = this.paddingLeft;
                }
            }

            this._setObjX(this.label, this._width -  this.paddingRight - this._objWidth(this.label));

        //ico to the right border, label to the left border
        }else{
            //there can be several icons for different states
            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                //if this is Bmp, consider it icon
                if( Std.is(child, Bmp) ){
                    cast(child, Bmp).right = this.paddingRight;
                }
            }

            this._setObjX(this.label, this.paddingLeft);
        }
    }//function _moveApart()

}//class Button