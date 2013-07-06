/**
*
* @file  /X/global/cfc/modules/html/Table.cfc
* @author  
* @description
*
*/

component output="false" displayname=""  {

	public function init(){
		if (!structKeyExists(This, 'tbr')) {
			throw('This is a mixin for the Html class');
		}
	}


	/*********************************************
	 *  Table functions						 *
	 *********************************************/

	/**
	 * DEPRECATED: Use otabletr
	 */	
	public void function otable(any atts='', any rowAtts='', string cols='') {
		This.otabletr(atts, rowAtts, cols);
	}
	
	/**
	 * Opens a table/tbody/tr	
	 * @param	atts	string	default="" additional attributes
	 * @param	rowAtts	string	default="" additional attributes
	 * @param	cols	string	default="" list of column widths which will generate <col width="X" /> tags
	 */	
	public void function otabletr(any atts='', any rowAtts='', string cols='') {
		otag('table', atts);
		if (cols neq "") {
			for (var i = 1; i le ListLen(cols); i++) {
//				tnl('<col width="#ListGetAt(cols, i)#" />');
				tag('col', {width=ListGetAt(cols, i)});
			}
		}
		This.otbody();
		This.otr(rowAtts);
	}

	public void function corow(any atts='') {
		This.ctr();
		This.otr(atts);
	}
	
	/**
	 * DEPRECATED: Use ctrtable()
	 */
	// public void function ctable(string comment='') {
	// 	This.ctrtable(comment);
	// }

	/**
	 * Closes tr/tbody/table
	 */			
	public void function ctrtable(comment='') {
		This.ctr();
		This.ctbody();
		ctag('table', false, comment);
	}
	
	
	
	/**
	 * Evaluates contents of a table cell
	 */	
	public void function evaltd(required string eval, any atts='') {
		This.otd(atts);//otag('td', atts);
		Evaluate(eval);
		This.ctd();//ctag('td');
	}
	
	function simpleTable(struct options={}) {
		var defaults = 	{
			headers=[],
			data=[],
			atts='',
			caption=''
		};
		options = extend(defaults, options);
		if (!IsArray(options.headers)) options.headers = ListToArray(options.headers);
		otag('table', options.atts);
		////caption
		if (options.caption != '') {
			This.caption(options.caption);
		}
		////headers
		if (ArrayLen(options.headers) > 0) {
			This.othead();
			This.otr();
			for (var i = 1; i <= ArrayLen(options.headers); i++) {
				This.th(options.headers[i]);
			}
			This.ctr();
			This.cthead();
		}
		////data
		This.otbody();
		for (var i = 1; i <= ArrayLen(options.data); i++) {
			This.otr();
			for (var j = 1; j <= ArrayLen(options.data[i]); j++) {
				This.td(options.data[i][j], 'style="vertical-align: top;"');
			}
			This.ctr();
		}
		This.ctbody();
		ctag('table');	
	}
	
	public void function query2table(required query recordset, struct options={}) {
		var defaults = {
			headers=recordset.getColumnNames(),
			atts=''	
		};
		options = extend(defaults, options);
		options.data = Request.db.query2array(recordset);
		simpleTable(options);
	}	
	
}