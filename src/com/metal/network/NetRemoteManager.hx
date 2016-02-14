package com.metal.network;
import com.metal.network.NetSocket;

/**
 * ...
 * @author weeky
 */
enum NetType {
	Http;
	Socket;
}
class NetRemoteManager
{
	public static var connection:IConnection = null;
	public function new() 
	{
		
	}
	
	public static function CreateNetwork(type:NetType):IConnection 
	{
		switch(type) {
			case Http:
				connection =  new NetHttp();
			case Socket:
				connection =  new NetSocket();
		}
		return connection;
	}
}