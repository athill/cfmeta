/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/Xml.cfc
* @author  andy hill
* @description Generate XML
*
*/

component output="false" displayname="Xml"  {
	Variables.tabs = 0;  //// how far to indent
	Variables.buffer = [];	//// array of buffers
	Variables.bufferIndex = 0;	///// current buffer array depth
	Variables.output = true;	//// outputting (versus buffering)
	// This.strictIndent = false;	

	//String public void functions
	public void function wo(required string str) hint='Base output public void function. Outputs to screen or adds to buffer, depending on whether in buffer'{
		if (output) WriteOutput(str);
		else buffer[bufferIndex] &= str;
	}

	public void function wonl(required string str) hint='Output str followed by a newline'{
		wo(str & Chr(10));
	}

	public void function wobr(required string str) hint='Output str followed by &lt;br /&gt; and newline' {
		wo(str & "<br />" & Chr(10));
	}

	public void function tab() hint='Outputs appropriate number of tabs based on current value of tabs' {
		if (tabs lt 0) tabs = 0;
		wo(RepeatString(Chr(9), tabs));
	}

	public void function tnl(required string str) hint='Outputs tab,then str, then newline'{
		wonl(tab() & str);
	}

	public void function tbr(required string str) hint='Outputs tab, str, &lt;br /&gt;, and newline' {
		tnl(str & "<br />");
	}

	/**
	 * Simple XML tag
	 */
	public void function tag(required string type, any atts='', string content='', boolean inline=false, boolean empty=true)  {
		atts = fixAtts(atts);	
		if (content eq "") {
			if (empty) tnl("<#type##atts# />");	
			else tnl("<#type##atts#></#type#>");	
		} else {
			if (inline) {
				tnl("<#type##atts#>#content#</#type#>");
			} else {
				otag(type, atts);
				tnl(content);
				ctag(type);
			}
		}
	}
	/**
	 * Opens an XML Tag
	 */
	public void function otag(required string type, any atts='', boolean indent=false)  {
		atts = fixAtts(atts);
		tnl("<#type##atts#>");
		if (indent) tabs++;
	}

	/**
	 * Closes an XML tag
	 */
	public void function ctag(required string type, boolean indent=false, string comment='') {
		if (indent) tabs--;
		var str = '</#type#>';
		if (comment != '') str &= ' <!-- '&comment&' -->';
		tnl(str);
	}

	/**
	 * Start buffering results of public void functions rather than outputting
	 */
	 public void function startBuffer() {
		ArrayAppend(buffer, "");
		bufferIndex++;
		output = false;
	 }
	 
	 function OnMissingMethod(required string name, required struct arguments) {
	 	if (name == '__docs') {
	 		throw;
	 	}
		 var type = name;
		if (Left(name, 1) == 'o') {
			type = Right(name, Len(name) - 1);
			var atts = ArrayLen(arguments) >= 1 ? arguments[1] : '';
			otag(type, atts);
		} else if (Left(name, 1) == 'c') {
			type = Right(name, Len(name) - 1);
			ctag(type);
		} else {
			var content = ArrayLen(arguments) >= 1 ? arguments[1] : '';
			var atts = ArrayLen(arguments) >= 2 ? arguments[2] : '';	
			tag(type, content, atts);
		}
	 }
	 
	/**
	 * Stop buffering results of funcitons, return buffer
	 * @return	string	buffered HTML
	 */
	 public string function endBuffer() {
		var buf = "";
		if (bufferIndex > 0) {
			buf = buffer[bufferIndex];
			ArrayDeleteAt(buffer, bufferIndex);
			bufferIndex--;	
		}
		if (bufferIndex == 0) output = true;
		return buf;
	 }
	/**
	 *Returns value of XML tag, rather than outputting it, e.g., h.rtn('a', {href='index.cfm', display='Home'})
	 */
	public string function rtn(required string methodName, required any args) {
		 var temp = "";
	//	 Request.utils.dump(Variables);
		 if (methodName == "rtn") throw "Recursion fail in rtn() in xml";
		 else if (!StructKeyExists(Variables, methodName) || !IsCustomFunction(Variables[methodName])) {
			 startBuffer();
			 OnMissingMethod(methodName, args);
			 return Trim(endBuffer());
			// throw "Bad methodName, '#methodName#', in html.rtn()";
		 }
		 ////also guard against startBuffer(), endBuffer(), others?
		 try {
			 startBuffer();
			 temp = Variables[methodName];
			 temp(argumentCollection = args);
			 return Trim(endBuffer());
		 } catch (any e) {
			////handle error
			Request.utils.throw(e.message);
		 }
	}

	public string function fixAtts(required any atts) hint="Add space befoer attributes and/or convert attribute struct to string" {
		if (!IsStruct(atts)) {
			if (atts neq "" and Left(atts, 1) neq " ") return " " & atts;
		} else {
			var str = '';
			for (var att in atts) {
				str &= ' '&LCase(att)&'="'&atts[att]&'"';	
			}
			atts = str;
		}
		return atts;
	}
}