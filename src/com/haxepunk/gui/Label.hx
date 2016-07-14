package com.haxepunk.gui;

import com.haxepunk.graphics.Stamp;
import com.haxepunk.HXP;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxe.ds.StringMap;

typedef TextOptions = {
	@:optional var font:String;
	@:optional var size:Int;
	@:optional var align:TextFormatAlign;
	@:optional var valign:VerticalAlign;
	@:optional var wordWrap:Bool;
	@:optional var resizable:Bool;
	@:optional var color:Int;
	@:optional var leading:Int;
	@:optional var richText:Bool;
};

/**
 * @author PigMess
 * @author Rolpege
 * @author Lythom
 */
class Label extends Control
{
	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "shown";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";
	static public inline var RESIZED:String = "resized";


	/**
	 * Label default font (must be a flash.text.Font object).
	 * Label defaults parameters affect every components that uses labels, i.e. : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window.
	 * Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
	 */
	public static var defaultFont(get, set):Font;
	private static function get_defaultFont():Font {
		if (_defaultFont == null) {
			//_defaultFont = openfl.Assets.getFont("font/04B_03__.ttf");
			_defaultFont = openfl.Assets.getFont("font/pf_ronda_seven.ttf");
		}
		return _defaultFont;
	}
	private static function set_defaultFont(font:Font):Font {
		return _defaultFont = font;
	}
	private static var _defaultFont:Font = null;
	
	/**
	 * Label default Size.
	 * Label defaults parameters affect every components that uses labels, i.e. : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window.
	 * Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
	 */
	public static var defaultSize:Int = 8;
	/**
	 * Label defaultColor. Tip inFlashDevelop : use ctrl + shift + k to pick a color.
	 * Label defaults parameters affect every components that uses labels, i.e. : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window.
	 * Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
	 */
	public static var defaultColor:Int = 0x333333;
	
	public static function textFormatFromTextOptions(object:TextOptions):TextFormat
	{
		var format = new TextFormat();
		for (key in Reflect.fields(object))
		{
			if (Reflect.hasField(format, key))
			{
				Reflect.setField(format, key, Reflect.field(object, key));
			}
			else
			{
				throw '"' + key + '" is not a TextFormat property';
			}
		}
		return format;
	}

	/**
	 * Create a text Label printed on a transparent background.
	 * @param	text
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	?align
	 */
	public function new(text:String = "", x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, ?align:FormatAlign, ?valign:VerticalAlign)
	{
		_styles = new StringMap<TextFormat>();
		
		_format = new TextFormat(Label.defaultFont.fontName, Label.defaultSize);
		//_format.bold = true;
		_textField = new TextField();
		_textField.text = text;
		_text = text;
		_textField.defaultTextFormat = _format;
		_textField.selectable = false;
		_textField.embedFonts = true;
		_textField.maxChars = 0;
		_textField.wordWrap = false;
		_textField.multiline = false;
		_textField.setTextFormat(_format);
		_textField.autoSize = TextFieldAutoSize.LEFT;

		_valign = (valign == null)? VerticalAlign.TOP : valign;

		// auto set width
		if (width == 0) {
			_autoWidth = true;
			width = Std.int(_textField.textWidth + 4);
		}
		// auto set height
		if (height == 0) {
			_autoHeight = true;
			height = Std.int(_textField.textHeight + 4);
		}

		_renderRect = new Rectangle(0, 0, width, height);
		_textBuffer = HXP.createBitmap(width, height, true);
		graphic = new Stamp(_textBuffer);

		super(x, y, width, height);
		this.color = Label.defaultColor;
		this.align = align;
	}

	override public function added()
	{
		super.added();
		updateBuffer();
	}

	override public function render()
	{
		if (toBeRedraw) {
			_textBuffer.fillRect(_renderRect, HXP.blackColor);
			var m:Matrix = new Matrix();
			m.tx = _bitmapBufferMargin;
			m.ty = _bitmapBufferMargin;
			_textBuffer.draw(_textField,m);
			toBeRedraw = false;
		}
		super.render();
	}

