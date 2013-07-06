/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/RetirePage.cfc
* @author  andy hill
* @description handles notification of page to be retired and redirecting to new page
*
*/

component output="false" displayname=""  {

	Variables.h = Request.html;
	Variables.redirect = "";
	Variables.expire=Now();
	Variables.timeout = 10;

	////Basic usage (In directorySettings.cfm)
	//Request.site.pageTitle = "Policies and Procedures";
	//Request.site.retirePage = true;
	//Request.site.retirePageParams = {expire=CreateDate(2012, 1, 1)};
	//Request.site.retirePageParams.redirect="https://apps.usss.iu.edu/tracker/";

	/**
	 * Initialize settings and render meta redirect tag to redirect after variable.timeout seconds
	 * @param location	string		required	location to redirect to.
	 * @param expire	datetime	required	date current page will disappear
	 * @param timeout	int			default=10	time on page before redirect
	 */
	function init() {
		Variables.redirect = h.reqArg("redirect", Arguments); 
		Variables.expire = h.reqArg("expire", Arguments);
		Variables.timeout = h.getValue("timeout", 10, Arguments);
		h.tag("meta", 'http-equiv="refresh" content="'&timeout&';url='&redirect&'"'); 
	}
	/**
	* Renders redirect message
	*/
	function render() {
		h.br(12);
		h.odiv('style="font-weight: bold; text-align: center;"');
		h.div("Please update your bookmarks.", 'style="font-size: 24pt; font-style: italic; font-weight: normal;"');
		h.div("This page has been moved to <a href="""&Variables.redirect&""">"&Variables.redirect&"</a> and will be removed "& 
			DateFormat(Variables.expire, "mm/dd/yyyy") & "<br /><br />" & 
			"This page will automatically redirect in "&Variables.timeout& " seconds.", 
			'style="font-size: 10pt"');
		h.br(12);
	}
}