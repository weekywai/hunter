package com.metal.network;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.Socket;
import openfl.utils.ByteArray;
import openfl.utils.Endian;

/**
 * ...
 * @author li
 */
class NetConnection
{
#if flash
	//大小端设置
	private static var EndianModle:Endian = Endian.LITTLE_ENDIAN; 
	public static var SocketEndian(get, set):Endian;
	private static function set_SocketEndian(endian:Endian):Endian { EndianModle = endian; return endian; }
	private static function get_SocketEndian():Endian{ return EndianModle; }
#else
	//大小端设置
	private static var EndianModle:String = Endian.LITTLE_ENDIAN; 
	public static var SocketEndian(get, set):String;
	private static function set_SocketEndian(endian:String):String { EndianModle = endian; return endian; }
	private static function get_SocketEndian():String{ return EndianModle; }
#end
	//包头长度字节数
	public static var HeaderLen:Int = 4;
	
	//超时设置
	public var TIME_OUT:UInt = 5000;
	
	private var _socket:Socket;
	
	//接收数据字节数
	private var recDataCount:UInt = 0;
	
	//接收数据的回调函数
	private var recDataCallback:ByteArray->Void;
	
	//将接收到的数据拼接成包
	private var packet:PacketData;
	
	// 只可以Config一次的机制
	private var isCallBackConfig:Bool = false;
	//注册回调函数
	private var connectCallBack:Void->Void;
	private var closeCallBack:Void->Void;
	private var errorCallBack:Void->Void;
	private var packetCallBack:PacketData->Void;
	
	public function new() 
	{
		_socket = new Socket();
		_socket.endian = EndianModle;
		_socket.timeout = TIME_OUT;
		
		_socket.addEventListener(Event.CONNECT, socketConnectHandler);
		_socket.addEventListener(Event.CLOSE, socketCloseHandler);
		_socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		_socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
	}
	
	// 关闭连接
	public function Close():Void 
	{
		//_socket.close();
		disconnection();
		recDataCallback = null;
		recDataCount = 0;
		packet = null;
	}
	
	// 挂接事件
	public function ConfigCallBack(_connectCallBack:Void->Void = null, _closeCallBack:Void->Void = null, _errorCallBack:Void->Void = null, _packetCallBack:PacketData->Void = null):Void 
	{
		if (isCallBackConfig) throw new Error("Can not config again!");
		connectCallBack = _connectCallBack;
		closeCallBack = _closeCallBack;
		errorCallBack = _errorCallBack;
		packetCallBack = _packetCallBack;
		isCallBackConfig = true;
	}
	
	public function connection(host:String, port:Int):Void
	{
		_socket.connect(host, port);
	}
	
	public function disconnection():Void
	{
		try
		{
			if (_socket.connected)
			{
				_socket.close();
			}
		} catch (msg:Dynamic)
		{
			trace("ERROR:" + msg);
		}
	}
	
	public function getSocketStatus():Bool
	{
		return _socket.connected;
	}
	
	public function setTimeOut(timeout:UInt):Void
	{
		TIME_OUT = timeout;
	}
	
	//上层传来数据
	public function sendPacketData(_protocol:UInt, _data:ByteArray):Void
	{
		var _packet:PacketData = new PacketData();
		_packet.Protocol = _protocol;
		_packet.Data = _data;
		_packet.DataSize = _packet.Data.length;
		_packet.PacketSize = _packet.DataSize + 6;
		var packetDataByte:ByteArray = encodePacket(_packet);
		sendPacket(packetDataByte);
	}
	
	//打包数据
	private function encodePacket(_packet:PacketData):ByteArray
	{
		var packetByte:ByteArray = new ByteArray();
		packetByte.endian = EndianModle;
		packetByte.writeUnsignedInt(_packet.PacketSize);
		
		packetByte.writeShort(_packet.Protocol);
		packetByte.writeBytes(_packet.Data, 0, _packet.DataSize);
		return packetByte;
	}
	
	//发包
	private function sendPacket(_packet:ByteArray):Void
	{
		_socket.writeBytes(_packet, 0, _packet.length);
		_socket.flush();
	}
	
	//注册接收数据的字节数和回调函数
	private function registRecInfo(_rec:UInt, _callback:ByteArray->Void):Void
	{
		if (_rec == 0) throw new Error("The length of the data to receive is null!");
		if (_callback == null) throw new Error("The function to handle the data received is null");
		recDataCount = _rec;
		recDataCallback = _callback;
	}
	
	//接收数据
	private function receiveData():Void
	{
		if (recDataCount == 0) return;
		while (_socket.connected && recDataCount <= _socket.bytesAvailable)
		{
			var b:ByteArray = new ByteArray();
			b.endian = EndianModle;
			_socket.readBytes(b, 0, recDataCount);
			recDataCount = 0;
			//recDataCallback(b);
			Reflect.callMethod(ByteArray, recDataCallback, [b]);
		}	
	}
	
	//解析包头信息
	private function recPacketHead(b:ByteArray):Void
	{
		packet = new PacketData();
		packet.PacketSize = b.readUnsignedInt();
		if (packet.PacketSize == 0) 
		{
			returnPacketData();
			registRecInfo(HeaderLen, recPacketHead);
		} else
		{
			registRecInfo(packet.PacketSize - 4, recPacketBody);
		}
	}
	
	//解析包数据
	private function recPacketBody(b:ByteArray):Void
	{
		if (packet.PacketSize != b.length + 4) 
		{
			throw new Error("packet data length mismatch " + packet.PacketSize + ":" + b.length);
		}
		packet.Protocol = b.readUnsignedShort();
		packet.DataSize = b.length - 2;
		b.readBytes(packet.Data,0,packet.DataSize);
		returnPacketData();
		registRecInfo(HeaderLen, recPacketHead);
	}
	
	//返回数据到上层
	private function returnPacketData():Void
	{
		var _packet:PacketData = packet;
		packet = null;
		if (packetCallBack != null)
		{
			Reflect.callMethod(PacketData,packetCallBack,[_packet]);
		}
	}
	
	private function socketConnectHandler(event:Event):Void
	{
		//trace("socketConnectHandler " + event);
		registRecInfo(HeaderLen, recPacketHead);
		if (connectCallBack != null) Reflect.callMethod(null,connectCallBack,[]);
	}
	
	private function socketCloseHandler(event:Event):Void
	{
		//trace("socketCloseHandler " + event);
		if (closeCallBack != null) Reflect.callMethod(null,closeCallBack,[]);
	}
	
	private function ioErrorHandler(event:IOErrorEvent):Void
	{
		//trace("ioErrorHandler " + event);
		if (errorCallBack != null) Reflect.callMethod(null,errorCallBack,[]);
	}
	
	private function socketDataHandler(event:ProgressEvent):Void
	{
		//trace("socketDataHandler " + event);
		receiveData();
	}
}