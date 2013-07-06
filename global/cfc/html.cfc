/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/html.cfc
* @author  andy hill
* @description Generates html
*
*/

component output="false" displayname="Html" extends="Xml"  {

	This.jsInline = false;
	Variables.js = [];
	This.mixin('global.cfc.mixins.html.Table');

	This.emptyTags = "area,base,br,col,hr,img,input,keygen,link,meta,param,source,track";
	This.nonemptyTags = "a,abbr,address,article,aside,audio,b,bdi,bdo,blockquote,body,canvas,caption,cite,code,colgroup," &
			"command,datalist,dd,del,details,dfn,div,dl,dt,em,embed,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6," &
			"head,header,hgroup,html,i,iframe,ins,kbd,label,legend,li,map,mark,menu,meter,nav,noscript,object,ol,optgroup,option," & 
			"output,p,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,span,strong,style,sub,summary,sup,table,tbody," &
			"td,textarea,tfoot,th,thead,time,title,tr,u,ul,var,video,wbr";
	This.indentTags = "datalist,div,dl,fieldset,footer,header,nav,ol,section,select,tr,ul";
	


	function OnMissingMethod(required string name, required struct args) {
		var command = Left(name, 1);
		var tag = Mid(name, 2, Len(name) - 1);
		////empty tag
		if (ListFindNoCase(This.emptyTags, name) && name != 'col') {
			var atts = ArrayLen(args) >= 1 ? args[1] : '';
			Super.tag(name, atts);
		////input tag --- requires Form mixin
		} else if (StructKeyExists(This, 'inputTags') && ListFindNoCase(This.inputTags, name)) {
			var fieldname = args[1];
			var value = ArrayLen(args) >= 2 ? args[2] : '';
			var atts = ArrayLen(args) >= 3 ? args[3] : '';
			if (name == 'date') {
				atts = addClass(fixAtts(atts), "datepicker");
				if (not Find("size=", atts)) atts &= ' size="15"';
			}
			var pos = FindNoCase('in', name);
			if (pos == 1) name = Replace(name, 'in', '', 1);
			This.input(name, fieldname, value, atts);
		////open/close tag
		} else if (ListFindNoCase(This.nonemptyTags, name)) {
			var content = args[1];
			var atts = (ArrayLen(args) >= 2) ? args[2] : '';
			var inline = !REFind('\n', content);
			Super.tag(name, atts, content, inline, false);
		////open tag
		} else if (command == 'o' && ListFindNoCase(This.nonemptyTags, tag)) {
			var atts = ArrayLen(args) >= 1 ? args[1] : '';
			var indent = ListFindNoCase(This.indentTags, tag);
			Super.otag(tag, atts, indent);
		////close tag
		} else if (command == 'c' && ListFindNoCase(This.nonemptyTags, tag)) {
			var comment = ArrayLen(args) >= 1 ? args[1] : '';
			var indent = ListFindNoCase(This.indentTags, tag);
			Super.ctag(tag, indent, comment);
		////close/open tag
		} else if (Left(name, 2) == 'co' && ListFindNoCase(This.nonemptyTags, Mid(name, 3, Len(name) - 2))) {
			var tag = Mid(name, 3, Len(name) - 2);
			var atts = ArrayLen(args) >= 1 ? args[1] : '';
			Super.ctag(tag);
			Super.otag(tag, atts);
		} else {
			Super.OnMissingMethod(name, args);	
		}
	}

	/**
	* http://corfield.org/blog/index.cfm/do/blog.entry/entry/Mixins
	* type is the path to the mixin cfc
	*/
	public void function mixin(required string type) {
	 	var target = createObject("component",arguments.type);
		structAppend(this,target);
		structAppend(variables,target);
		if (structKeyExists(target, 'getVariables')) {
			structAppend(variables, target.getVariables());
		}
	}

	
	/**
	 * Opens an XHTML compliant header
	 */ 
	public void function ohtml(required string title, string includes='', struct options={}) {
		var js = ""; var css = "";
		var i = 0;
		var defaults = {
			'keywords'='',
			'compatible'='',
			'icon'='',
			'description'='',
			'author'='',
			'copyright'='',
			'charset'='utf-8',
			'viewport'=''
		};
		options = This.extend(defaults, options);
		/*
		tnl('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" ' & 
			'"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
		tnl('<html xmlns="http://www.w3.org/1999/xhtml">');
		tnl('<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />');
		*/
		tnl('<!DOCTYPE html>');
		otag('html');
		otag('head');
		tag('meta', 'charset="'&options.charset&'"');
		tag('meta', 'http-equiv="X-UA-Compatible" content="'&options.compatible&'"');
		var metas = ['keywords', 'description', 'author', 'copyright', 'viewport'];
		for (var i = 1; i le ArrayLen(metas); i++) {
			var meta = metas[i];
			if (options[meta] != '') {
				tag('meta', 'name="'&meta&'" content="'&options[meta]&'"');
			}
		}
		if (options.icon != '') {	
			tnl('<link rel="icon" href="'&options.icon&'" />');
			tnl('<link rel="shortcut icon" href="'&options.icon&'" />');
		}
		tnl("<title>#title#</title>");
		script('var webroot="#Request.scriptroot#";');
		if (Request.site.combineScripts) {
		  for (i = 1; i le ListLen(includes); i++) {
			  inc = ListGetAt(includes, i);
			  if (REFind("\.css$", script)) css = ListAppend(css, inc);
			  else js = ListAppend(js, inc);
		  }
		  combiner = "/scripts/combine.cfm";
		  if (StructKeyExists(CGI, "https") && CGI.https eq "on") combiner = "/scripts/ssl/combine.cfm";
		  
		  tnl('<link rel="stylesheet" type="text/css" href="#combiner#?type=css&files=#css#" />');
		  scriptfile(combiner & "?files=" & js);
		} else {
			var scripts = [];
			var styles = [];
		  for (var i = 1; i le ListLen(includes); i++) {
			  var inc = ListGetAt(includes, i);
			  if (REFind("\.css$", inc))
				  arrayAppend(styles, inc);
				  //tnl('<link rel="stylesheet" type="text/css" href="#script#" />');
			  else 
				  arrayAppend(scripts, inc);
		  }
		}
		for (var i = 1; i le arrayLen(styles); i++) {
			stylesheet(styles[i]);
		}
		scriptfile('/global/js/modernizr.js', true);
		for (var i = 1; i le arrayLen(scripts); i++) {
			scriptfile(scripts[i]);
		}		
		
	}
	
	/**
	 * Ends the header, starts the body
	 */
	public void function body(any atts='') {
		ctag('head');
		otag('body', atts);
	}
	
	/**
	 * Closes body and HTML tags
	 */
	public void function chtml() {
		if (!This.jsInline) {
			for (var i = 1; i le ArrayLen(Variables.js); i++) {
				var js = Variables.js[i];
				if (js.type == 'file') {
					This.scriptfile(js.value, true);
				} else {
					if (i == 1 || Variables.js[i-1].type == 'file') {
						This.oscript(true);	
					}
					This.tnl(js.value);
					if (i == arrayLen(Variables.js) || Variables.js[i+1].type == 'file') {
						This.cscript(true);	
					}
				}
			}
		}
		ctag('body');
		ctag('html');
	}


	/***
	 * Geerates an HTML comment
	 */	 
	  public void function comment(required string content) {
	 	tnl("<!-- #content# -->");
	 }

	/**
	 * creates (a) br tag(s)
	 */
	public void function br(numeric count=1) {
		for (var i = 1; i le count; i++) {
			tnl("<br />");
		}
	}		 
	 
	/**
	 * Creates an img tag
	 */
	public void function img(required string src, required string alt, any atts='') {
		if (Left(src, 1) eq "/") src = Request.scriptroot & src;
		atts = 'src="#src#" alt="#alt#"' & fixAtts(atts);
		tag('img', atts);
	}
	/**
	 * Creates an anchor tag
	 */
	public void function a(required string href, string display='', string atts='') {
		if (display == '') display=href;
		if (Left(href, 1) eq "/") href = Request.webroot & href;
		atts = 'href="#href#"' & fixAtts(atts);
		tag('a', atts, display, true);
//		tnl('<a href="#href#"#atts#>#display#</a>');
	}

	/**
 	 * Created by Andy Hill: 11/2005 
	 * Converts email to ASCII representations to discourage harvesting
	 * @param addr		string	default="SES-Tech@indiana.edu"	Email address to obfuscate
	 * @param display	string	default=addr 					Text to be displayed on screen (also obfuscated if the same as email)
	 **/
	public void function email(required string addr, string display='') {
		var email = "";
		for (var i = 1; i le Len(addr); i++) {
			email = email & "&##" & Asc(Mid(addr, i, 1)) & ";";
		}
		if (display == '') display = email;
		// this.tbr(display);
		var mailto2 = "";
		var mailto = "mailto:";
		for (var i = 1; i le Len(mailto); i++) {
			mailto2 = mailto2 & "&##" & Asc(Mid(mailto, i, 1)) & ";";
		}
		a("#mailto2##email#", display);
	}


	/***
	 * Generates a script tag with an src attribute
	 */
	 public void function scriptfile(required src, boolean inline=This.jsInline) {
		 var i = 0; var script = "";
		 if (isArray(src)) {
			 src = ArrayToList(src);
		 }
		 for (i = 1; i le ListLen(src); i++) {
			 script = ListGetAt(src, i);
			if (Left(script, 1) eq "/" && !REFind('^'&Request.scriptroot, script)) {
				script = Request.scriptroot & script;
			}
			if (inline) {
				tnl('<script src="#script#"></script>');
				
			} else {
		 		ArrayAppend(Variables.js, { type='file', value=script });
			}
		 }
	 }

	/***
	 * Opens a script tag
	 */
	 public void function oscript(boolean inline=This.jsInline) {
		if (inline) {
			otag('script');
		 	tnl("//<![CDATA[");			
		} else {
			This.startBuffer();
		}
	 }

	/***
	 * Closes a script tag
	 */
	 public void function cscript(boolean inline=This.jsInline) {
	 	if (inline) {
			tnl("//]]>");
			ctag('script');			
		} else {
			ArrayAppend(Variables.js, { type='script', value=This.endBuffer() });
		}
	 }

	/***
	 * Encloses content in script tags
	 */	 
	 public void function script(required string content, boolean inline=This.jsInline) {
	 	if (inline) {
			oscript(inline);
			tnl(content);
			cscript(inline);
		} else {
			ArrayAppend(Variables.js, { type='script', value=content });
		}
	 }
	 
	/***
	 * generates a JavaScript alert
	 */	 
	  public void function alert(required string content) {
	 	script('alert("#content#");');
	 }

	/**
	 * Link to open window via JS
	 * @param	href	string	required		uri
	 * @param	display	string	default=href	what to display
	 * @param	atts	string	default=""		attributes to pass to anchor tag
	 */
	function jsWin(href) {
		if (ArrayLen(Arguments) ge 2) display = Arguments[2];
		else display = href;
		if (ArrayLen(Arguments) ge 3) atts = fixAtts(Arguments[3]);
		else atts = "";
		a(href, display, 'onclick="openWindow(''#href#''); return false;"#atts#');
	}	 
	 
	 
	/**
	 * opens a style tag
	 */	 
	 public void function ostyle() {
		otag('style', {type='text/css'});
	 	tnl("<!--");
	 	
	 }
	/**
	 * Generates style declarations based on an array of {match}->{rules}
	 */	 
	 public void function style(required array styles) {
		ostyle();
		for (var i = 1; i le ArrayLen(styles); i++) {
			tnl(styles[i]);
		}
		cstyle(); 
	 }
	/***
	 * closes a style tag
	 */	 
	 public void function cstyle() {
	 	tnl("-->");
		ctag('style');
	 }

	/***
	 * Generates stylesheet link tag(s) 
	 */	 
	  public void function stylesheet(required string sheets) {
		var i = 0; var sheet = "";
		for (i = 1; i le ListLen(sheets); i++) {
			sheet = ListGetAt(sheets, i);
			if (Left(sheet, 1) eq "/") sheet = Request.scriptroot & sheet;
			tnl('<link rel="stylesheet" href="#sheet#" />');	
		}
	 }
		
	/**
	 * Embeds a Flash applet
	 */
	public void function flashApplet(required string applet, required numeric width, required numeric height, required string bgcolor) {
		otag('object', 'type="application/x-shockwave-flash" data="#applet#" ' & 				
				'width="#width#" height="#height#"', true);
		tag('param', ' name="movie" value="#applet#"');
		tag('param', 'name="quality" value="high"');
		tag('param', 'name="quality" value="high"');
		tag('param', 'name="scale" value="noscale"');
		tag('param', 'name="bgcolor" value="#bgcolor#"');
		ctag('object', true);
	}	

	/**
	 * Replace quotes with XHTML escape equivelents
	 */
	public string function escapeQuotes(required string str) {
		str = Replace(str, '"', "&quot;", "ALL");
		str = Replace(str, "'", "&apos;", "ALL");
		return str;
	}

	/*
	 * Returns escaped quotes to quotes
	 */
	public string function unescapeQuotes(required string str) {
		str = Replace(str, "&quot;", '"', "ALL");
		str = Replace(str, "&apos;", "'", "ALL");
		str = Replace(str, "&##39;", "'", "ALL");
		return str;
	}


	entities = {
		"&iquest;" = chr(191),
		"&lsquo;" = chr(8216),
		"&ldquo;" = chr(8220),
		"&rdquo;" = chr(8221),
		"&rsquo;" = chr(8217),
		"&quot;" = chr(34),
		"&##39;" = chr(39),
		"&amp;" = chr(38),
		"&gt;" = chr(62),
		"&lt;" = chr(60),
		"&ndash;" = chr(8211),
		"&mdash;" = chr(8212),
		"&apos;" = "'"
	};
	/**
	 * Characters to entities
	 */
	public string function entify(required string str) {
		for (var entity in entities) {
			str = Replace(str, entities2[entity], entity, "ALL");
		}
		return str;
	}

	/**
	 * Entities to characters
	 */
	public string function deEntify(required string str) {
		for (var entity in entities) {
			str = Replace(str, entity, entities[entity], "ALL");
		}
		return str;
	}


	/**
	 * Strips all HTML from a string
	 */
	public string function stripHtml(required string str) {
		return REReplace(str, "<[^<]+>", "", "ALL");
	}


	/**
	 * combines multiple class attributes into one
	 */
	public string function combineClassAtts(required string atts) {
		var re = '\s?class="[^"]+"';
		var matches = REMatch(re, atts);
		var classes = "";
		for (var i = 1; i le ArrayLen(matches); i++) {
			classes = ListAppend(classes, REReplace(matches[i], '\s?class="([^"]+)"', "\1"), " ");
		}
		atts = REReplace(atts, re, "", "ALL");
		classes = Request.utils.listUnique(classes, " "); 
		return atts & ' class="'&classes&'"';
	}
	/**
	 * Verifies an argument is passed in and returns it
	 */
	public any function reqArg(required string arg, required any Arguments) {
		if (not StructKeyExists(Arguments, arg)) {
			Throw(message="Required argument '#arg#' missing.");	
		}
		return Arguments[arg];
	}

	/**
	 * Overrides struct defaults with options
	 */
	public struct function extend(required struct defaults, required struct options) {
		for (opt in defaults) {
			if (StructKeyExists(options, opt)) {
				defaults[opt] = options[opt];	
			}
		}
		return defaults;
	}
	/**
	 * If a class attribute already exists in atts, adds class to it; otherwise, creates a class attribute with class
	 */
	public string function addClass(required string atts, required string class) {
		if (!Find("class=", atts)) {
			if (Len(atts)) return atts & ' class="'&class&'"';	
			else return atts & 'class="'&class&'"';	
		} else {
			var regex = '\s?class="([^"]+)"';
			var classes = REReplaceNoCase(atts, ".*"&regex&".*", "\1");
			var pre = REReplaceNoCase(atts, "(.*)"&regex&".*", "\1");
			var post = REReplaceNoCase(atts, ".*"&regex&"(.*)", "\2");
			return pre & ' class="'&classes & " "& class & '"' & post;
		}
	}

	/**
	 *	Adds an attribute, attr to attrs
	 */
	public string function addAttr(required string attrs, required string attr) {
		return (attrs == "") ? attr : attrs & ' ' & attr;	
	}

	/**
	 * Creates an icon from the /global/img/icons/Crystal/ directory
	 */
	function icon(required string name, string atts='', numeric size=16) {
		var title = UCase(Mid(name, 1, 1)) & Mid(name, 2, Len(name)); 
		if (REFind(" title=", atts)) {
			title = REReplace(atts, 'title="([^"]+)"', "\1");
		} else {
			atts &= ' title="#title#"';
		}
		img("/global/img/icons/Crystal/#name#/png/#size#.png", title, atts);
	}


	/**
	 * force a string to wrap if too long by inserting zero-width spaces every so many non-space characters
	 * returns string with spaces added
	 * 
	 * @author John Weber (wjweber@indiana.edu)
	 * 
	 * @string		REQUIRED	string to break up
	 * @maxChars 	default=20	number of non-space chars to break after
	 * @lookAhead	default=5	number of characters to look ahead to break instead at non-letter
	 * 
	 */
	public string function forceWrap(required string string, numeric maxChars=80, numeric lookAhead=5) {
		var returnString="";
		var splitChar= "&##x200B;";  // invisible space
		var preferredSplit ="[\;\:\'\""\<\>\,\.\`\!\@\##\$\%\^\&\*\(\)\_\-\+\=\{\}\[\]\|\/\?\\]";
		var inTag=false;
		var inSpecChar=false;
		var curChar="";
		var consecCount=0;
		
		if (maxChars eq 0) return string;
		
		for (var i=1; i le Len(string); i++) {
			curChar=Mid(string, i, 1);
			returnString &= curChar;
			//tbr("x"&curChar&"x");
			if (curChar eq "<") { 
				inTag=true; 
				inSpecChar = false;
			}
			if (curChar eq ">") inTag=false;
			if (!inTag and curChar eq "&") inSpecChar = true;
			//tbr("in string: " & FindNoCase(";",string,i+1) & " next 8: " & FindNoCase(";",string,i+1) - i);
			////undelimited special char
			if (inSpecChar and (FindNoCase(";",string,i+1) eq 0 or FindNoCase(";",string,i+1) - i gt 8)) inSpecChar = false;
			////delimited special char
			if (!inTag and curChar eq ";") inSpecChar = false;
			//tbr(curChar & " in tag: " & inTag & " specChar: " & inSpecChar);

			if (!inTag and !inSpecChar) {
				if (!REFindNoCase("\s",curChar)) {
					consecCount++;
				} else {
					consecCount=0;
				}
				gtmc = consecCount gt maxChars;
				if (consecCount gt maxChars and // if we are over maxChars non-space characters (and one of the following)
					(!REFindNoCase(preferredSplit,mid(string,i+1,lookAhead)) or // there's no punctuation in the next lookAhead characters
					 REFindNoCase(preferredSplit,curChar) or 	//the current character is punctuation
					 consecCount gt (maxChars + lookAhead) or 	// we've gone past lookAhead extra characters
					 lookAhead eq 0)) { 						// lookAhead is disabled
					returnString &= splitChar;
					consecCount=0;
				}	
			}
		}
		return returnString;
	}

	/**
	 * Returns defined value of field in struct or empty string
	 */
	public string function getValue(required string field, string defaultVal='', struct struct={}) {
		////If third argument provided, use that struct
		if (StructCount(struct) > 0) {
			if (StructKeyExists(Arguments[3], field)) return Arguments[3][field];
		///check both URL and Form scopes
		} else {
			if (StructKeyExists(Form, field)) return Form[field];
			if (StructKeyExists(URL, field)) return URL[field];
		}
		return defaultVal;
	}	
}