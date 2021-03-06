package ru.stablex.ui.widgets;

import bitmapFont.BitmapFont;
import bitmapFont.BitmapTextField;
import flash.display.BitmapData;
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import pgr.dconsole.DC;


/**
* Text field
*/
class BmpText extends Box{
    //<type>flash.display.TextField</type> used to render text
    public var label  : BitmapTextField;
    //Text format wich will be aplied to label on refresh
    public var format : TextFormat;
    //Text format for higlight mode
    public var highlightFormat (get_highlightFormat,set_highlightFormat) : TextFormat;
    private var _hightlightFormat : TextFormat;
    //indicates highlighting state
    public var highlighted (default,null) : Bool = false;
    //Getter-setter for text.
    public var text (get_text, set_text) : String;
	public var autoWordWrap(get_autoWordWrap, set_autoWordWrap):Bool;
	
	public var size(get, set):Float;

    /**
    * Constructor
    *
    */
    public function new() : Void {
        super();
		var fontXML:Xml = Xml.parse(Assets.getText("font/artFont_0.fnt"));
		var fontImage:BitmapData = Assets.getBitmapData("font/artFont_0.png");
		var angelCodeFont:BitmapFont = BitmapFont.fromAngelCode(fontImage, fontXML);
        this.label = new BitmapTextField(angelCodeFont);
        this.label.autoSize   = true;
        this.label.multiLine  = true;
		addChild(label);

        //this.format = this.label.defaultTextFormat;
        this.align    = 'top,left';
    }//function new()


    /**
    * Getter for `.highlightFormat`.
    * Since highlighting is rare required, avoid creating object for it, until
    * it is requested
    */
    @:noCompletion private function get_highlightFormat () : TextFormat {
        if( this._hightlightFormat == null ){
            //clone current format
            /*this._hightlightFormat = new TextFormat(
                this.format.font,
                this.format.size,
                this.format.color,
                this.format.bold,
                this.format.italic,
                this.format.underline,
                this.format.url,
                this.format.target,
                this.format.align,
                #if html5
                    Std.int(this.format.leftMargin),
                    Std.int(this.format.rightMargin),
                    Std.int(this.format.indent),
                    Std.int(this.format.leading)
                #else
                    this.format.leftMargin,
                    this.format.rightMargin,
                    this.format.indent,
                    this.format.leading
                #end
            );*/
        }
        return this._hightlightFormat;
    }//function get_highlightFormat()


    /**
    * Setter for `.highlightFormat`
    *
    */
    @:noCompletion private function set_highlightFormat (hl:TextFormat) : TextFormat {
        return this._hightlightFormat = hl;
    }//function set_highlightFormat()


    /**
    * Refresh widget. Apply format to text, update text alignment and re-apply skin
    *
    */
    override public function refresh() : Void {
        /*if( this.highlighted ){
            this.label.defaultTextFormat = this.highlightFormat;
            if( this.label.text.length > 0 ){
                this.label.setTextFormat(this.highlightFormat #if cpp , 0 , this.text.length #end );
            }
        }else{
            this.label.defaultTextFormat = this.format;
            if( this.label.text.length > 0 ){
                this.label.setTextFormat(this.format #if cpp , 0 , this.text.length #end);
            }
        }*/

        if( !this.autoWidth && this.label.wordWrap ){
            this.label.width = this._width;
        }

        super.refresh();
    }//function refresh()

	public function resetFormat(color:Int,size:Int,bold:Bool = false):Void {
		#if android
		var textformat:TextFormat = new TextFormat();
		textformat.font = new Font("/system/fonts/DroidSansFallback.ttf").fontName;
		textformat.color = color;
		textformat.size = size;
		textformat.bold = bold;
		#else
		var textformat:TextFormat = new TextFormat(ru.stablex.ui.themes.gui.Main.FONT,size, color,bold);
		#end
		/*this.label.defaultTextFormat = textformat;
		this.label.embedFonts = true;
		this.format = textformat;*/
	}
	
	/**
	 * 15.5.15新增代码
	 */
	public function textWrapingCopy(textFieldString:String):String {
		
		var ary = textFieldString.split("");
		var str:String = "";
		var t:TextField = new TextField();
		t.autoSize=TextFieldAutoSize.LEFT;
		t.defaultTextFormat = this.format;
		t.wordWrap = false;
		for (i in 1...ary.length+1) 
		{
			t.appendText(ary[i - 1]);
			
			//if (t.width  > textFieldwidth)
			
			if (t.width  > this.w)
			{
				t.text = "";
				str += ary[i - 1]  + "\n";
			}else
			{
				str += ary[i-1];
			}	
			//DC.log("t.width="+t.width);
		}
		//DC.log(this.w +" widthPt:" + this.widthPt + " wparent:" + this.wparent +" label width:"+label.width);
		return str;
	}
	public  function textWraping(textFieldString:String, length:Int):String {
		//方法1
		var ary = textFieldString.split("");
				var str:String = "";
				for (i in 1...ary.length+1) 
				{
					if(i%length==0)
					{
						str += ary[i-1]  + "\n";
						
					}else {
						str += ary[i-1];
					}
					
				}
				DC.log("str2="+str);
				return str;
	}
	
	/*public static function textFieldWraping(TF:TextField,lenght:Int):String
	{
		var strtext = TF.text;
		var ary = strtext.split("");
		var str = "";
		var addLen:Float = 0;
		TF.autoSize = TextFieldAutoSize.LEFT;
		for(i in 0...strtext.length)
		{
			var addLennum = TF.getCharBoundaries(i).width;
			addLen += addLennum;
			trace("addLen=" + addLen +">>"+TF.width);
			if(addLen >lenght)
			{
				str += ary[i]  + "\n";
				addLen = 0;
			}else {
				str += ary[i] ;
			}
		}
		return str;
	}*/
	

    /**
     *  Highlight the text by applying `.highlightFormat`
     */
    public function highlight () : Void {
        this.highlighted = true;
        this.refresh();
    }//function highlight()


    /**
     *  Unhighlight the widget by setting its format back to `.format`
     */
    public function unhighlight () : Void {
        this.highlighted = false;
        this.refresh();
    }//function unhighlight()


    /**
    * Text getter
    *
    */
    @:noCompletion private function get_text() : String {
        return this.label.text;
    }//function get_text()
	

    /**
    * Text setter
    *
    */
    @:noCompletion private function set_text(txt:String) : String {
        //this.label.text = txt;
        this.label.text = autoWordWrap?textWrapingCopy(txt):txt;

        //if widget needs to be resized to fit new string size
        if( this.autoWidth || this.autoHeight ){
            this.refresh();
        //otherwise just realign text
        }else{
            this.alignElements();
        }

        return txt;
    }//function set_text()
/*	public function Text_wrapping(txtBool:Bool) : Bool {
        
    }*/
	private var _autoWordWrap = false;
	private function get_autoWordWrap() : Bool {
        return _autoWordWrap;
    }
	 private function set_autoWordWrap(bool:Bool) : Bool {
		//label.multiline = !bool;
		label.wordWrap = !bool;
		_autoWordWrap = bool;
        return _autoWordWrap;
    }

	private function get_size() : Float {
        return label.size;
    }
	 private function set_size(value:Float) : Float {
		label.size = value;
		return label.size;
    }

}//class Text
