/**
* Sets defaults for page rendering
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/Defaults.cfc
* @author  andy hill
* @description Default setting for site
*
*/

component output="false" displayname=""  {

  Variables.deptname = "University Student Services and Systems";

  site = {
    deptname = deptname,
    deptabbr = "USSS",
    template = "default",
    directory = GetDirectoryFromPath(GetBaseTemplatePath()),
    filename = GetFileFromPath(GetBaseTemplatePath()),					//Filename of current page

    ////Used to match directories against XML entries
    tempFullDir = Replace(CGI.SCRIPT_NAME, "index.cfm", ""),	
    ////Depth from parent directory
    subDirCount = Request.utils.FindOccurrences(ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/"), "/"),
    //Used to match directories against XML entries
    tempFullDir = Replace(CGI.SCRIPT_NAME, "index.cfm", ""),  
    site = "http://"&CGI.HTTP_HOST,
    sendTestEmailsToUser = true,				////If true on DEV and TST will send emails to auth user, rather than recipients	
    //Redirect to https:// when appropriate?
    sslOn = true,
    webmaster = "athill",
    hasSidebar = true,						//Whether there is an alternative sidebar (like on the main page)								
    hasRightSidebar = false,
    hasTree = true,							//Whether there is a tree menu
    treeXml = "",								////Alternate XML for tree menu
    subHeader = "",						////subtitle under header
    parseAll = false,						//parse entire tree (used only for sitemap)
    security = "",							//Can be set for various security groups
    hasAccess = true,						//Access to a given page (used in security.cfm and header.cfm)
    rssFile = "",							//path to rss file, if applicable
    retirePage = false,						////Using the redirect component to retire a page
    retirePageParams = {redirect="", expire=Now(), timeout=10},					////Params for redirect component
    hasHeader = true,						//Whether to show the header
    headerExtra = "",
    onload = "",
    hasFooter = true,						//Whether to show the footer
    widePage = false,						//Render content full screen width
    meta = {
    	'description' = "Metaprogramming in ColdFusion",
    	'keywords' = "ColdFusion, Metaprogramming",
    	'author' = "Andy Hill",
    	'copyright' = Year(Now()) & ', Andy Hill http://andyhill.us',
    	'icon'='',
    	'compatible'='IE=edge,chrome=1',
    	'viewport'='width=device-width'
    },
    webmaster = "athill@indiana.edu",
    pageTitle = "",							//Displays in titlebar and at top of page content
    hasPageTitle = true,					//Whether pageTitle will show at top of page content
    headerImage = "sesheader.jpg",				//image at top of page
    showPath = false,						//Whether to show the directory path
    email = "ses-tech@exchange.indiana.edu", //Standard email mail is sent from
    techEmail = "sestech@indiana.edu",
    forbiddenMessage = "",					//Message to display when a user is denied access to an area of a site
    homeFile = "/main.cfm",					//Where the "home" file will link to.
    baseDir = "",							//Directory where links begin
    treeLevel = 1,							//Level of XML file to start parsing tree
    editor = "tinymce",					////ckeditor|tinymce
    validIuEmail = "^\w+([\.-]?\w+)*@(.*\.)?(indiana|iupui|iun|ius|iuk|ipfw|iusb|iupuc|purdue|iue|iu)\.edu$",
    combineScripts = false,
    sidepadding = false,
    hasMobile = false,
    features = {
    	header = true,
    	footer = true,
    	sidebar = true,
    	rightSideBar = false,
    	tree = true
    }
  };

  StructAppend(site, Request.jsModule.getDefaults());
  site.hasTree = true;							//Whether there is a tree menu
  //writedump(Request.site);
  //hasPopup = true,						////top tab menu




  //string to go back up to parent directory
  site.secureProtocol = IIf(site.sslOn, DE("https"), DE("http"));
    //WriteOutput(secureProtocol),
  site.currentSite = site.secureProtocol & "://" & CGI.HTTP_HOST;
  if (site.subDirCount ge 2) site.treeLevel = 2;

  ////Make global
  Request.site = site;

  //writedump(Request.site);

  /**
  * Additional documentation, setting of request.site
  */
  public void function __docs() {
    writedump(Request.site);
  }
}