	/**
	 * Call this if width or height is changed manually to update the graphic.
	 */
	public function updateBuffer() {

		// Label has been changed, we need to update its display by drawing it
		toBeRedraw = true;

		// apply new TextFormat to the textField
		if (multiline) {
			_format.align = align;
		}
		if (useXmlFormat) {
			matchStyles();
		} else if(!useCustomFormat) {
			_textField.setTextFormat(_format);
			if(!multiline){
				_textField.autoSize = TextFieldAutoSize.LEFT;
			}
		}
		
		resizeAndAlign();
	}
	
	function resizeAndAlign():Void 
	{
		// flag to know if we need to resize Label's buffer.
		var doResize:Bool = multiline;
	
		// auto resize width
		if (_autoWidth && width != Std.int(_textField.textWidth + 4)) {
			width = Std.int(_textField.textWidth + 4);
			_textField.width = width;
			_renderRect.width = width;
			doResize = true;
		}
	
		// auto resize height
		if (_autoHeight && height != Std.int(_textField.textHeight + 4)) {
			height = Std.int(_textField.textHeight + 4);
			_textField.height = height;
			_renderRect.height = height;
			doResize = true;
		}
	
		if (doResize) {
			resize();
		}
		// alignment
		if (!multiline) {
			if (align == TextFormatAlign.CENTER) {
				_alignOffset = Math.round((width - _textField.width)/2);
			} else if (align == TextFormatAlign.RIGHT) {
				_alignOffset = Math.round(width - _textField.width);
			} else {
				_alignOffset = 0;
			}
		}
		graphic.x = Math.round(_alignOffset) - _bitmapBufferMargin;
		if ( _valign == VerticalAlign.TOP )
			graphic.y = _bitmapBufferMargin;
		else if ( _valign == VerticalAlign.CENTER )
			graphic.y = Math.round((height - _textField.height) / 2) - _bitmapBufferMargin;
		else if ( _valign == VerticalAlign.BOTTOM )
			graphic.y = Math.round(height - _textField.height) - _bitmapBufferMargin;
	}
	
	public function resize()
	{
		_textBuffer = HXP.createBitmap(width + _bitmapBufferMargin * 2, height + _bitmapBufferMargin * 2, true);
		graphic = new Stamp(_textBuffer);
	}
	
	/**
	 * Add a style for a subset of the text, for use with the text property.
	 * Usage:
	 *    text.setStyle("red", new TextFormat(null, null, 0xFF0000));
	 *    text.setStyle("big", new TextFormat(null, textfield.size*2, 0xFF0000, true));
	 *    text.useXmlFormat = true;
	 *    text.text = "<big>Hello</big> <red>world</red>";
	 */
	public function addStyle(tagName:String, params:TextFormat):Void
	{
		_styles.set(tagName, params);
	}
	
	/**
	 * Add a style for any wml formatted label, for use with the text property.
	 * Usage:
	 *    Label.setGlobalStyle("red", new TextFormat(null, null, 0xFF0000));
	 *    Label.setGlobalStyle("big", new TextFormat(null, textfield.size*2, 0xFF0000, true));
	 *    text.useXmlFormat = true;
	 *    text.text = "<big>Hello</big> <red>world</red>";
	 */
	static private var _globalStyles:StringMap<TextFormat>;
	public static function addGlobalSyle(tagName:String, params:TextFormat):Void {
		if (_globalStyles == null) {
			_globalStyles = new StringMap<TextFormat>();
		}
		_globalStyles.set(tagName, params);
	}
	public static function hasGlobalSyle(tagName:String):Bool {
		return _globalStyles != null && _globalStyles.exists(tagName);
	}
	
	private static var tag_re = ~/<([^>]+)>([^(?:<\/)]+)<\/[^>]+>/g;
	
