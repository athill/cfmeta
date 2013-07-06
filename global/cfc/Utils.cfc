<!--- 
These are mostly wrappers for CFML tags, so that they can be called in cfscript
--->

<cfcomponent>	
    <cffunction name="fappend" hint="Append to a file">
    <cfargument name="theFile">
    <cfargument name="output">
    	<cffile action="append" file="#theFile#" output="#output#">
    </cffunction>

	<cffunction name="flush" hint="wrapper for cfflush">
		<cfflush>
	</cffunction>
    
	<cffunction name="get" hint="retrieves a url via cfhttp">
	<cfargument name="uri" type="string">
		<cfhttp url="#uri#"
		method="get" resolveurl="yes" throwonerror="yes">	
	</cfhttp>
	<cfreturn cfhttp>
	</cffunction>    
	
	<!--- These don't replace CFML tags --->
	<cfscript>
	

	/**
	* gets files modification time
	*/
	public date function filemtime(required string filePath)  {
		var fileObj = createObject("java","java.io.File").init(filePath);	
		var fileDate = createObject("java","java.util.Date").init(fileObj.lastModified());
		return fileDate;
	}
	
	
	/**
	 * Returns a list of unique values
	 */
	public string function listUnique(required string list) {
		var newList = ""; var i = 0; var item = "";
		var delim = IIf(ArrayLen(Arguments) ge 2, DE(Arguments[2]), DE(","));
		for (i = 1; i le ListLen(list, delim); i++) {
			item = ListGetAt(list, i, delim);
			if (not (ListFind(newList, item, delim))) newList = ListAppend(newList, item, delim);
		}
		return newList;
	}
	/*************************
	 * query string utils
	 ***************************/

	/**
	* remove argments from a query string
	*/
	public string function removeQueryStringArgs(required string queryString, required string argNames) {
		var i = 0;
		for (i = ListLen(queryString, "&"); i ge 1; i--) {
			arg = ListGetAt(queryString, i, "&");	
			name = ListFirst(arg, "=");
			if (ListFindNoCase(argNames, name)) {
				queryString = ListDeleteAt(queryString, i, "&");
			}
		}
		return queryString;
	}
	/**
	* Converts a struct to a query string 
	*/
	public string function structToQueryString(required struct struct) {
		var i = 0; var item = ""; var j = 0;
		var queryString = "";
		var keyList = ListSort(StructKeyList(struct), "TEXT"); 
		for (i = 1; i le ListLen(keyList); i++) {
			item = ListGetAt(keyList, i);
			for (j = 1; j le ListLen(struct[item]); j++) {
				var value = ListGetAt(struct[item], j);
				value = replace(value, '&apos;', "'");
				queryString = ListAppend(queryString, LCase(item)&"="&value, "&");	
			}
		}
		return ListSort(queryString, "TEXT");
	}
	/**
	* Converts a query string to a struct
	*/
	public struct function querystringToStruct(required string querystring) {
		var i = 0; var param = ""; var name = ""; var value = ""; var params = {};
		for (i = 1; i le ListLen(querystring, "&"); i++) {
			param = ListGetAt(querystring, i, "&");
			name = ListFirst(param, "=");
			if (ListLen(param, "=") eq 2) value = ListLast(param, "=");
			else value = "";
			if (!StructKeyExists(params, name)) params[name] = value;
			else params[name] = ListAppend(params[name], value);
		}		
		//dump(params);
		return params;
	}
	
	/**
	 * Returns list of any fields not defined
	 * @param	fields		required	List of required fields
	 * @param	scope		default="ALL"	URL|Form|ALL
	 * @return	fields, if any, not present	
	 */
	public string function reqFieldCheck(required string fields, string scope="ALL") {
		var i = 0; var j = 0;
		var undefined = "";
		if (scope eq "ALL") scope = "Form,URL";
		for (i = 1; i le ListLen(fields); i++) {
			defined = false;
			for (j = 1; j le ListLen(scope); j++) {
				if (IsDefined("#ListGetAt(scope, j)#.#ListGetAt(fields, i)#")) {
					defined = true;
					break;
				}
			}
			if (not defined) undefined = ListAppend(undefined, ListGetAt(fields, i));
		}
		return undefined;
	}
	
	/**
	 *  This function is called on all Form and URL fields
	 *  Cleans fields to prevent XSS by: 
	 *  - Replacing iframe and img tags with badTag
	 *  - Calling escape() and unescapeQuotes()
	 *  @field Form or URL field
	 */
	public string function cleanField(field, fieldname) {
		var badTags = "iframe,script";
		var fld = field; var i = 0;
		
		for (i = 1; i le ListLen(badTags); i = i + 1) {
			//WriteOutput("cleaning field before: " & field & ' #ListGetAt(badTags, i)#' & "<br />");
			field = ReplaceNoCase(field, "<#ListGetAt(badTags, i)#", "<badTag", "ALL");
			field = ReplaceNoCase(field, "</#ListGetAt(badTags, i)#", "</badTag", "ALL");
			//WriteOutput("cleaning field after: " & field & " /#ListGetAt(badTags, i)#<br />");
		}
		if (fld != field) {
			Request.mailer.type = "html";
			content = "Field: " & fieldname & "<br />";
			content &= "IP Address: " & CGI.REMOTE_ADDR & "<br />";
			if (StructKeyExists(Session, "user")) content &= "User: " & Session.user & "<br />";
			content &= "<br />";
			fld = Replace(fld, "<", "&lt;", "ALL");
			fld = Replace(fld, ">", "&gt;", "ALL");
			content &=  "<strong>Original String:</strong><br />" &fld;
			//Request.mailer.mail(Request.site.webmaster, "Possible XSS attack on #CGI.SCRIPT_NAME#", content);	
		}
		field = Request.html.escapeUnicode(field);
		field = Request.html.escapeQuotes(field);
		return field;
	}
	function cleanFields() {
		var element = "";
		if (IsDefined("Form")) for (element in Form) Form[element] = cleanField(Form[element], element);
		if (IsDefined("URL"))for (element in URL) URL[element] = cleanField(URL[element], element);
	}
	
	
	/**
	 * Remove elements in second list from first list 
	 */
	public string function listDiff(required string fullList, required string subtractList) {
		for (var i=1; i le ListLen(subtractList);i++) {
			if (ListFindNoCase(fullList, ListGetAt(subtractList,i))) {
				fullList = ListDeleteAt(fullList,ListFindNoCase(fullList, ListGetAt(subtractList,i)));
			}
		}
		return fullList;
	}	
	
	/**
	* Finds list elements in common between two lists
	*/
	public string function listIntersection(required string list1, required string list2, string delimiter1=','
			string delimiter2=',', string delimiterReturn=',') {
		var returnList = "";
		var i=0;
		var listElement="";
		for (i=1; i le ListLen(list1,delimiter1); i++) {
			listElement = ListGetAt(list1,i,delimiter1);
			if (ListFindNoCase(list2,listElement,delimiter2)) {
				returnList = ListAppend(returnList,listElement,delimiterReturn);
			}
		}
		return returnList;
	}
	/**
	* Returns TRUE if  there are any elements in common between two lists
	*/
	public boolean function listIntersects(requierd string list1, required string list2, string delimiter1=','
			string delimiter2=',') {
		if (ListLen(listIntersection(list1,list2,delimiter1,delimiter2)) gt 0) return true;
		return false;
	}
	
	/**
	* deletes value from list
	*/
	public string function listDelete(required string list, required string value) {
		var pos = ListFindNoCase(list, value);
		if (pos > 0) {
			list = ListDeleteAt(list, pos);
		}
		return list;
	}

	/**
	* remove leading or trailing whitespace or html breaks
	*/
	public string function superTrim(required string value) {
		var regexStart = "^( |\r|\n|\t|\<br\>|\<br ?\/\>|\<\/br\>|\&nbsp\;)+";	
		var regexEnd = "( |\r|\n|\t|\<br\>|\<br ?\/\>|\<\/br\>|\&nbsp\;)+$";
		
		return REReplaceNoCase(REReplaceNoCase(value,regexStart,"","ALL"),regexEnd,"","ALL");
	}
	/**
	* Displays ascii values for given strings
	*/
	public void function showAscii() {
		var paramCount =  ArrayLen(Arguments);
		var longestStringLength=0;
		var i=0; var j=0;
		var currentChar="";
		var ascVal=0;
		var lastAscVal=0;
		
		for (i=1; i le paramCount; i++) {
			longestStringLength =  max(longestStringLength,len(Arguments[i]));
		}
		
		if (paramCount neq 0) {
			Request.html.otabletr();
			for (i=1; i le longestStringLength; i++) {
				for (j=1; j le paramCount; j++) {
					currentChar=Mid(Arguments[j], i, 1 );
					ascVal=asc(currentChar);
					Request.html.td(currentChar);
					if (ascVal neq lastAscVal and j neq 1) Request.html.td(ascVal,'style="background-color:pink;"');
					else  Request.html.td(ascVal);
					lastAscVal=ascVal;
				}
				Request.html.corow();
			}
			Request.html.ctrtable();
			
		}
	}

	
	/**
	 * Creates a set of directories based on a path of the form a/b/c
	 */
	public void function createDirs(required string path) {
		path = ListToArray(path, "/");
		var dir = "";
		var i = path.iterator();
		while (i.hasNext()) {
			var node = i.next();
			dir &= "/" & node;
			if (!DirectoryExists(ExpandPath(dir))) {
				DirectoryCreate(ExpandPath(dir));	
			}
		}
	}
	
	public function timeDateFormat(datetime) {
		return TimeFormat(datetime, "hh:mm:ss tt") & " " & DateFormat(datetime, "mm/dd/yyyy");	
	}


	function getDateByWeek(numeric year, numeric week, numeric day=0) {
		var firstDayOfYear = createDate(arguments.year, 1, 1);
		var firstDayOfCalendarYear = firstDayOfYear - dayOfWeek(firstDayOfYear) + 1;
		var firstDayOfWeek = firstDayOfCalendarYear + (arguments.week - 1) * 7;
		return dateAdd("d", arguments.day, firstDayOfWeek);
	}
	
	/**
	 * Encodes CF array/struct to JSON, if a string is enclosed with [NOQUOTE] or [NQ], escapes the quotes
	 */	
	public string function encode_json(required any jsStruct) {
		if (!StructIsEmpty(jsStruct)) jsonString=SerializeJSON(jsStruct);
		var jsonString = Replace(jsonString,'"[NOQUOTE]','', "ALL");
		jsonString = Replace(jsonString,'[NOQUOTE]"','', "ALL");			
		var jsonString = Replace(jsonString,'"[NQ]','', "ALL");
		jsonString = Replace(jsonString,'[NQ]"','', "ALL");					
		return jsonString;
	}
	
	/**
	* Finds number of occurances of tsubString in  tString
	*/
	public numeric function FindOccurrences(required string tString, required string tsubString){
		if(not len(tString) OR not len(tsubString)) return 0;
		else {
			// delete all occurences of tString
			// and then calculate the number of occurences by comparing string sizes
			return ((len(tString) - len(replaceNoCase(tString, tsubString, "", "ALL"))) / len(tsubString));
		}
	}
	
	/**
	* Uppercases first letter of str
	*/
	public string function ucfirst(required string str) {
		return UCase(Left(str, 1)) & Mid(str, 2, Len(str) - 1);
	}
	
	/**
	* Takes JSON from file and deserializes
	*/
	public string function importJSON(required string filename) {
		return DeserializeJSON(FileRead(filename));	
	}

	/**
	* Writes data to filename as JSON
	*/
	public void function exportJSON(required string filename, requierd any data) {
		FileWrite(filename, SerializeJSON(data));
	}

	/**
	* Starts a timer
	*/
	public void function timerStart(required string label) {
		if (!structKeyExists(request,"timerStartInstances")) {
			request.timerStartInstances = [];
		}
		arrayAppend(request.timerStartInstances,{
			label = arguments.label,
			startTime = getTickCount()
		});
	}
	/**
	* Ends a timer. Use after timerStart()
	*/
	public void function timerEnd() {
		var label = request.timerStartInstances[arrayLen(request.timerStartInstances)].label;
		var totalTicks = getTickCount() - request.timerStartInstances[arrayLen(request.timerStartInstances)].startTime;
		var traceContent = "Timer:  [#totalTicks#ms] #label#";
		arrayDeleteAt(request.timerStartInstances,arrayLen(request.timerStartInstances));
		writeoutput(traceContent);
	}
	</cfscript>
</cfcomponent>
