package ru.stablex.ui.themes.gui.defaults ;

import ru.stablex.ui.themes.gui.Main;
import ru.stablex.ui.widgets.Toggle in WToggle;
import ru.stablex.ui.widgets.Widget;



/**
* Defaults for Toggle widget
*
*/
class Toggle {

    /**
    * Default section
    *
    */
    static public function Default (w:Widget) : Void {
        var btn = cast(w, WToggle);

        //the same as StateButton
        StateButton.Default(btn);

        btn.states.up.skinName   = 'button';
        btn.states.down.skinName = 'buttonPressed';
    }//function Default()

}//class Toggle