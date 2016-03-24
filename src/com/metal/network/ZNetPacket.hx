package com.metal.network;
import openfl.utils.ByteArray;

/**
 * ...
 * @author li
 */
class ZNetPacket
{
	//消息协议
	public var protocol(get, null):UInt;
	function get_protocol():UInt {
		return 0;
	}
	
	//0:服务器主动发来的消息  1:服务器收到客户端申请而返回的消息
	public var flag(get, null):Int;
	function get_flag():Int {
		return 0;
	}
	
	public var data:Dynamic;
	public function new() 
	{
		data = {};
	}
	
	public function Write(b:ByteArray):Void
	{
		
	}
	
	public function Read(b:ByteArray):Void
	{
		
	}
	
	public function toString():String
	{
		return "";
	}
	
}