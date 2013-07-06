/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/components/Page.cfc
* @author  andy hill
* @description abstracts application.cfc functions
*
*/

component output="false" displayname=""  {
							
	function OnApplicationStart(maproot) {	
		var settings = {
		};
		return settings;
	}

	function OnSessionStart() {
		return;	
	}




	function OnRequestStart(TargetPage) {
		////Initialize - Sets defaults and instantiates global objects, among other things
		var i = CreateObject("component", "components.init");
		i.init();
		return true;	
	}


	function OnRequest(TargetPage) {
			
		////Localize some common objects
		h = Request.h;
		utils = Request.utils;	
		appdsn = Request.appDsn;
		////Load directorySettings page for directory
		if (FileExists(Request.site.directory & "directorySettings.cfm")) {
			httpDir = ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/");
			include "#httpDir#/directorySettings.cfm";
		}
		if (!Request.site.hasSidebar && !Request.site.hasTree) {
			Request.site.sidePadding = true;
		}
		////Handle request for spreadsheet
		if (StructKeyExists(Form, "spreadsheet")) {
			ss = CreateObject("component", "components.spreadsheet");
			ss.init("Download");    		
		////Initialize template and render header	
		} else if (Request.site.hasHeader) {
			Request.template.init(Request.site.template);
			
			Request.template.head();
	//		WriteOutput("in onrequest");
			Request.template.header();
			if (Request.site.sidePadding) {
				Request.html.odiv('id="side-padding"');	
			}
		}		
		if (Request.site.retirePage) {
			Request.retirePage.render();
		} else {
			include Arguments.TargetPage;
		}
		return;	
	}

	function OnRequestEnd() {
		if (Request.site.sidePadding && Request.site.hasFooter) {
			Request.html.cdiv('Close side padding');	
		}
		if (Request.site.hasFooter) {
			//include "#Request.webroot#/includes/footer.cfm";
			Request.template.footer();
		} else if (StructKeyExists(Request.site, "footer")) {
			h.tnl(Trim(Request.site.footer));
		}
		// if (Len(Request.err.errors)) {
		// 	Request.err.mailPageErrs();
		// }	
	}

	function OnSessionEnd(sessionscope, applicationscope) {
	}

	function OnApplicationEnd(applicationscope) {
		
	}
	/*
	function OnMissingTemplate(targetpage) {
		try{
			return true;	
		} catch (Any e) {
			return false;	
		}
	}
	*/



	function onError(exception, eventname) {
			// writedump(arguments.exception);
			switch (arguments.exception.rootcause.type) {
				////Weird bug for abort and location()
				case "coldfusion.runtime.AbortException":
					return;
					break;
				default:
						throw(object=exception);
			}
	}
}