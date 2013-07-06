<cfscript>
d = {
	'one'='a',
	'two'='b'
};
/**
 * serializes data using given formatting function 
 * @data data to be serialized
 * @func function to serialize data
 * @return serialized data
 */
function serializer(required any data, required function func) {
	var md = getMetaData(func);
	if (!structkeyExists(md, 'parameters') || arrayLen(md.parameters) < 1 || (structKeyExists(md.parameters[1], 'type') && 
			md.parameters[1].type != 'any')) {
		throw 'Invalid function passed to serializer.';
	}
	return func(data);
}

/**
* converts data to xml string
* @data cf variable
* @return xml string
*/
string function data2xml(required any data) {
	//// http://www.raymondcamden.com/index.cfm/2006/7/2/ToXML-CFC--Converting-data-types-to-XML
	var toxml = new toxml();
	if (isQuery(data)) {
		return toxml.queryToXML(data, 'items', 'item');
	} else if (isArray(data)) {
		return toxml.arrayToXML(data, 'items', 'item');
	} else if (isStruct(data)) {
		return toxml.structToXML(data, 'items', 'item');		
	} else {
		return toxml.listToXML(data, 'items', 'item');		
	}
}

/**
* converts data to json string
* @data cf variable
* @return json string
*/
string function data2json(required any data) {
	return serializeJSON(data);
}

writeOutput('XML: ');
writeDump(serializer(d, data2xml));
writeOutput('<br /><br />');
writeOutput('JSON: '&serializer(d, data2json));

writeOutput('<br /><br />');
writeoutput('Inline functions!!!: ');

h.br(2);
writedump(serializer(d, function(data) { 
	return serializeJSON(data); 
}));	

function function serializeCurry(required function func) {
	return function(required any data) {
		return func(data);
	};
}



xmlSerializer = serializeCurry(data2xml);
jsonSerializer = serializeCurry(function(data) { return serializeJSON(data); });
// jsonSerializer = serializeCurry(function(data) { return serializeJSON(data); })(data);

writeOutput('XML: ');
writeDump(xmlSerializer(d));
writeOutput('<br /><br />');
writeOutput('JSON: '&jsonSerializer(d));

</cfscript>