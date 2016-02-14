package com.metal.network;
import com.metal.manager.UIManager;
import com.metal.message.MsgUI;
import haxe.ds.IntMap.IntMap;
import openfl.errors.Error;
import signals.Signal1;
import com.metal.network.NetRemoteManager;
/**
 * ...
 * @author weeky
 */
class Network
{
	
	private var _connection:IConnection;
	private var _connTryTime:Int;
	private var _tokenAssign:UInt;
	private var _callBacks:IntMap<Dynamic->Void>;
	private var _currentProtocol:UInt;
	
	private var hookPacket:Signal1<ZNetPacket>;
	private var hookPacketCallBack:Signal1<PacketData>;
	

	private static var _instance:Network;
	public static var instance(get, null):Network;
	private static function get_instance():Network {
		if (_instance == null) 
			_instance = new Network();
		return _instance;
	}
	
	private function new() 
	{
		_connection = NetRemoteManager.CreateNetwork(NetType.Http);
		init();
		_tokenAssign = 0;
		_callBacks = new IntMap();
	}
	
	private function init():Void
	{
		_connection.onConnect.add(onNetworkcConnect);
		_connection.onClose.add(onNetworkClose);
		_connection.onError.add(onNetworkError);
		_connection.onReponse.add(netWorkPacketCallBack);
		connect();
	}
	/**直接请求*/
	public function sendPacket(packet:ZNetPacket):Void
	{
		_connection.sendData(packet);
	}
	/**请求回调*/
	public function responsePacket(packet:ZNetPacket, callBack:Dynamic->Void = null, tag:Dynamic = null):Void
	{
		//var task:ZNetCallBack = new ZNetCallBack(callBack, tag);	
		_currentProtocol = packet.protocol;
		_callBacks.set(packet.protocol, callBack);
		sendPacket(packet);
	}
	
	public function connect():Void
	{
		_connection.connection(Main.config.get("host"), Main.config.get("port"));
		_connTryTime = 0;
	}
	
	public function disconnect():Void
	{
		_connection.disconnection();
		_connTryTime = 0;
	}
	
	private function onNetworkcConnect():Void
	{
		//trace("net work connected");
	}
	
	private function onNetworkClose():Void
	{
		//trace("net work disconnected");
	}
	
	private function onNetworkError(status:Int):Void
	{
		trace("net work error");
		if (status == 1) {
			//删除回掉引用
			_callBacks.remove(_currentProtocol);
			GameProcess.root.notify(MsgUI.Tips, { msg:"网络超时，请重试！", type:TipsType.tipPopup });
		}else {
			GameProcess.root.notify(MsgUI.Tips, { msg:"网络出错，请重试！", type:TipsType.tipPopup });
		}
		/*
		if (_connection.status) {
			_connTryTime++;
			if (_connTryTime >= 3) {
				_connTryTime = 0;
			} else {
				_connection.disconnection();
				_connection.connection(Main.config.get("host"), Main.config.get("port"));
			}
		} else {
			trace("Session Error : ");
		}
		*/
	}
	
	private function netWorkPacketCallBack(packet:PacketData):Void
	{
		//trace("net work receive packet");
		var isExistPacket:Bool = false;
		var existPacketNum:Int = 0;
		var callback = _callBacks.get(Reflect.field(packet.Content,"PROTOCOL"));
		if (callback != null)
		{
			_callBacks.remove(Reflect.field(packet.Content,"PROTOCOL"));
			callback(packet.Content);
		}
		else
		{
			trace("PT Packet protocol not found : " + Reflect.field(packet.Content,"PROTOCOL"));
		}
	}
}