	private function matchStyles()
	{
		// strip the tags for the display field
		var _tagText:String = _text;
		_textField.text = tag_re.replace(_tagText, "$2");

		// set the text formats based on tag names
		_textField.setTextFormat(_format);
		while (tag_re.match(_tagText))
		{
			var tagName = tag_re.matched(1);
			var text = tag_re.matched(2);
			var p = tag_re.matchedPos();
			_tagText = _tagText.substr(0, p.pos) + text + _tagText.substr(p.pos + p.len);
			// try to find a tag name
			var style:TextFormat = _styles.exists(tagName) ? _styles.get(tagName) :  (_globalStyles.exists(tagName) ? _globalStyles.get(tagName) : null );
			if (style != null)
			{
				_textField.setTextFormat(style, p.pos, p.pos + text.length);
			}
#if debug
			else
			{
				HXP.log("Could not found text style '" + tagName + "'");
			}
#end
		}
	}

	/**
	 * update or get the text.
	 */
	public var text(get_text, set_text):String;
	private function get_text():String { return _text; }
	private function set_text(value:String):String {
		_textField.text = value;
		_text = value;
		updateBuffer();
		return value;
	}
	
	/**
	 * Format using flash textfield html text capabilities.
	 * May fail on native targets ! See @useXmlFormat for fully compatible text formatting.
	 */
	public var htmlText(get_htmlText, set_htmlText):String;
	private function get_htmlText():String { return _textField.htmlText; }
	private function set_htmlText(value:String):String {
		_textField.htmlText = value;
		updateBuffer();
		return value;
	}

	/**
	 * update or get the text color.
	 */
	public var color(get_color, set_color):Int;
	private function get_color():Int { return _format.color; }
	private function set_color(value:Int):Int {
		_normalColor = value;
		_format.color = value;
		updateBuffer();
		return value;
	}

	/**
	 * get text length.
	 */
	public var length(get_length, never):Int;
	private function get_length():Int { return _textField.text.length; }

	/**
	 * update or get text size.
	 */
	public var size(get_size, set_size):Dynamic;
	private function get_size():Dynamic { return _format.size; }
	private function set_size(value:Dynamic):Dynamic {
		_format.size = value;
		updateBuffer();
		return value;
	}

	/**
	 * update or get font
	 */
	public var font(get_font, set_font):String;
	private function get_font():String { return _format.font; }
	private function set_font(value:String):String {
		_format.font = value;
		updateBuffer();
		return value;
	}

	/**
	 * update or get text alignement.
	 * No effect if autoWidth is true.
	 */
	public var align(default, set_align):FormatAlign;
	private function set_align(value:FormatAlign):FormatAlign {
		if (align == value) return value;
		align = value;
		updateBuffer();
		return value;
	}
	
	public var alpha(get_alpha, set_alpha):Float;
	private function get_alpha():Float {
		return _textField.alpha;
	}
	private function set_alpha(value:Float):Float {
		_textField.alpha = value;
		updateBuffer();
		return value;
	}

	/**
	 * Automatically resize Label height.
	 */
	public var autoHeight(get_autoHeight, set_autoHeight):Bool;
	private function get_autoHeight():Bool
	{
		return _autoHeight;
	}
	private function set_autoHeight(value:Bool):Bool
	{
		_autoHeight = value;
		return _autoHeight;
	}

	/**
	 * Automatically resize Label width.
	 */
	public var autoWidth(get_autoWidth, set_autoWidth):Bool;
	private function get_autoWidth():Bool
	{
		return _autoWidth;
	}
	private function set_autoWidth(value:Bool):Bool
	{
		_autoWidth = value;
		return _autoWidth;
	}

	private function get_disabledColor():Int
	{
		return _disabledColor;
	}
	private function set_disabledColor(value:Int):Int
	{
		return _disabledColor = value;
	}
	/**
	 * Text color to use when disabled.
	 * Mostly used when Label is used as child of another component.
	 */
	public var disabledColor(get_disabledColor, set_disabledColor):Int;
	
