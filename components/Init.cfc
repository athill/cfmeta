/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/components/Init.cfc
* @author  
* @description
*
*/

component output="false" displayname=""  {

	Variables.components = ListToArray("jsModule,utils,Defaults,html,db");
	function init() {
		
		////Instance vars
		Request.isDEV = FindNoCase("dev", CGI.SERVER_NAME);
		Request.isTST = FindNoCase("test", CGI.SERVER_NAME) or FindNoCase("tst", CGI.SERVER_NAME);
		Request.isPRD = not Request.isDEV and not Request.isTST;	
		/////Indicates if a script is called by the CF scheduler		
		Request.isScheduled = FindNoCase("CFSCHEDULE",CGI.HTTP_USER_AGENT) 
			and (Find("10.",CGI.REMOTE_ADDR)==1 or Find("198.162.",CGI.REMOTE_ADDR)==1);		
				
		////////////////////
		////Databse vars
		///////////////////
		Request.appDsn = "mysql";

		//////////////////////////////
		////Initialize components
		///////////////////////////////////
		Request.site.webmaster = "";
		Request.site.filename = "";
		var i = components.iterator();
		while (i.hasNext()) {
			comp = i.next();
			//WriteOutput(comp & "<br />");
			if (not StructKeyExists(Request, comp)) {
				// writedump(comp);
				Request[comp]= CreateObject("component", "global.cfc.#comp#");
			}
		}
		Request.h = Request.html;
		////Template		
		Request.template = CreateObject("component", "components.template.base");		

		
		//Initialize menu
		if (!StructKeyExists(Request.site, "xmlFile")) {
			Request.site.xmlFile = "menu.xml";
		}
		xml = FileRead(ExpandPath(Request.webroot&'/'&Request.site.xmlFile));
		vals = XmlParse(xml);
		Request.site.xml = vals.XmlRoot;
		menuStart = CGI.SCRIPT_NAME;
		Request.menuStart = REReplace(menuStart, "index\.cfm$", "");
		Request.menu = CreateObject("component", "global.cfc.menu");
		Request.menu.init(Request.site.xml, Request.menuStart);		
		
	}
}