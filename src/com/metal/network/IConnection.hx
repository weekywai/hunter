package com.metal.network;
import openfl.utils.ByteArray;
import signals.Signal0;
import signals.Signal1;

/**
 * @author weeky
 */

interface IConnection 
{
	function connection(host:String, port:Int):Void;
	function disconnection():Void;
	var status(get, null):Bool;
	function sendData(packet:ZNetPacket):Void;
	var onConnect:Signal0;
	var onClose:Signal0;
	var onError:Signal1<Int>;
	var onReponse:Signal1<PacketData>;
}