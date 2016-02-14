package com.metal.network;
import com.metal.config.RequestType;
import haxe.Http;
import haxe.remoting.HttpAsyncConnection;
import haxe.Timer;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequestMethod;
import openfl.net.URLVariables;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import pgr.dconsole.DC;
import signals.Signal0;
import signals.Signal1;

/**
 * ...
 * @author weeky
 */
class NetHttp implements IConnection
{
	private var _http:HttpAsyncConnection;
	//超时设置
	private var TIME_OUT:UInt = 30000;
	
	private var _timeout:Timer;
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
	private function get_status():Bool { return false; }
	private var _url:URLRequest;
	private var _loader:URLLoader;
	
	public function new() 
	{
		onConnect = new Signal0();
		onClose = new Signal0();
		onError = new Signal1();
		onReponse = new Signal1();
	}
	
	// 关闭连接
	public function Close():Void 
	{
		_recCallback.removeAll();
		_recTotalBytes = 0;
		_packet = null;
	}
	
	public function connection(host:String, port:Int):Void
	{
		var path = host+"/" + RequestType.urlList[1];
		//trace(path);
		_http = HttpAsyncConnection.urlConnect(path);
		_http.setErrorHandler(ioErrorHandler);
		_url=new URLRequest("http://"+path);
		//var postdata:URLVariables = new URLVariables();
		_url.method = URLRequestMethod.POST;
		_loader = new URLLoader();
		_loader.dataFormat = URLLoaderDataFormat.VARIABLES;
	}
	
	public function disconnection():Void
	{
		try
		{
		} catch (msg:Dynamic)
		{
			//trace("ERROR:" + msg);
		}
	}
	
	
	
	public function setTimeOut(timeout:UInt):Void
	{
		TIME_OUT = timeout;
	}
	
	//上层传来数据
	public function sendData(packet:ZNetPacket):Void
	{
		//trace("send");
		trace(_url.url);
		_loader.addEventListener(Event.COMPLETE, onDataHandler);
		_loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		_url.data = packet.data;
		_loader.load(_url);
		_timeout = Timer.delay(onDataTimeout, TIME_OUT);
		//有回调
		//if(packet.flag==1)
		//_http.Server.add.call([12, 2], onDataHandler);
		//_http.Server.joinStr.call(["Xiong","Yan"],onDataHandler);
		//_http.Server.regist.call([], onDataHandler);
		//_http.mobileReg.call([], onDataHandler);
		//test();
		//testlogin();
	}
	private function testlogin()
	{
		var url:URLRequest=new URLRequest("http://"+_url);
		var postdata:URLVariables = new URLVariables();
   
		url.method = URLRequestMethod.POST;
		var loader:URLLoader = new URLLoader();
		loader.dataFormat=URLLoaderDataFormat.VARIABLES;
		//如果有参数，在这里写
	    var postdata = {}; 
		Reflect.setField(postdata,"username", "weeky");
		Reflect.setField(postdata,"password", "123456");
		Reflect.setField(postdata,"lifetime", 0);
		Reflect.setField(postdata,"tobind", 0);
		Reflect.setField(postdata,"ecmsfrom","");
		Reflect.setField(postdata, "groupid", 1);
		Reflect.setField(postdata, "enews", "mobileLogin");
		url.data = postdata;
		loader.addEventListener(Event.COMPLETE,onDataHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		loader.load(url);
	}
	private function test()
	{
		var url:URLRequest=new URLRequest("http://"+_url);
		var postdata:URLVariables = new URLVariables();
   
		url.method = URLRequestMethod.POST;
		var loader:URLLoader = new URLLoader();
		loader.dataFormat=URLLoaderDataFormat.VARIABLES;
		//如果有参数，在这里写
	    var postdata = {}; 
		Reflect.setField(postdata,"username", "weeky");
		Reflect.setField(postdata,"password", "123456");
		Reflect.setField(postdata,"repassword", "123456");
		Reflect.setField(postdata,"tobind", 0);
		Reflect.setField(postdata,"key","");
		Reflect.setField(postdata, "groupid", 1);
		Reflect.setField(postdata, "enews", "register");
		url.data = postdata;
		loader.addEventListener(Event.COMPLETE,onDataHandler);
		loader.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
		loader.load(url);
	}
	//打包数据
	private function encodePacket(_packet:PacketData):ByteArray
	{
		return null;
	}
	
	
	//注册接收数据的字节数和回调函数
	private function registRecInfo(_rec:UInt, _callback:ByteArray->Void):Void
	{
		
	}
	
	
	//返回数据到上层
	private function response():Void
	{
		
	}
	
	private function onConnectHandler(event):Void
	{
		DC.log("ConnectHandler " + event);
		onConnect.dispatch();
	}
	private function onStateHandler(event:Int):Void
	{
		DC.log("StateHandler " + event);
		onConnect.dispatch();
	}
	
	private function onCloseHandler(event:Event):Void
	{
		DC.log("CloseHandler " + event);
		onClose.dispatch();
	}
	
	private function ioErrorHandler(event):Void
	{
		removeTimeout();
		//trace("ioErrorHandler " + event);
		DC.log("ioErrorHandler " + event);
		onError.dispatch(0);
	}
	
	private function onDataHandler(event):Void
	{
		removeTimeout();
		var returndata = event.currentTarget.data;
		var vars:URLVariables = new URLVariables(returndata);
		//trace("onDataHandler " + vars);
		DC.log("onDataHandler " + returndata);
		var packet:PacketData = new PacketData();
		packet.Content = vars;
		onReponse.dispatch(packet);
	}
	private function removeTimeout():Void 
	{
		_loader.removeEventListener(Event.COMPLETE, onDataHandler);
		_loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		_timeout.stop();
		_timeout = null;
	}
	private function onDataTimeout():Void 
	{
		//trace("timeout");
		
		removeTimeout();
		onError.dispatch(1);
	}
}