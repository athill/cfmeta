/**
*
* @file  /C/ColdFusion10/cfusion/wwwroot/global/cfc/mixins/Form.cfc
* @author  
* @description
*
*/

component output="false" displayname=""  {
	/*********************************************
	 *  Form functions						 *
	 *********************************************/
	This.inputTags = "radio,checkbox,hidden,submit,button,intext,date,color,datetime,"&
				"inemail,range,search,tel,time,url,week";


	/**
	 * Opens a form	
	 * @param	method	string	default="post" additional attributes
	 * @param	atts	string	default="" additional attributes
	 */	
	public void function oform(required string action, string method='post', any atts='') {
		atts = 'action="#action#" method="#method#"' & fixAtts(atts);
		otag('form', atts);
	}

	/**
	 * Alias for getValue
	 */
	public string function getVal(required string field, string defaultVal='', struct struct={}) {
		return getValue(field, defaultVal, struct);
	}
	
	/**
	 * Opens a fieldset and legend tag	
	 */	
	public void function ofieldset(required string legend, any atts='', any legendAtts='') {
		otag('fieldset', atts, true);
		//tag('legend', legendAtts, legend, true, false);
		This.legend(legend, legendAtts);
	}
	
	/**
	 * Creates a label
	 */
	public void function label(required string id, required string content, any atts='') {
		atts = 'for="#id#"' & fixAtts(atts);
		tag('label', atts, content, true);
	}

	
	/**
	 * Creates an input 
	 */
	public void function input(required string type, required string name, string value='', any atts='') {
		atts = fixAtts(atts);
		var addAtts = ' type="#type#" name="#name#"';
		if (!FindNoCase("id=", atts)) addAtts &= ' id="#name#"';
		if (value != '') addAtts &= ' value="#value#"';
		atts = addAtts & atts;
		tag('input', atts);
	}
	
	
	/**
	 * Creates a text area 	 
	 */
	public void function textarea(required string name, string value='', any atts='', numeric rows=5, numeric cols=60) {
		atts = ' name="#name#" rows="#rows#" cols="#cols#"' & fixAtts(atts); 
		if (!FindNoCase("id=", atts)) atts = ' id="#name#"' & atts;
		tag('textarea', atts, value, true, false);
	}	

	/**
	 * Creates a select dropdown
	 */
	public void function select(required string name, required array options, string selected='', any atts='', 
			boolean empty=false, string optionClassList='') {
		atts = ' name="#name#"' & fixAtts(atts);
		if (!FindNoCase("id=", atts)) atts = ' id="#name#"' & atts;
		otag('select', atts, true);
		if (empty) tag('option', 'value=""', '', true, false);
		renderOptions(options, selected, atts);
		ctag('select', true);
	}
	
	public void function datalist(required string name, required array options, string selected='', any atts='', 
			boolean empty=false, string optionClassList='') {
		tag('input', 'type="text" list="#name#" id="#name#_text"', '', true);
		if (!FindNoCase("id=", atts)) atts = ' id="#name#"' & fixAtts(atts);
		otag('datalist', atts, true);
		if (empty) tag('option', 'value=""', '', true, false);
		renderOptions(options, selected, atts);
		ctag('datalist', true);		
	}
	
	private void function renderOptions(required array options, string selected='', string atts='', string optionClassList='') {
		var value="";
		var display="";
		var optionClass="";
		var selectIt="";
		for (var i = 1; i le ArrayLen(options); i++) {
			if (Find("|", options[i])) {
				if (options[i] eq "|") {
					value = "";
					display = "";
				} else {
					if (Left(options[i], 1) eq "|") {
						value = "";
						display = ListFirst(options[i], "|");	
					} else if (Right(options[i], 1) eq "|") {
						value = ListFirst(options[i], "|");
						display = "";
					} else {
						value = ListFirst(options[i], "|");
						display = ListRest(options[i], "|");
					}
				}
			} else {
				value = options[i];
				display = value;
			}
			if (optionClassList neq "") {
				if (i le ListLen(optionClassList)) {
					optionClass=' class="'&ListGetAt(optionClassList, i)&'"';			 
				} else {
					optionClass="";
				}
			}
			var selectIt = (ListFindNoCase(selected, value)) ? ' selected="selected"': "";
			var optAtts = 'value="#value#"#selectIt##optionClass#';
			tag('option', optAtts, display, true, false);
		}		
	}


	/**
	 * Requires SES.hasEditor to be set.
	 * @param name	string	required	name and id of editor
	 * @param content	content	default=""	
	 * @param options	struct		default={ width=550 }	Number of rows
	 **/
	public void function editor(required string name, string content='', struct options={}) {
		if (Request.site.editor eq "ckeditor") {
			if (!StructKeyExists(options, "width")) {
				options['width'] = 550;	
			}
			options['resize_minWidth'] = options.width;
			options['resize_maxWidth'] = options.width;
		}
		var class = 'editor';
		if (Request.site.editor eq "tinymce" && StructKeyExists(options, 'class')) {
			class = options.class;	
		}
		textarea(name, content, {class=class});
		if (Request.site.editor eq "ckeditor") script("utils.editorManager.create('"&name&"',"&SerializeJSON(options)&");");
		
	}

	public void function calendar(required string name, string value='', any atts='') {
		atts = addClass(fixAtts(atts), "datepicker");
		if (not Find("size=", atts)) atts &= ' size="15"';
		input('date', name, value, atts);
	}		 


	/**
	 * Displays a grid of checkbox or radio button fields
	 */
	public void function choicegrid() {
		var name = reqArg("name", Arguments);				////REQUIRED string - form name of checkbox set
		var vals = reqArg("vals", Arguments);				////REQUIRED list - values for checkboxes/radoibuttons
		var type = getValue("type", "checkbox", Arguments);	////Optional - checkbox|radio, default: checkbox
	//	var labels = getValue("labels", vals, Arguments);	////Optional - list, default: values
		var ids = getValue("ids", "", Arguments);			////Optional - list, default: ""
		var selected = getValue("selected", getValue(name), Arguments);	/////Optional - list, default: ""
		var labelfirst = getValue("labelfirst", false, Arguments);	/////Optional - bool, default: false
		var attsAll = getValue("attsAll", "", Arguments);	/////Optional - string, attributes shared by all choices, default: ""
		var atts = getValue("atts", "", Arguments);	/////Optional - list, attributes for each choice
		var labelAttsAll = getValue("labelAttsAll", "", Arguments);	/////Optional - string, attributes shared by all labels default: ""
		var labelAtts = getValue("labelAtts", "", Arguments);	/////Optional - list, attributes for each label
		var container = getValue("container", "none", Arguments);	/////Optional - none|table|div, default: none
		var containerAtts = getValue("containerAtts", "", Arguments);	/////Optional - string, container attributes
		var closeContainer = getValue("closeContainer", true, Arguments);	/////Optional - , default: true
		var numCols = getValue("numCols", 0, Arguments);	/////Optional - int, number of column. default: 0 (each choice in its own column)
		var selectall = getValue("selectall", false, Arguments);	////Optional - Append a selectall link 
		var selectallInitState= getValue("selectallInitState", "select", Arguments);
		var selectClass="selectall";
		var hasAtts = ListLen(atts) > 0;
		var labelClass= type&"_label";
		//if (ListLen(labels) != ListLen(vals)) Request.utils.throw("Error in choicegrid. vals and labels not same length");
		if (ids != "" && ListLen(vals) != ListLen(ids)) Request.utils.throw("Error in choicegrid. vals and ids not same length");
		if (hasAtts && ListLen(vals) != ListLen(atts)) Request.utils.throw("Error in choicegrid. vals and atts not same length");
		if (LCase(selectallInitState) eq "deselect") selectClass &= " deselect";
		if (selectall) containerAtts = combineClassAtts(containerAtts & 'class="#selectClass#"');
		if (container eq "table") otabletr(containerAtts);
		else if (container eq "div" or (container eq "none" and selectall)) otag('div', containerAtts, true);
		for (var i = 1; i <= ListLen(vals); i++) {
			if (container eq "table") otag('td');
			value = ListGetAt(vals, i);
			labl = value;
			if (ListLen(value, "|") eq 2) {
				labl = ListLast(value, "|");
				value = ListFirst(value, "|");
			}
			id = name&"_"&value;
			if (ListLen(ids) > 0) {
				id = ListGetAt(ids, i);		
			} 
			lblAtt = 'class="'&labelClass&'"';
			if (ListLen(labelAtts) ge i) lblAtt &= fixAtts(ListGetAt(labelAtts, i)); 
			lblAtt &= fixAtts(labelAttsAll); 
			if (labelfirst) lblAtt &= fixAtts('class="'&labelClass&'"');
			lblAtt = combineClassAtts(lblAtt);
			if (labelfirst) label(id, labl, lblAtt);
			attributes = IIf(ListFindNoCase(selected, value), DE(' checked="checked"'), DE(""));
			if (hasAtts) attributes &= fixAtts(ListGetAt(atts, i));
			if (Len(attsAll)) attributes &= fixAtts(attsAll);
			attributes = combineClassAtts(attributes);
			//if (id != value) 
			attributes &= fixAtts('id="'&id&'"');
			input(type, name, value, attributes);
			if (!labelfirst) label(id, labl, lblAtt);
			if (container eq "table") ctag('td');
			if (numCols > 0 && i mod numCols eq 0 && i < ListLen(vals)) {
				if (container eq "table") {
					ctag('tr');
					otag('tr');
				}
				else br();
			}
		}
		if (container eq "table" && closeContainer) ctrtable();
		else if ((container eq "div" or (container eq "none" and selectall)) && closeContainer) ctag('div', true);	
	}
}