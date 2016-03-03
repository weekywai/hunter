package com.metal.utils;
import com.metal.component.GameSchedual;
import com.metal.message.MsgStartup;
import haxe.ds.StringMap;
import openfl.errors.Error;
import pgr.dconsole.DC;
import spinehaxe.JsonUtils;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
import openfl.Assets;
import com.metal.config.FilesType;
import openfl.utils.SystemPath;
import haxe.Json;
/**
 * ...
 * @author hyg
 */
using spinehaxe.JsonUtils;

typedef UserData = 
{
	id:String,
	name:String,
	pwd:String
}

class LoginFileUtils
{
	static private var _path:String;
	static private var _file:String = "user";
	static private var _filePath:String;
	public static var FileExits(get, null):Bool;
	public static var Id:String = "";
	public static var FileData:JsonNode = null; 
	static private function get_FileExits():Bool
	{
		#if sys
		_path = FileUtils.getPath() + "/user/";
		//trace(_path);
		//return true;
		if (!FileSystem.exists(_path))
		{
			FileSystem.createDirectory(_path);
		}
		if (!FileSystem.exists(_path+_file)) {
			saveFile();
		}
		return FileSystem.exists(_path + _file);
		#else
		return false;
		#end
		
	}
	public function new() 
	{
		
	}
	/**
	 * Save data to file
	 * */
	private static function saveFile():Void
	{
		#if sys
		var filePath:String = _path + _file;
		//var filePath:String = _filePath;
		var f:FileOutput = File.write( filePath, false );
		var strData:String = Json.stringify(FileData);
		f.writeString(strData);
		f.close();
		#end
	}
	/**组合数据*/
	public static function saveLogin(data:Dynamic, ?name:String):Void
	{
		if (data != null)
		{
			if(FileData == null)	
				initFileData();
			var find:Bool = false;
			if (FileData != null) {
				var root:JsonNode = JsonUtils.getNode(FileData, "data");
				var node:JsonNode = null;
				
				for (key in root.fields())
				{
					node = root.getNode(key);
					if (JsonUtils.getStr(node, "id") == data.id) {
						find = true;
						JsonUtils.setDynamic(FileData, "id", key);
						break;
					}
				}
				if (!find) {
					var len = root.fields().length;
					Reflect.setField(root, Std.string(len), data);
					JsonUtils.setDynamic(FileData, "id", len);
				}
			}else {
				FileData = {"id":"0", "data":{"0":data}};
			}
			
			Id = JsonUtils.getStr(FileData, "id");
			saveFile();
		}
	}
	
	/**获取登录数据*/
	public static function getLoginData(account:String = ""):Dynamic
	{
		if (FileExits) {
			initFileData();
			trace(FileData);
			if (FileData == null) return null;
			var root:JsonNode = FileData.getNode("data");
			var id = FileData.getNode("id");
			var node:JsonNode = null;
			for (key in root.fields())
			{
				if (account != "") 
				{
					node = root.getNode(key);
					if (node.getStr("id") == account)
						return node;
				}
				else
				{
					if(key == id)
						return root.getNode(key);
				}
			}
			Id = FileData.getStr("id");
		}
		return null;
	}
	/**获取新手帮助数据*/
	public static function getNewBie():Array<Int>
	{
		trace("getNewBie");
		var temp:Array<Int> = [];
		if (FileData == null)
			initFileData();
		if (FileData == null) 
			return temp;
			//throw "user " + Id +" null";
		var root:JsonNode = JsonUtils.getNode(FileData, "data");
		var node:JsonNode = JsonUtils.getNode(root, Id);
		var ary = JsonUtils.getNodesArray(node, "n");
		if (ary != null)
		{
			for (i in ary) 
			{
				temp.push(Std.parseInt(i));
			}
		}
		return temp;
	}
	public static function saveNewBie(data:Dynamic):Void
	{
		if (data == null)
			return;
		if (FileData == null)
			initFileData();
		//if (FileData == null) 
			//throw "user " + Id +" null";
		var root:JsonNode = JsonUtils.getNode(FileData, "data");
		var node:JsonNode = JsonUtils.getNode(root, Id);
		JsonUtils.setDynamic(node, "n", data);
		
		if (FileExits) saveFile();
	}
	
	private static function initFileData()
	{
		if (FileExits) {
			var fileContent = File.getContent( _path +_file);
			FileData = JsonUtils.parse(fileContent);
		}
	}
}