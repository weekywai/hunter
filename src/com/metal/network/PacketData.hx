package com.metal.network;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

/**
 * ...
 * @author li
 */
class PacketData
{
	//public static var FlagConnectionRelated:Int = 128;
	//public static var FlagEncrypted:Int = 64;
	//public static var FlagCompressed:Int = 32;
	//public static var FlagNone:Int = 0;
	//
	//
	//public var Flags:Int;
	//
	//public var PrimaryCode:Int;
	//
	//public var SecondaryCode:Int;
	
	//包的长度的字节数（包头4字节）
	public var PacketSize:UInt;
	
	//消息类型的协议（2字节）
	public var Protocol:UInt;
	
	//消息数据长度
	public var DataSize:UInt;
	
	//消息数据内容
	public var Data:ByteArray;
	public var Content:Dynamic;
	public function new() 
	{
		Data = new ByteArray();
		Data.endian = NetConnection.SocketEndian;
	}

	
	public function toString():String {
		return "PacketSize:" + PacketSize + " Protocol:" + Protocol + " DataSize:" + DataSize;
	}
	
}