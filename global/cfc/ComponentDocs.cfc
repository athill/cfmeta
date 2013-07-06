/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/demo/introspection/ComponentDocs.cfc
* @author  
* @description Displays component documentation
*
*/

component output="false" displayname="ComponentDocs"  {
	Variables.h = Request.html;

	
	/**
	 * Renders list of components in directory, as well as details of selected component, if applicable
	 */
	public void function render(required string directory, boolean recur=false) {
		if (Right(directory, 1) != "/") directory &= "/";
		var path = Replace(directory, "/", ".", "ALL");
		path = Replace(path, ".", "");
		
		h.otabletr('id="docs"');
		h.otd('id="docs-menu" valign="top"');
		ls = DirectoryList(ExpandPath(directory), recur, 'name', '*.cfc');
		for (i = 1; i le ArrayLen(ls); i++) {
			h.a('?component='&ls[i], ls[i]);
			h.br();	
		}
		h.ctd('/docs-menu');
		h.otd('id="docs-content"');
		if (StructKeyExists(URL, 'component')) {
			h.br(2);
			if (!FileExists(ExpandPath(directory&URL.component))) {
				h.tbr(directory);
				h.div('Bad component: ' & URL.component, 'class="alert"');
				abort;
			}
			h.h3('Details for ' & URL.component);
			var component = CreateObject('component', path& Replace(URL.component, '.cfc', ''));
			var meta = GetMetaData(component);
			var hint = (StructKeyExists(meta, 'hint')) ? meta.hint : 
				(StructKeyExists(meta, 'description')) ? meta.description : 'Needs a description';
			h.tbr('<em><strong>Description: </strong>' & hint & '</em>');

			h.odiv('style="background: lightgray;"');
			try {
				component.__docs();
			} catch (Any e) {
				h.tbr("No additional docs");
			}
			h.cdiv();		
			h.h4("<strong>Extends: </strong>" & meta.extends.name);
			if (StructKeyExists(meta.extends, 'functions')) {
				h.h4("<strong>Inherited Functions:</strong>");	
				renderFunctions(meta.extends.functions);
			}
			if (structKeyExists(meta, "functions")) {
				h.h4('Functions');
				renderFunctions(meta.functions);
			}		
			// writedump(meta);
		}
		h.ctd('/docs-content');
		h.ctrtable('/docs');
	}
	/**
	* Renders description and signature of functions' metadata
	*/
	public void function renderFunctions(required array functions) {
		for (var i = 1; i le ArrayLen(functions); i++) {
			var str = '';
			if (StructKeyExists(functions[i], 'access')) str &= functions[i].access & ' ';
			if (StructKeyExists(functions[i], 'returntype')) str &= functions[i].returntype & ' ';
			str &= 'function ' & functions[i].name & "(";
			var numParams = ArrayLen(functions[i].parameters);
			for (var j = 1; j le numParams; j++) {
				var param = functions[i].parameters[j];
				if (StructKeyExists(param, 'required') && param.required) {
					str &= 'required ';	
				}
				if (StructKeyExists(param, 'type')) {
					str &= param.type&' ';	
				}			
				str &= param.name;
				if (StructKeyExists(param, 'default')) {
					var def = param.default == "" ? '""' : param.default;
					str &= '='&def;	
				}			
				if (j lt numParams) str &= ', ';
			}
			str &= ') {}';
			var hint = (StructKeyExists(functions[i], 'hint')) ? functions[i].hint : 'Needs a hint';
			h.tbr('<em>'&hint&'</em>');
			h.tbr(str);
			h.br();
		}
	}	
}