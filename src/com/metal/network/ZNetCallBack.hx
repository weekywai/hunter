package com.metal.network;

/**
 * ...
 * @author li
 */
class ZNetCallBack
{
	private var _callBack:ZNetPacket->Dynamic->Void;
	
	private var _tag:Dynamic;
	public var Tag(get, null):Dynamic;
	private function get_Tag():Dynamic
	{
		return _tag;
	}
	
	public function new(callBack:ZNetPacket->Dynamic->Void = null, tag:Dynamic = null) 
	{
		_callBack = callBack;
		_tag = tag;
	}
	
	public function CallBack(packet:ZNetPacket)
	{
		if (_callBack != null)
		{
			_callBack(packet, _tag);
		}
	}
	
}