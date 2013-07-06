/**
*
* @file  /Y/components/template/new.cfc
* @author  
* @description
*
*/

component output="false" displayname=""   {

This.bodyAtts = 'class="iu-ses"';
	This.stylesheets = "/css/site.css";
	Variables.h = Request.html;
	Variables.base = "";

	function init(base) {
		Variables.base = base;
	}

	function header() {
		openPage();
		openContainer();
		h.oheader('id="header"');
		h.h1('Metaprogramming in ColdFusion');
		h.cheader("header");
		////Usability Links
		base.usabilityLinks();
		openLayout();
	}

	function openPage() {
		base.banners();
		h.odiv('id="wrapper"');

	}

	function openContainer() {
		h.odiv('id="container"');		
	}

	function closeContainer() {
		h.cdiv('/container');	
	}

	function closePage() {
		h.cdiv('/wrapper'); 
		h.chtml();	
	}


	function openLayout() {
		h.odiv('id="layout"');
		//////Sidebar
		if (Request.site.hasSidebar) {
			h.odiv('id="column1"');
			// h.odiv('id="nav_vertical"');//class="subnav"
			base.sidebar();
		
		//h.cdiv(); ////nav_vertical
			h.cdiv(); ////close column1
			if (Request.site.hasRightSidebar) {
				h.odiv('id="column2"');
			} else {
				h.odiv('id="column23"');
			}
		//Request.utils.include(Request.webroot&"/includes/openSidebarTable.cfm");
		} 
		h.odiv('id="content"');
		h.tnl('<a name="content"></a>');
		h.h2(Request.site.pageTitle);
	}

	function closeLayout() {
		h.cdiv('/content');	////close content
		if (Request.site.hasSidebar) {
			h.cdiv('/column2');
			if (Request.site.hasRightSidebar) {
				h.odiv('id="column3"');
				base.rightSidebar();
				h.cdiv();	
			}
		}
		h.cdiv('/layout');
	}

	///////////////////
	////Footer
	////////////////
	function footer() {
		closeLayout();
		closeContainer();
		h.ofooter('id="footer"');	
		h.odiv('id="copyright"');
		h.startBuffer();
		h.a('http://andyhill.us', 'Andy Hill', 'target="_blank"');
		var link = h.endBuffer();
		h.tnl('Copyright &copy; '&Year(Now())&' '&link);
		h.cdiv();	////close copyright
		h.cfooter('/footer');	////close footer
		closePage();
	}
}