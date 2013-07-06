/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/JsModule.cfc
* @author  andy hill
* @description groups js and css files by function, allowing to include or exclude easily
*
*/

component output="false" displayname="JsModule"  {	
	
	Variables.mods = [
		{ name="mobile",
			sesVar="hasMobile",
			scripts="http://code.jquery.com/mobile/1.0a4.1/jquery.mobile-1.0a4.1.min.js",
			styles="http://code.jquery.com/mobile/1.0a4.1/jquery.mobile-1.0a4.1.min.css"
		},
		////Tree menu
		{ name="tree", 
			sesVar = "hasTree", 
			scripts = "/global/js/jquery.treeview/jquery.treeview.min.js",
			styles = "/global/js/jquery.treeview/jquery.treeview.css"
//			scripts = "/js/jquery-treeview/jquery.treeview.min.js,/js/jquery-treeview/lib/jquery.cookie.js",
//			styles = "/js/jquery-treeview/jquery.treeview.css"
		},
		////Timepicker
		{ name="timepicker", 
			sesVar = "hasTimepicker", 
			scripts = "/js/jquery.timePicker/jquery.timePicker.min.js",
			styles = "/js/jquery.timePicker/timePicker.css"
		},
		////Calendar
		{ name="ui", 
			sesVar = "hasUi", 
			scripts = "/global/js/jquery-ui-1.10.2.custom/js/jquery-ui-1.10.2.custom.min.js",
			styles = "/global/js/jquery-ui-1.10.2.custom/css/ui-darkness/jquery-ui-1.10.2.custom.min.css"
		},					
		////Slideshow
		{ name="slideshow", 
			sesVar = "hasSlideshow", 
			scripts = "/global/js/reveal.js/lib/js/head.min.js,/global/js/reveal.js/js/reveal.min.js,/global/js/reveal.js/plugin/highlight/highlight.js",
			styles = "/global/js/reveal.js/css/reveal.min.css,/global/js/reveal.js/css/theme/default.css"
				//// PDF: ,/global/js/reveal.js/css/print/pdf.css
		},	
		////Default text in form fields
		{ name="defaultValue", 
			sesVar = "hasDefaultValue", 
			scripts = "/js/jquery.defaultValue/jquery.defaultValue.js",
			styles = "/js/jquery.defaultValue/jquery.defaultValue.css"
		},					
		////Tooltip
		{ name="tooltip", 
			sesVar = "hasTooltip", 
			scripts = "/global/js/jquery-tooltip/lib/jquery.bgiframe.js,/global/js/jquery-tooltip/lib/jquery.dimensions.js,"&
				"/global/js/jquery-tooltip/jquery.tooltip.js",
			styles = "/global/js/jquery-tooltip/jquery.tooltip.css,/global/js/jquery-tooltip/demo/screen.css"
		},	
		////Facebox
		{ name="facebox", 
			sesVar = "hasFacebox", 
			scripts = "/js/facebox/facebox.js",
			styles = "/js/facebox/facebox.css"
		},		
		////Popup menu
		{ name="popup", 
			sesVar = "hasPopup", 
			scripts = "/global/js/superfish-1.4.8/js/hoverIntent.js,/js/superfish-1.4.8/js/superfish.js",
			styles = "/global/js/superfish-1.4.8/css/superfish_sp.css"
		},	
		/////WYSIWYG editor
		{ name="editor", 
			sesVar = "hasWysiwyg", 
			scripts = //Variables.editorConfig[Request.site.editor].scripts
				{ "editor" = {
						ckeditor = "/global/js/ckeditor/ckeditor.js,/js/ckeditor/adapters/jquery.js",
						tinymce = 	"/global/js/tinymce/jscripts/tiny_mce/tiny_mce.js,/global/js/tinymce.js"
					}
				}
			
		},
		{ name="queue",
			sesVar="hasQueue",
			scripts="/global/cfc/queue/queue.js",
			styles="/global/cfc/queue/queue.css"
		},
		{ name="threads",
			sesVar="hasThreads",
			scripts="/global/cfc/queue/threads.js",
			styles="/global/cfc/queue/threads.css"
		},
		{ name="validate",
			sesVar="hasValidate",
			scripts="/global/js/validate/jquery.validate.min.js",
			styles=""
		},
		{ name="cssForm",
			sesVar="hasCssForm",
			styles="/css/grid.css,/global/cfc/cssForm/cssForm.css",
			scripts="/global/cfc/cssForm/cssForm.js"
		},
		{ name="uft",
			sesVar="hasUft",
			styles="/global/css/grid.css,/global/cfc/uft/uft.css",
			scripts="/global/cfc/uft/uft.js"
		},		
		{ name="collapsible",
			sesVar="hasCollapsible",
			scripts="/global/js/collapsible.js"
		},
		{ name="savedSearch",
			sesVar="hasSavedSearch",
			styles="/global/cfc/savedSearch/savedSearch.css",
			scripts="/global/cfc/savedSearch/savedSearch.js"
		},
		{ name="notifications",
			sesVar="hasNotifications",
			scripts="/components/notifications/notifications.js",
			styles="/components/notifications/notifications.css"
		},
		{ name="grid",
			sesVar="hasGrid",
			scripts="",
			styles="/css/grid.css"
		},
		{ name="numeric",
			sesVar="hasNumeric",
			scripts="/js/jquery.numeric.js",
			styles=""
		},
		{ name="sorttable",
			sesVar="hasSorttable",
			scripts="/js/sorttable.js",
			styles=""
		}						
	];
	
	/**
	* sets all modules to false, module array to empty
	*/
	public struct function getDefaults() {
		var struct = {};
		var struct.modules = [];
		for (var module in mods) {
//			writeoutput('setting: ' & module.sesVar & '<br />');
			struct[module.sesVar] = false;	
		}
		return struct;
	}
	
	
	/**
	* generates struct of lists of script and stylesheet files based on either Global Request.site variables or a list of modules
	*/
    public struct function getModules() {
		var files = {
			styles = "",
			scripts = "/global/js/jquery-1.6.2.min.js"
			//,/js/helium/helium.js
		};
		for (var i = 1; i le ArrayLen(mods); i++) {
			m = mods[i];
			if ((StructKeyExists(Request.site, m.sesVar) and Request.site[m.sesVar]) || ArrayFindNoCase(Request.site.modules, m.name)) {
				////determine value based on global var
				if (StructKeyExists(m, "scripts")) {
					if (IsStruct(m.scripts)) {
						for (var varname in m.scripts) {
							if (StructKeyExists(Request.site, varname)) {
								var value = Request.site[varname];
								//writedump(m.scripts[varname][value]);
								files.scripts = ListAppend(files.scripts, m.scripts[varname][value]);	
							}
						}
					} else {
						files.scripts = ListAppend(files.scripts, m.scripts);
					}
				}
				if (StructKeyExists(m, "styles")) files.styles = ListAppend(files.styles, m.styles);
			}
		}
		files.scripts = ListAppend(files.scripts, "/js/site.js");
		return files;
	}


	public void function __docs() {
		writeDump(mods);
		return;
	}	
}