	/**
	 * Set the text to autowrap and be automatically multine.
	 * AutoWidth and AutoHeight will be desactivated when using multine
	 */
	public var multiline(get_multiline, set_multiline):Bool;
	function get_multiline():Bool 
	{
		return _multiline;
	}
	function set_multiline(value:Bool):Bool 
	{
		_textField.multiline = value;
		_textField.wordWrap = value;
		if (value) {
			if (_autoWidth) _autoWidth = false;
			if (_autoHeight) _autoHeight = false;
			_textField.width = width;
			_textField.height = height;
		}
		updateBuffer();

		return _multiline = value;
	}

	public var valign(get_valign, set_valign):VerticalAlign;
	function get_valign():VerticalAlign
	{
		return _valign;
	}
	function set_valign(value:VerticalAlign):VerticalAlign
	{
		_valign = value;
		updateBuffer();

		return _valign;
	}
	
	function get_textField():TextField 
	{
		return _textField;
	}
	function set_textField(value:TextField):TextField 
	{
		return _textField = value;
	}
	/**
	 * Access to the textField to be drawn to the bitmapBuffer
	 */
	public var textField(get_textField, set_textField):TextField;
	
	function get_bitmapBufferMargin():Int 
	{
		return _bitmapBufferMargin;
	}
	function set_bitmapBufferMargin(value:Int):Int 
	{
		_bitmapBufferMargin = value;
		toBeResized = true;
		return _bitmapBufferMargin;
	}
	/**
	 * Add a border margin to the output buffer to allow effects like glowing
	 */
	public var bitmapBufferMargin(get_bitmapBufferMargin, set_bitmapBufferMargin):Int;
	
	function get_textBuffer():BitmapData 
	{
		return _textBuffer;
	}
	
	public var textBuffer(get_textBuffer, null):BitmapData;
	
	/**
	 * Format using defined styles (see @addStyle) and xml tags.
	 * The text with tags are read from the "text" field.
	 * To get the text without tags, use textfield.text.
	 */
	public var useXmlFormat(get_useXmlFormat, set_useXmlFormat):Bool;
	function get_useXmlFormat():Bool 
	{
		return _useXmlFormat;
	}
	function set_useXmlFormat(value:Bool):Bool 
	{
		if (value) _useCustomFormat = false;
		_useXmlFormat = value;
		updateBuffer();
		return _useXmlFormat;
	}
	
	/**
	 * No text formatting is applied.
	 * You can freely use your external setTextFormat and it won't alterned by the Label if useCustomFormat is set to true.
	 * Must be set to true to take advandage of htmlText features.
	 */
	public var useCustomFormat(get_useCustomFormat, set_useCustomFormat):Bool;
	
	function get_useCustomFormat():Bool 
	{
		return _useCustomFormat;
	}
	function set_useCustomFormat(value:Bool):Bool 
	{
		if (value) _useXmlFormat = false;
		_useCustomFormat = value;
		updateBuffer();
		return _useCustomFormat;
	}


	override private function set_enabled(value:Bool):Bool
	{
		if (value) {
			_format.color = _normalColor;
		} else {
			_format.color = _disabledColor;
		}
		updateBuffer();
		return super.set_enabled(value);
	}

	override public function toString():String
	{
		return this._class + "=" + this.text;
	}

	private var _textField:TextField;
	private var _renderRect:Rectangle;
	private var _textBuffer:BitmapData;
	private var _format:TextFormat;
	private var _autoHeight:Bool = false;
	private var _autoWidth:Bool = false;
	private var _disabledColor:Int = 0x666666;
	private var _normalColor:Int;
	private var toBeRedraw:Bool = true;
	private var _alignOffset:Int = 0;
	private var _bitmapBufferMargin:Int = 0;
	private var _multiline:Bool = false;
	private var toBeResized:Bool = false;
	private var _useXmlFormat:Bool = false;
	private var _useCustomFormat:Bool = false;
	private var _styles:StringMap<TextFormat>;
	private var _valign:VerticalAlign;
	var _text:String;
}

enum VerticalAlign
{
	TOP;
	CENTER;
	BOTTOM;
}