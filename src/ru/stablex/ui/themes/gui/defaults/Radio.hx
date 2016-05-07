package ru.stablex.ui.themes.gui.defaults ;

import ru.stablex.ui.themes.gui.Main;
import ru.stablex.ui.widgets.Radio in WRadio;
import ru.stablex.ui.widgets.Widget;


/**
* Defaults for Radio widget
*
*/
class Radio {

    /**
    * Default section
    *
    */
    static public function Default (w:Widget) : Void {
        var check = cast(w, WRadio);
        check.format.font  = ru.stablex.ui.themes.gui.Main.FONT;//Main.FONT;
        check.format.size  = 14;
        check.format.color = 0xFFFFFF;

        //check.states.up.ico.bitmapData   = Main.getBitmapData('img/radio.png');
        //check.states.down.ico.bitmapData = Main.getBitmapData('img/radioChecked.png');
    }//function Default()
	
	/*static public function Blue (w:Widget) : Void {
        var check:Radio = cast(w, Radio);
        check.format.font  = ru.stablex.ui.themes.gui.Main.FONT;//Main.FONT;
        check.format.size  = 28;
        check.format.bold  = false;
        check.format.color = 0xb8ffff;
        check.states.up.ico.bitmapData   = Main.getBitmapData('ui/storehouse/storehouse/anniu1-3.png');
        check.states.down.ico.bitmapData = Main.getBitmapData('ui/storehouse/storehouse/anniu1-2.png');
    }*/
}//class Radio