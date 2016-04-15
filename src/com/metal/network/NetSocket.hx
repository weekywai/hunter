package com.metal.network;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.Socket;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import signals.Signal0;
import signals.Signal1;

/**
 * ...
 * @author weeky
 */
class NetSocket implements IConnection
{
	//大小端设置
	#if flash
	private static var EndianModle:Endian = Endian.LITTLE_ENDIAN; 
	public static var SocketEndian(get, set):Endian;
	private static function set_SocketEndian(endian:Endian):Endian { EndianModle = endian; return endian; }
	private static function get_SocketEndian():Endian { return EndianModle; }
	#else
	private static var EndianModle:String = Endian.LITTLE_ENDIAN; 
	public static var SocketEndian(get, set):String;
	private static function set_SocketEndian(endian:String):String { EndianModle = endian; return endian; }
	private static function get_SocketEndian():String { return EndianModle; }
	#end

	//包头长度字节数
	public static var HeaderLen:Int = 4;
	
	//超时设置
	public var TIME_OUT:UInt = 5000;
	
	private var _socket:Socket;
	
	//接收数据字节数
	private var _recTotalBytes:UInt = 0;
	
	//接收数据的回调函数
	private var _recCallback:Signal1<ByteArray>;
	
	//将接收到的数据拼接成包
	private var _packet:PacketData;
	
	//注册回调函数
	public var onConnect:Signal0;
	public var onClose:Signal0;
	public var onError:Signal1<Int>;
	public var onReponse:Signal1<PacketData>;
	
	public var status(get, null):Bool;
	private function get_status():Bool { return _socket.connected; }
	
	public function new() 
	{
		_socket = new Socket();
		_socket.endian = EndianModle;
		_socket.timeout = TIME_OUT;
		
		onConnect = new Signal0();
		onClose = new Signal0();
		onError = new Signal1();
		onReponse = new Signal1();
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
		_recCallback.removeAll();
		_recTotalBytes = 0;
		_packet = null;
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
	
	
	
	public function setTimeOut(timeout:UInt):Void
	{
		TIME_OUT = timeout;
	}
	
	//上层传来数据
	public function sendData(packet:ZNetPacket):Void
	{
		if(status)
		{	
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			packet.Write(data);
			
			var packetData:PacketData = new PacketData();
			packetData.Protocol = packet.protocol;
			packetData.Data = data;
			packetData.DataSize = data.length;
			packetData.PacketSize = data.length + 6;
			var packetDataByte:ByteArray = encodePacket(packetData);
			sendPacket(packetDataByte);
		}
	}
	
	//打包数据
	private function encodePacket(packet:PacketData):ByteArray
	{
		var packetByte:ByteArray = new ByteArray();
		packetByte.endian = EndianModle;
		packetByte.writeUnsignedInt(packet.PacketSize);
		
		packetByte.writeShort(packet.Protocol);
		packetByte.writeBytes(packet.Data, 0, packet.DataSize);
		return packetByte;
	}
	
	//发包
	private function sendPacket(packet:ByteArray):Void
	{
		_socket.writeBytes(packet, 0, packet.length);
		_socket.flush();
	}
	
	//注册接收数据的字节数和回调函数
	private function registRecInfo(_rec:UInt, _callback:ByteArray->Void):Void
	{
		if (_rec == 0) throw new Error("The length of the data to receive is null!");
		if (_callback == null) throw new Error("The function to handle the data received is null");
		_recTotalBytes = _rec;
		_recCallback.add(_callback);
	}
	
	//接收数据
	private function receiveData():Void
	{
		if (_recTotalBytes == 0) return;
		while (_socket.connected && _recTotalBytes <= _socket.bytesAvailable)
		{
			var b:ByteArray = new ByteArray();
			b.endian = EndianModle;
			_socket.readBytes(b, 0, _recTotalBytes);
			_recTotalBytes = 0;
			//recDataCallback(b);
			_recCallback.dispatch(b);
		}	
	}
	
	//解析包头信息
	private function recPacketHead(b:ByteArray):Void
	{
		_packet = new PacketData();
		_packet.PacketSize = b.readUnsignedInt();
		if (_packet.PacketSize == 0) 
		{
			returnPacketData();
			registRecInfo(HeaderLen, recPacketHead);
		} else
		{
			registRecInfo(_packet.PacketSize - 4, recPacketBody);
		}
	}
	
	//解析包数据
	private function recPacketBody(b:ByteArray):Void
	{
		if (_packet.PacketSize != b.length + 4) 
		{
			throw new Error("packet data length mismatch " + _packet.PacketSize + ":" + b.length);
		}
		_packet.Protocol = b.readUnsignedShort();
		_packet.DataSize = b.length - 2;
		b.readBytes(_packet.Data,0,_packet.DataSize);
		returnPacketData();
		registRecInfo(HeaderLen, recPacketHead);
	}
	
	//返回数据到上层
	private function returnPacketData():Void
	{
		var packet:PacketData = _packet;
		onReponse.dispatch(_packet);
		_packet = null;
	}
	
	private function socketConnectHandler(event:Event):Void
	{
		//trace("socketConnectHandler " + event);
		registRecInfo(HeaderLen, recPacketHead);
		onConnect.dispatch();
	}
	
	private function socketCloseHandler(event:Event):Void
	{
		//trace("socketCloseHandler " + event);
		onClose.dispatch();
	}
	
	private function ioErrorHandler(event:IOErrorEvent):Void
	{
		//trace("ioErrorHandler " + event);
		onError.dispatch(0);
	}
	
	private function socketDataHandler(event:ProgressEvent):Void
	{
		//trace("socketDataHandler " + event);
		receiveData();
	}
}