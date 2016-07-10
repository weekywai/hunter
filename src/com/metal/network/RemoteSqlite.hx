package com.metal.network;

import com.metal.config.ItemType;
import flash.utils.ByteArray;
import haxe.db.ResultSet;
import haxe.ds.StringMap;
import openfl.Assets;
import openfl.filesystem.File;
import haxe.db.Sqlite;
import haxe.db.Connection;
/**
 * sqlite
 * @author weeky
 */
class RemoteSqlite
{
	public static var instance(default, null):RemoteSqlite = new RemoteSqlite();
	private var _cnx:Connection;
	private var _data:Connection;
	/**记录是否空表*/
	private var _table:StringMap<Bool>;
	
	public function new() 
	{
		_table = new StringMap();
		var filePath:String, userPath:String;
		#if android
			filePath = File.applicationStorageDirectory.nativePath + "/proto";
			if(!sys.FileSystem.exists(filePath)){
				sys.io.File.saveBytes(filePath, Assets.getBytes("proto/proto.db"));
			}
			
			userPath = File.applicationStorageDirectory.nativePath + "/null";
			if (!sys.FileSystem.exists(userPath)) {
				/*Assets.loadBytes ("proto/null.db", function(bytes:ByteArray) {
					trace(bytes.length);
					if (bytes.length != 0)
						sys.io.File.saveBytes(userPath, bytes);
				});*/
				var b = Assets.getBytes("proto/null.db");
				
				sys.io.File.saveBytes(userPath, b);
			}
		#else
			filePath = "proto/proto.db";
			userPath = "proto/null.db";
		#end
		
		//trace(Assets.getBytes("proto/a").length);
		_data = Sqlite.open(userPath);
		_cnx = Sqlite.open(filePath);
		//readDb();
		//var a = request("prop_item", "ItemKind2", ItemType.IK2_GON);
		//trace(a.length);
	}
	
	private function readDb()
	{
		var a = _cnx.request ("SELECT * FROM prop_actor");
		var p = [];
		for (i in a) {
			p.push(i);
		}
		trace(p.length);
	}
	
	private function emptyTable(table:String):Bool
	{
		if (_table.exists(table))
			return _table.get(table);
		var data = _data.request ("SELECT count(*) a FROM " + table);
		for (r in data){
			if (r.a == 0) {
				_table.set(table, true);
			}
		}
		_table.set(table, false);
		return _table.get(table);
	}
	public function request(table:String, ?fields:String, ?value:Dynamic, ?row:Dynamic):Array<Dynamic>
	{
		var req = requestStr(table, fields, value, row);
		//return _cnx.request (req);
		var data = _cnx.request (req);
		return parse(data);
	}
	
	public function requestProfile(table:String, ?fields:String, ?value:Dynamic, ?row:Dynamic):Array<Dynamic>
	{
		if (emptyTable(table))
			return null;
		var req = requestStr(table, fields, value, row);
		//return _data.request (req);
		var data = _data.request (req);
		return parse(data);
	}
	private function requestStr(table:String, ?fields:String, ?value:Dynamic, ?row:Dynamic):String
	{
		var req:String = "SELECT ";
		if (row != null)
			req += row + " FROM " + table;
		else
			req += "* FROM " + table;
		
		if (fields != null) {
			req += " WHERE " + fields;
			if (value != null)
				req += " IN (" + value + ")";
		}
		return req;
	}
	/**
	 * fields  {field:value} 	SET
	 * row	   {rowName:value}	WHERE
	 */
	public function updateProfile(table:String, fields:Dynamic = null, row:Dynamic = null ):Void
	{
		var req:String = "UPDATE " + table +" SET ";
		if (fields != null) {
			//req += fields;
			var keys = Reflect.fields(fields);
			for (key in keys) 
			{
				req += key +"=" + check(Reflect.field(fields, key)) + ",";
			}
			req = req.substr(0, req.length - 1);
		}
		if (row != null) {
			req += " WHERE ";
			var keys = Reflect.fields(row);
			for (key in keys) 
			{
				req += key +"=" + check(Reflect.field(row, key)) + ",";
			}
			req = req.substr(0, req.length - 1);
		}
		_data.request (req);
	}
	public function deleteProfile(table:String, row:Dynamic = null, values:Array<Dynamic> = null ):Void
	{
		//DELETE FROM 表名称 WHERE 列名称 = 值
		var req:String = "DELETE FROM " + table+" WHERE ";
		for (i in values) 
		{
			if (i == values.length - 1)
				req += row +"=" + check(i);
			else
				req += row +"=" + check(i) + " OR ";
		}
		_data.request (req);
	}
	/** fields 整条插入 rows 单个指定数据*/
	public function addProfile(table:String, fields:Array<Dynamic> = null, rows:Dynamic = null):Void
	{
		var req:String = "INSERT INTO " + table;
		if (fields != null) {
			req += " VALUES (" + fields.join(",") +")";
		}
		if (rows != null) {
			var keys = Reflect.fields(rows);
			var f = keys.join(",");
			req += " ( " + f + " ) ";
			var values = [];
			for (key in keys) 
			{
				values.push(check(Reflect.field(rows, key)));
			}
			var v = values.join(",");
			req += " VALUES (" + v +")";
		}
		_data.request (req);
	}
	
	private function parse(data:ResultSet):Array<Dynamic>
	{
		var temp = [];
		for (i in data)
			temp.push(i);
		return temp;
	}
	
	private function check(v:Dynamic):Dynamic
	{
		if (Std.is(v, String) || Std.is(v, Date)){
			return "'" + v + "'";
		}else if (Std.is(v, Bool)){
			return v?1:0;
		}else
			return v;
	}
}