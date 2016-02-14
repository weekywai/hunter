package com.metal.remote;

import com.metal.utils.FileUtils;
import sys.db.TableCreate;
import sys.db.Object;
import sys.db.Transaction;
import sys.db.Types;
import sys.db.Connection;
import sys.db.Sqlite;
import sys.db.Manager;
/**
 * ...
 * @author weeky
 */
class SQLite
{

	private var cnx:Connection;

	static function main() {
		new Main();
	}

	public function new() {
		// setup the db
		connectToDB();
		createTables();

		// use it
		var user = User.manager.search($disabled == false).first(); // PROBLEM!
		trace(user.name);
		
		// close it
		cnx.close();
	}

	private function connectToDB() {
		
		cnx = Sqlite.open(FileUtils.getPath() + "example.db");
		//Manager.cnx = cnx;
		//Manager.initialize();
		Transaction.main(cnx, logErr);
	}
	private function logErr(e)
	{
		
	}
	private function createTables() {
		if(!TableCreate.exists(User.manager)) {
			TableCreate.create(User.manager);
			//Transaction.isDeadlock();
			var u = new User();
			
			u.name = "John Doe";
			u.insert();
		}
	}
}

class User extends Object {
	public var id : SId;
	public var name : SString<32>;
	public var disabled : SBool = false;
}