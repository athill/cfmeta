/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/menu.cfc
* @author  
* @description
*
*/

component output="false" displayname=""  {
	This.script = "";
	Variables.h = Request.html;
	
	function init(xml, path) {
		This.xml = xml;
		This.script = ReplaceNoCase(path, "/index.cfm", "");
	}


	function getHref(atts, treePath) {
		treePath = Replace(treePath, "\", "\", "ALL");
		atts.href = Replace(atts.href, "\", "/", "ALL");
		if (StructKeyExists(atts, "redirect")) return atts.redirect;
		return treePath & atts.href;
	}

	
	function getPageTitle(xml=This.xml, level=1) {
		var title = "";
		for (var i = 1; i le ArrayLen(xml.XmlChildren); i = i + 1) {
			atts = xml.XmlChildren[i].XmlAttributes;
			//WriteOutput(ListGetAt(This.script, level, "/") & " " & ListFirst(atts.href, "/") & "<br />");
			if (ListLen(This.script, "/") ge level and ListGetAt(This.script, level, "/") eq ListFirst(atts.href, "/")) {
				display = atts.display;
				if (level lt  ListLen(This.script, "/")) title = getPageTitle(xml.XmlChildren[i], level + 1);
				else title = display;			
				if (not IsDEfined("title")) title = display;					
				title = REReplace(title, "<img[^>]+>", "");
				return Request.html.stripHtml(title);
			}
		}
		return '';
	}

	

	function displayTreeMenu(treeMenu=This.xml, treePath='', level=1) {
		var atts = (level == 1) ? 'id="tree-menu"' : '';
		h.oul(atts);
		for (var i = 1; i le arrayLen(treeMenu.xmlChildren); i++) {
			var node = treeMenu.xmlChildren[i];
			var atts = structKeyExists(node.XmlAttributes, 'target') ? 'target="'&node.XmlAttributes.target&'"' : '';
			h.startBuffer();
			var href = treePath&node.XmlAttributes.href;
			h.a(href, node.XmlAttributes.display, atts);
			var link = trim(h.endBuffer());
			if (arrayLen(node.xmlChildren) > 0) {
				h.oli();
				h.tnl(link);
				displayTreeMenu(node, href, level+1);
				h.cli();
			} else {
				h.li(link);
			}
		}
		h.cul();
	}

	function getNodeFromPath(xml, path) {
		var i = 0; var segment = ""; var results = [];
		var vals = []; 
		var lis = [];
		var webroot = Request.webroot != "" && REFind("^#Request.webroot#", path);
		var intranet = REFind("^/intranet", path);
		var cache = "";
		if (webroot) {
			path = ListRest(path, "/");	
		}
		
		if (intranet) {
			path = ListRest(path, "/");	
		}
		for (i = 1; i le ListLen(path, "/"); i++) {
			segment = ListGetAt(path, i, "/") & "/";
			if (i eq 1 and not intranet) segment = "/"&segment;
			results = XmlSearch(xml, "links[translate(@href, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', " & 
				"'abcdefghijklmnopqrstuvwxyz')='"&LCase(segment)&"']");
			if (ArrayLen(results) ge 1) xml = results[1];
			else {
				results = XmlSearch(xml, "links[translate(@href, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', " & 
					"'abcdefghijklmnopqrstuvwxyz')='"&LCase(cache & segment)&"']");					
				if (ArrayLen(results) ge 1) xml = results[1];
			}
			cache = segment;
		}
		return xml;
	}	
	
	function listMenu() {
		var path = h.reqArg("path", Arguments);				////REQUIRED string - path to list
		var node = h.reqArg("node", Arguments);				////REQUIRED XmlNode - Root XML node
		var depth = h.getValue("depth", 0, Arguments);	////Optional - depth to traverse, default: 0 (no recur); -1=total recur
		var fontpoints = h.getValue("fontpoints", -1, Arguments);	////Optional - size of font default: -1 (default size)
		var norecur = h.getValue("norecur", "", Arguments);	////Optional - List of hrefs to not recur on
		var spacing = h.getValue("spacing", 0, Arguments);	////Optional - default=0; spacing between main menu items
		var dp = 0; var atts = {}; var i = 0; var link = ""; var uri = "";
		var attrs = "";
//		h.tbr(Arguments.depth);
		if (fontpoints gt -1) attrs = 'style="font-size: #fontpoints#pt"';
		h.oul(attrs);
		for (i = 1; i le ArrayLen(node.XmlChildren); i++) {
			atts = node.XmlChildren[i].XmlAttributes;
			if (StructKeyExists(atts, "inmenu") && !atts.inmenu) {
				continue;	
			}
			if (Right(path, 1) neq "/") path &= "/";
			if (StructKeyExists(atts, "redirect")) uri = atts.redirect;
			else if (path == "/") uri = atts.href;
			else uri = path & atts.href;
			if (Left(uri, 1) eq "/" && Request.webroot != "" && !REFind("^#Request.webroot#", uri)) {
				uri = Request.webroot & uri;
			}
			hrefAtts = '';
			if (REFind("\.(doc|xls|ppt)x?$", uri) or StructKeyExists(atts, "target") and atts.target eq "_blank") {
				 hrefAtts = ' target="_blank"';
			}
			link = '<a href="'&uri&'"'&hrefAtts&'>'&atts.display&'</a>';			
			if (depth gt 0) dp = depth - 1;
			else dp = depth;
			h.oli();
			if (StructKeyExists(atts, "nolink")) h.tnl(atts.display);
			else h.tnl(link);
			if (spacing gt 0) h.br(spacing);
			if (depth neq 0 and ArrayLen(node.XmlChildren[i].XmlChildren) gt 0 and !ListFindNoCase(norecur, atts.href)) {
				listMenu(path=path & atts.href, 
						node=node.XmlChildren[i], 
						depth=dp,
						fontpoints=fontpoints,
						norecur=norecur,
						spacing=spacing
				); 	
			}
			h.cli();
		}
		h.cul();
	}	

	function list() {
		var path = h.getValue("path", "", Arguments);				////optional- path to list		
		var depth = h.getValue("depth", 0, Arguments);	////Optional - depth to traverse, default: 0 (no recur); -1=total recur
		var fontpoints = h.getValue("fontpoints", -1, Arguments);	////Optional - size of font default: -1 (default size)
		var norecur = h.getValue("norecur", "", Arguments);	////Optional - List of hrefs to not recur on
		var spacing = h.getValue("spacing", 0, Arguments);	////Optional - default=0; spacing between main menu items
		var root = This.xml;
		
		if (StructKeyExists(Arguments, "root")) {
			root = Arguments.root;	
		}
		if (path eq "") {
			path = Reverse(CGI.SCRIPT_NAME);
			path = Reverse(ListRest(path, "/"));
		}
//		h.tbr(path);
		node = getNodeFromPath(root, path);
		listMenu(path=path, 
				node=node, 
				depth=depth,
				fontpoints=fontpoints,
				norecur=norecur,
				spacing=spacing
		); 		
	}
}