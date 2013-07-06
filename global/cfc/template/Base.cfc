/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/template/Base.cfc
* @author  andy hill
* @description Template engine. 
*
*/

component output="false" displayname=""  {
	Variables.h = Request.html;
	Variables.template = "grayBg";
	Variables.templateText = Variables.template;
	This.home = Request.webroot&"/";
	Request.retirePage = "";
	Variables.templateLocation = '';
	
	function init(template='default') {
		if (ArrayLen(Arguments) ge 1) Variables.template = Arguments[1];
		Variables.templateText = template;
		variables.template = CreateObject("component", templateLocation&template);
		variables.template.init(this);
		if (StructKeyExists(Request.site, "templateStylesheets")) {
			variables.template.stylesheets = Request.site.templateStylesheets;
		}
	}
	
	
	function head() {
		if (StructKeyExists(template, "head")) {
			template.head();
			return;	
		}
		h.strictIndent = true;
		perms = "";
		if (StructKeyExists(Session, "permissions")) perms = Session.permissions;
		Request.site.hasHeader = true;
		modFiles = Request.jsModule.getModules();
		////Scripts and styles to include
		styles = ListAppend(modFiles.styles, template.stylesheets);
		scripts = modFiles.scripts;
		
		includes = Request.utils.listUnique(ListAppend(styles, scripts));
		//titleAndPath = Request.menu.getPageTitleAndPath();
		////Page title
		if (not StructKeyExists(Request.site, "pageTitle")) {
			Request.site.pageTitle = "";
		}
		if (Request.site.pageTitle eq "") {
			Request.site.pageTitle = Request.menu.getPageTitle();
			//SES.pageTitle = ListFirst(titleAndPath, "|");
		}

		title = "CF Metaprogramming Demo - " & 
			Replace(Request.site.pageTitle, "<br />", " ", "ALL");
		////Initialize HTML
		h.ohtml(title, includes, Request.site.meta);
		////////Extra Header Info
		h.wo(Request.site.headerExtra);
		if (Request.site.retirePage) {
			Request.retirePage = new global.cfc.RetirePage(argumentCollection=Request.site.retirePageParams);
			if (Request.site.pageTitle == "") {
				Request.site.pageTitle = "This Page Has Been Moved";	
			} else {
				Request.site.pageTitle = 'The "' & Request.site.pageTitle & '" Page Has Been Moved';
			}
		}
		h.body(template.bodyAtts);
	}	
	
	function header() {
		template.header();
		if (Request.site.security neq "") {
			Request.sec.checkAccess();
		}
		//////Access denied
		if (not Request.site.hasAccess and CGI.HTTP_HOST neq CGI.REMOTE_ADDR) {
			if (Request.site.forbiddenMessage eq "") {
				h.h3("You do not appear to have access to this page");
				//// TODO: check query string for refreshAccess, add it if it isn't there
				h.tnl('If you feel this is in error, try ' & 
					'<a href="?refreshAccess=true">refreshing your session</a>.');
			} else {
				h.h3(Request.site.forbiddenMessage, 'align="center"');
			}
			h.br(2);
			abort;
			
		}			
	}
	
	function banners() {
		////Identify instnace on DEV nad TST
		if (Request.isDev or Request.isTST) {
			var instance = (Request.isDev) ? "Development" :  "Test";
			h.div("Alert: This is a non production environment ("&instance&")", 'id="instanceId"');
		}		
	}
	
	function usabilityLinks() {
		////Hidden usability links
		h.comment("Usability Links");
		h.a("##content", "Skip to Main content", 'class="hide"');
		if (Request.site.hasTree) {
			h.a("##subMenu", "Skip to sub-menu", 'class="hide"');
		}		
	}
	
	function sidebar() {
		
		Request.menu.displayTreeMenu();
	}
	
	function submenu(links) {
		var testObj = (ArrayLen(Arguments) ge 2) ? Arguments[2] : {};		
		for (var i = 1; i le ArrayLen(links); i++) {
			var link = links[i];
			if (!IsStruct(link)) {
				var tmp = {};
				tmp.href = ListFirst(link, "|");
				tmp.display = (ListLen(link, "|") ge 2) ? ListGetAt(link, 2, "|") : tmp.href;
				link = tmp;
			}
			var href = link.href;
			var qargs = {};
			if (Find("?", href)) {
				href = ListFirst(link.href, "?");
				qargs = Request.utils.querystringToStruct(ListRest(link.href, "?"));	
			}
			var active = false;
				////absolute path
			if ((Left(href, 1) == "/" && Request.webroot&href == CGI.SCRIPT_NAME) ||
						////Local link
						(href == Request.site.filename)) {
				////Check for query
				active = true;
				for (var arg in qargs) {
					if (!StructKeyExists(URL, arg) or URL[arg] != qargs[arg]) {
						active = false;
						break;	
					}
				}
				////custom function
				if (!active && StructKeyExists(testObj, "test")) {
					 active = testObj.test(href);
				}
				if (active) {
					if (!StructKeyExists(link, "atts")) {
						link.atts = '';	
					}
					link.atts = h.addClass(link.atts, 'active');
				}
			}
			links[i] = link;
		}
//		writedump(links);
		h.linkList(links, 'class="submenu"');
	}
	
	function rightSidebar() {
		if (IsStruct(template) && StructKeyExists(template, "footer")) {
			template.rightSidebar();	
		}
	}
	
	function footer() {
		if (IsStruct(template) && StructKeyExists(template, "footer")) {
			template.footer();	
		}
	}
}