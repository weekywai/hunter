package com.metal.network;
import haxe.ds.IntMap.IntMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author li
 */
class ZNetPacketCreator
{
	private static var _instance:ZNetPacketCreator;
	public static var instance(get, null):ZNetPacketCreator;
	private static function get_instance():ZNetPacketCreator {
		if (_instance == null) {
			_instance = new ZNetPacketCreator();
		}
		return _instance;
	} 

	private var _packetClass:IntMap<Class<Dynamic>>;
	
	
	public function new() 
	{
		_packetClass = new IntMap();
	}
	
	@keep public function RegisterPacketClass(cls:Class<Dynamic>):Void
	{
		var packet:ZNetPacket = Type.createInstance(cls, []);
		if (packet == null) throw("Class new Error");
		
		var code:UInt = packet.protocol;
		//trace("RegisterPacketClass " + code);
		if (_packetClass.get(code) != null) throw("Class exist : " + cls);
		_packetClass.set(code, cls);
	}
	
	public function GetNetPacket(data:PacketData):Array<ZNetPacket>
	{
		var code:UInt = data.Protocol;
		var packetArray:Array<ZNetPacket> = new Array();
		//trace(data.Protocol);
		//大包，特殊处理
		if (code == NetProtocol.PT_BIG_PACKET)
		{
			var packetNum = data.Data.readUnsignedShort();
			for (i in 0...packetNum)
			{
				var perPacket:PacketData = new PacketData();
				perPacket.PacketSize = data.Data.readUnsignedShort();
				perPacket.Protocol = data.Data.readUnsignedShort();
				if (perPacket.PacketSize > 4)
				{
					perPacket.DataSize = perPacket.PacketSize - 4;
					data.Data.readBytes(perPacket.Data, 0, perPacket.DataSize);
					perPacket.PacketSize = perPacket.DataSize + 4;
				}
				//trace("little packet " + perPacket.Protocol);
				var cls:Class<Dynamic> = _packetClass.get(perPacket.Protocol);
				if (cls != null)
				{
					var packet:ZNetPacket = Type.createInstance(cls, []);
					packet.Read(perPacket.Data);
					packetArray.push(packet);
				} 
			}
		}
		else
		{
			var cls:Class<Dynamic> = _packetClass.get(code);
			if (cls != null)
			{
				var packet:ZNetPacket = Type.createInstance(cls, []);
				packet.Read(data.Data);
				packetArray.push(packet);
			}
		}
		
		return packetArray;
	}
	
}