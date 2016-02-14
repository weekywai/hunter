package ru.stablex.ui.events;

import flash.events.Event;

/**
* Events dispatched by widgets
*/

class CustomEvent extends Event{

	//Dispatched when a widget is attach recive notify
    static public inline var NOTIFY = 'widgetNotify';
    static public inline var UPDATE = 'widgetUpdate';

    //widget which dispatched this event
    public var data (get,never) : Dynamic;
    private var _data : Dynamic;


    /**
    * Constructor
    *
    */
    public function new(type:String, data:Dynamic = null) : Void {
        super(type);
        this._data = data;
    }//function new()


    /**
    * Getter for `widget`
    *
    */
    @:noCompletion private function get_data () : Dynamic {
        return this._data;
    }//function get_widget()

}//class WidgetEvent