<cfcomponent>
<cfscript>
This.bodyAtts = '';
This.stylesheets = "/css/default.css";
Variables.h = Request.html;
Variables.base = "";

Request.site.hasPopup = false;
Request.site.hasTree = false;
Request.site.hasPageTitle = false;

function init(base) {
	Variables.base = base;
}

function header() {	
} 

function footer() {
	h.chtml();
}


</cfscript>
</cfcomponent>