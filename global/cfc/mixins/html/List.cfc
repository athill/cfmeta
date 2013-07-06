/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/mixins/html/List.cfc
* @author  
* @description List mixin for HTML.cfc
*
*/

component output="false" displayname=""  {
	Variables.test = true;

	/********************************************
	 * List Functions
	 **********************************************/
      /**
      *  Creates a list of $listType (ul or ol) with list items defined by $listItemArray
      */
  	public void function liArray(required string listType, required array listItemArray, any atts='', any liAtts='') {
		if (!ListFindNoCase("ul,ol", listType)) listType = "ul";
		 otag(listType, atts, true);
         for (var i = 1; i <= ArrayLen(listItemArray); i++) {
             This.li(listItemArray[i], liAtts);
         }
         ctag(listType, true);
     }

     function anothertest() {
     	This.tbr('anothertest'&Variables.test);
     }

     public struct function getVariables() {
     	return variables;
     }
	 
	 /**
	  * Takes an array of link structs and generates an unordered list
	  * Links take form of href,display, and optional atts
	  */
	 public void function linkList(required array links, any listAtts='') {
		 var atts = ""; var href = ""; var display = "";
		 for (var i = 1; i le ArrayLen(links); i++) {
			startBuffer();
			if (IsStruct(links[i])) {
				href = links[i].href;
				atts = (StructKeyExists(links[i], "atts")) ? links[i].atts : '';
				display = (StructKeyExists(links[i], "display")) ? links[i].display : links[i].href;
			} else {
				href = ListFirst(links[i], '|');
				display = (ListLen(links[i], '|') ge 2) ? ListGetAt(links[i], 2, '|') : href;
				atts = (ListLen(links[i], '|') ge 3) ? ListGetAt(links[i], 3, '|') : '';	
			}
			a(href, display, atts);
			links[i] = Trim(endBuffer());
		 }
		 liArray("ul", links, listAtts);
	 }
}