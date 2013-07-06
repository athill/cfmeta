/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/application.cfc
* @author  
* @description
*
*/

component output="false" displayname=""  {
	/////////////////////
	////Session info
	//////////////////////

	This.name = "cfmeta";
	This.setclientcookies = true;
	This.sessionmanagement = true;
	This.sessiontimeout = createtimespan(0,4,0,0);



	///////////////////////////////
	//// Roots for paths
	//////////////////////////////
	////Set if site is subfolder of host
	Request.webroot = "";			
	////Can be same as webroot or can be url for site with js/css/images
	Request.scriptroot = "";	
	////Deprecated: use mappings
	Request.cfcroot = ""; 							

	/////Set Roots
	if (reFindNoCase('^/'&This.name, CGI.SCRIPT_NAME)) {
		Variables.mapRoot = "C:\ColdFusion10\cfusion\wwwroot\"&This.name&"\";
		Request.webroot = '/'&This.name;
		Request.scriptroot = Request.webroot;
		////convert webroot to cfcroot
		Request.cfcroot = This.name&'.'; //// TODO 
		This.mappings['/components'] = Variables.maproot&"components\";
		This.mappings['/global'] = Variables.maproot&"global\";
	}

	Variables.page = CreateObject("component", "components.Page");


	function OnApplicationStart() {	
		return true;
	}

	function OnSessionStart() {
		return;	
	}




	function OnRequestStart(TargetPage) {


		////Initialize - Sets defaults and instantiates global objects, among other things
		var init = CreateObject("component", "components.init").init(); 
		var rtn = 	page.OnRequestStart(TargetPage);
		return rtn;
	}


	function OnRequest(TargetPage) {	
		page.OnRequest(TargetPage);
		return;	
	}

	function OnRequestEnd() {
		page.OnRequestEnd();	
	}

	function OnSessionEnd(sessionscope, applicationscope) {
	}

	function OnApplicationEnd(applicationscope) {
		
	}


	function onError(exception, eventname) {
			page.OnError(exception, eventname);
	}
}