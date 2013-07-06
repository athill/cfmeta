/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/Db.cfc
* @author  
* @description
*
*/

component output="false" displayname=""  {

	This.dsn = Request.AppDSN;
	Variables.h = Request.html;

	/**
	 * Initializes the db
	 */
	function init(string dsn=This.dsn hint="default data source")	{
		This.dsn=dsn;
	}

	/**
	* Retrieves or generates and retrieves an object indicating the structure of the table
	*/
	function getDSObject(required string table, string dsn=This.dsn) {
		tablename = Replace(table, ".", "__", "ALL");
		var filename = Request.webroot&"/components/datasources/"&tablename&".cfc";
		var objectpath = 'components.datasources.'&tablename;
		//// obect doesn't exist, create it
		if (not FileExists(ExpandPath(filename))) {
			//// get metadata from db
			var sql = "SELECT column_name, data_type, character_maximum_length " & 
					"FROM information_schema.columns " & 
					"WHERE table_name=?";
			var data = This.query(sql, [ table ], dsn);
			//// generate component file
			var nl = Chr(13); var tab = Chr(9);
			var str = "<cfcomponent>" & nl & tab & "<cfscript>" & nl;
			for (var i = 1; i le data.recordCount; i++) {
				str &= tab & "This."&data.column_name[i]&" = StructNew();" & nl;
				str &= tab & "This."&data.column_name[i]&".type = '"&data.data_type[i]&"';" & nl;
				if (data.character_maximum_length[i] neq "")
					str &= tab & "This."&data.column_name[i]&".size = "&data.character_maximum_length[i]&";" & nl & nl;	
			}
			str &= tab & "</cfscript>" & nl & "</cfcomponent>";
			filewrite(ExpandPath(filename), str);
		}
		//// instantiate object
		return CreateObject("component", objectpath);
	}
	
	/**
	* Converts basic DB types into CF DB Types (e.g., datetime-&gt;cf_sql_date)
	*/
	function getCfSqlType(required string dbtype)  {
		var cfType = "cf_sql_";
		switch (dbtype) {
			case "datetime":
				cfType &= "date";
				break;
			case "int":
				cfType &= "integer";
				break;
			case "text":
			case "ntext":
				cfType &= "longvarchar";
				break;
			case "varchar":
			case "nvarchar":
				cfType &= "varchar";
			case "bigint":
			case "tinyint":
			case "decimal":
			default:
				cfType &= dbtype;
		}
		return cfType;
	}
	/**
	* Interpolates args array into ?'s in sql to guard against SQL injection
	* also can use named arguments
	*/
	function safeQuery(required string sql, array argsArray=[])  {
		var dsn = IIf(ArrayLen(Arguments) ge 3, DE(Arguments[3]), DE("Ses"));
		var q = new query(); 
		q.setDatasource(dsn);
		for (var i = 1; i le ArrayLen(argsArray); i++) {
			////value only
			if (!isStruct(argsArray[i])) {
				////list
				if (isArray(argsArray[i])) {
					q.addParam(value = arraytolist(argsArray[i]), list=true);
				} else {
					////simple value
					q.addParam(value = argsArray[i]);
				}
			//// struct
			} else {
				var attrs = { value = argsArray[i].value };
				if (structKeyExists(argsArray[i], 'name')) {
					attrs.name = argsArray[i].name;
				}
				if (structKeyExists(argsArray[i], 'type')) {
					attrs.cfsqltype = 'cf_sql_'&argsArray[i].type;
				}
				q.addParam(argumentCollection=attrs);
			}
		}
		var r = q.execute(sql = preserveSingleQuotes(sql));
		var result = r.getResult();
		if (IsDefined('result')) {
			return result;
		} else {
			return r;
		}
	}
	

	/**
	* Basic query mechanism. If args not array, args is dsn
	*/
	public any function query(required string sql, any args, string dsn=This.dsn) {
		if (!IsDefined('args')) {
			args = This.dsn;
		}
		if (isArray(args)) {
			return This.safeQuery(sql, args, dsn);
		} else {
			return This.safeQuery(sql, [], args);
		}
		return;
	}

// <cffunction name="query">
// <cfargument name="queryString" type="string" required="yes">
// <cfargument name="dsn" type="string" required="no" default="#This.dsn#">
// <cfargument name="name" type="string" required="no" default="tmp">
// 	<cfquery datasource="#dsn#" name="#name#">
// 	#PreserveSingleQuotes(queryString)#	
// 	</cfquery>
// 	<cfreturn Evaluate(name)>
// </cffunction>
	
	/**
	* Query known to return one row (as struct).
	*/
	function singleton(required string sql, string dsn=This.dsn) {
		var result = query(sql, dsn);
		return record2Struct(result, 1);
	}


	/**
	* Inserts a record into the database
	*/
	public any function insertr(required string table, required struct args, string dsn=This.dsn) {
		var sql = "INSERT INTO "&table&" (";
		var argArray = structKeyArray(args);
		var arglen = arrayLen(argArray);
		for (var i = 1; i <= arglen; i++) {
			var arg = argArray[i];
			sql &= arg;
			if (i < arglen) sql &= ', ';
		}
		sql &= ") VALUES(";
		//// values
		for (var i = 1; i <= arglen; i++) {
			var arg = argArray[i];
			sql &= ':'&arg;
			if (i < arglen) sql &= ', ';
		}
		sql &= ')';
		var values = getValues(table, args, argArray); 
		return safeQuery(sql, values, dsn);
	}

	/**
	* Generates an argArray ready for safeQuery()
	* argArray passed in simply indicates the arg sequence
	*/
	private array function getValues(required string table, required struct args, required array argArray, string dsn=This.dsn) {
		var md = This.getDSObject(table, dsn);
		var values = [];
		for (var i = 1; i <= arrayLen(argArray); i++) {
			var arg = argArray[i];
			var params = {
				name=arg,
				value = args[arg],
				type = md[arg].type
			};
			arrayAppend(values, params);
		}
		return values;
	}

	/**
	* Updates a table
	*/
	function update(required string table, required struct args, required string where, string dsn=This.dsn) {
		var sql = "UPDATE "&table&" SET ";
		var argArray = structKeyArray(args);
		var arrlen = arrayLen(argArray);
		for (var i = 1; i <= arrlen; i++) {
			var arg = argArray[i];
			sql &= arg&'=:'&arg;
			if (i < arrlen) sql &= ', ';
		}
		if (where != '') {
			sql &= " WHERE "&where;
		}
		var values = getValues(table, args, argArray, dsn);
		return safeQuery(sql, values, dsn);
	}

	

	/**
	* Delete from a db table
	*/
	public any function delete(required string table, required string where, string dsn=This.dsn) {
		var sql = "DELETE FROM "&table;
		if (where != '') sql &= ' WHERE '&where;
		return query(sql, [], dsn);
	}

	/**
	* Inserts record with auto-id
	* @return new id
	*/
	public any function insertid(required string table, required struct args, required string id, string dsn=This.dsn) {
		transaction {
			insertr(table, args, dsn);
			var sql = "SELECT MAX("&id&") AS mx FROM "&table;
			var result = query(sql);
		}
		return result.mx[1];
	}
	
	/**
	* Given a query object and a row number, returns that row as a struct
	*/
	public struct function record2struct(required query recordset, required numeric index)  {
		var i = 0; var col = "";
		var data = {};
		if (ArrayLen(Arguments) ge 3) data = Arguments[3];
		for (i = 1; i le ListLen(recordset.columnList); i++) {
			col = ListGetAt(recordset.columnList, i);
			data[col] = recordset[col][index];
		}
		return data;								 
	}    
	/** 
	 * Takes a coldfusion query object and returns an array of arrays
	 */
	public array function query2array(required query recordset) {
		var arr = [];
		var columns = recordset.getColumnNames();
		for (var i = 1; i le recordset.recordCount; i++) {
			var row = [];
			for (var j = 1; j le ArrayLen(columns); j++) {
				var column = columns[j];
				ArrayAppend(row, recordset[column][i]);	
			}
			ArrayAppend(arr, row);
		}
		return arr;
	}	
}