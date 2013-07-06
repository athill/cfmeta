
		<div class="reveal">

			<!-- Any section element inside of this container is displayed as a slide -->
			<div class="slides">

				<section>
					<h1>Metaprogramming<br /> in ColdFusion</h1>
					<p>
						<small>By <a href="http://andyhill.us">Andy Hill</a></small>
					</p>
				</section>
				<!-- About -->
				<section>
					<h2>About Me</h2>
					<p>
						<ul>
							<li class="fragment">Senior Systems/Analyst at Indiana University as well as freelance work</li>
							<li class="fragment">Maintain multiple web sites in ColdFusion, PHP, and SharePoint</li>
							<li class="fragment">Graduated from I.U. with  B.S. in Computer Science in 2003</li>
							<li class="fragment">All about CFSCRIPT</li>
						</ul>
					</p>
				</section>				
				<section>
					<h2>What is Metaprogramming?</h2>
					<p>
					According to Wikipedia, 
					<blockquote>
						<a href="http://en.wikipedia.org/wiki/Metaprogramming" title="_blank">Metaprogramming</a> is the writing of computer programs that write or manipulate other programs (or themselves) as their data, or that do part of the work at compile time that would otherwise be done at runtime.
					</blockquote>
					</p>
				</section>	
				<section>
					<h2>Metaprogramming to Me</h2>
					<p>
					Code that inspects or maniplulates its environment at compile or 
					run time. 
					<ul>
						<li>Reduce redundant code </li>
						<li>Increase flexibility</li>
						<li>Extend a component with only the functionality you need</li>
					</ul>
					</p>
				</section>	
				<section>
					<h2>Overview</h2>
					<p>We'll look at the following in ColdFusion:
					<ol>
						<li>Evaluate()</li>
						<li>Introspection</li>
						<li>Function Passing</li>
						<li>Overloading</li>
						<li>Code Generation</li>
						<li>OnMissingMethod()</li>
						<li>Mixins</li>
					</ol>
					</p>
				</section>
				<!-- Evaluate -->
				<section>
					<section>
						<h2>Evaluate()</h2>
						<p>
						According to CF docs, <a href="http://help.adobe.com/en_US/ColdFusion/9.0/CFMLRef/WSc3ff6d0ea77859461172e0811cbec22c24-7f4e.html" title="_blank">Evaluate</a>: 
								<blockquote>
								Evaluates one or more string expressions, dynamically, from left to right. (The results of an evaluation on the left can have meaning in an expression to the right.) Returns the result of evaluating the rightmost expression.
								</blockquote>

						</p>
					</section>
					<section>
						<h2>Evaluate() (continued)</h2>
						<p>
						<ul>
							<li>The example Adobe gives, 
							<pre><code data-trim>
Evaluate("qNames.#colname#[#index#]");
						</code></pre>I would just write as 
						<pre><code data-trim>
qNames[colname][index];
						</code></pre>
							</li>
							<li>If you do use it, be sure to sanitize any user data before passing to Evaluate()</li>
							<li>Not nearly as capable as Ruby's eval()</li>
							<li>I haven't used recently, so my example is contrived</li>
						</ul>
						</p>
					</section>
				</section>
				<!-- Introspection -->
				<section>
					<section>
						<h2>Introspection</h2>
						<p>From <a href="http://en.wikipedia.org/wiki/Type_introspection" target="_blank">Wikipedia</a>:
						<blockquote>
						In computing, type introspection is the ability of a program to examine the type or properties of an object at runtime. Some programming languages possess this capability.

						Introspection should not be confused with reflection, which goes a step further and is the ability for a program to manipulate the values, meta-data, properties and/or functions of an object at runtime.
						</blockquote>
						</p>					
					</section>
					<section>
						<p>
						<h2>Introspection (Methods)</h2>
						<ul>
							<li>WriteDump/CFDump to inspect the returned metadata</li>
							<li>GetMetaData()</li>
							<li>CF10:
							 <ul>
							 	<li>GetApplicationMetadata()</li>
							 	<li>SessionGetMetaData()</li>
							 	<li>CallStackGet()</li>
							 </ul>
							</li>
						</ul>
						</p>
					</section>
					<section>
						<p>
						<h2>GetMetaData: Native CF Variables</h2>
						<ul>         
						    <li>Returns an instance of Java.lang.class</li>
						    <li>Can use any methods of that class on the metadata object</li>
						    <li>Probably not very useful unless using other Java classes</li>
						</ul>	
						</p>
					</section>
					<section>
						<p>
						<h2>GetMetaData: Functions</h2>
						<ul>
							<li>Depends on how explicit your function declarations are.
							<li>Struct keys:
								<ul>
								    <li>Name: Name of the function</li>
								    <li>Parameters: Array of function parameters. Each array entry is a struct with 'name' and 'required' fields, other cfargument attributes returned if declared
									</li>
									<li>Access: Not defined by default (public/private)</li>
								    <li>Return Type: Not defined by default</li>
								    <li>Any other attributes to cffunction</li>
								</ul>	
							</li>
						</p>
					</section>
					<section>
						<p>
						<h2>GetMetaData: Components</h2>
						<ul>
						    <li>By default, has 'fullname', 'name', 'path', 'type', and an 'extends' struct with the same fields for the component's parent</li>
						    <li>If there are any methods defined, returns 'functions', an array of structs with metadata for each function</li>
						    <li>Returns any other defined cfcomponent attribute</li>
						</ul>	
						</p>
					</section>
					<section>
						<h2>CF10</h2>
						<p>
						<ul>
						 	<li>GetApplicationMetadata(): Application (timeout, session, client, cookie, etc. settings)</li>
						 	<li>SessionGetMetaData(): Only current key is 'starttime'</li>
						 	<li>CallStackGet(): How did I get here? Works anywhere. Array of structs representing the call stack (from most recent back to application.cfc.).
						 	Struct keys are 'Function', 'LineNumber', and 'Template.'</li>
						 </ul>
						</p>
					</section>
				</section>
				<!-- Function Passing -->
				<section>
					<section>
						<h2>Function Passing</h2>
						<p>
						<ul>
							<li>Pass a function (callback) to another function as an argument</li>
							<li>CF10 supports inline functions (a subset of <a href="http://help.adobe.com/en_US/ColdFusion/10.0/Developing/WSe61e35da8d31851842acbba1353e848b35-7fff.html" target="_blank">closures</a>), making traditional function passing somewhat irrelevant, but still valuable if 
							passing the same function to more than one function.
							</li>
							<li>CF10 also supports passing functions as arguments to native functions such as ArraySort() for custom sorting</li>
						</ul>
						</p>					
					</section>
					<section>
						<p>
						<h3>CF9</h3>
						<pre><code data-trim>
d = { 'one'='a', 'two'='b' };
string function serializer(data, func) {
	return func(data);
}
//// helpers
string function data2json(required any data) {
	return serializeJSON(data);
}
string function data2xml(required any data) {
	var toxml = new toxml(); //// toxml.cfc from <a href="http://www.raymondcamden.com/index.cfm/2006/7/2/ToXML-CFC--Converting-data-types-to-XML" target="_blank">raymondcamden.com</a>
	if (isQuery(data)) return toxml.queryToXML(data, 'items', 'item');
	else if (isArray(data)) return toxml.arrayToXML(data, 'items', 'item');
	if (isStruct(data)) return toxml.structToXML(data, 'items', 'item');		
	else return toxml.listToXML(data, 'items', 'item');
}
//// returns {"one":"a","two":"b"}
jsonstr = serializer(d, data2json);

//// returns &lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;items&gt;&lt;item&gt;&lt;one&gt;a&lt;/one&gt;&lt;two&gt;b&lt;/two&gt;&lt;/item&gt;&lt;/items&gt;
xmlstr = serializer(d, data2xml);
						</code><pre>
						</p>
					</section>
					<section>
						<p>			
						<h3>CF10</h3>			
						<pre><code data-trim>
serializer(d, function(data) { return serializeJson(data); });

//// CF ArraySort with custom sorting function
//// from <a href="http://www.raymondcamden.com/index.cfm/2012/8/14/Another-ColdFusion-10-Closures-Post" target="_blank">raymondcamden.com</a>
arraySort(data, function(a,b) {
	//remove the The
	var first = a;
	var second = b;
 
	first = replace(first, "The ","");
	second = replace(second, "The ","");
 
	return first gt second;
});
						</code><pre>
						</p>
					</section>
					<section>
					<h3>Currying</h3>
					<pre><code data-trim>
function function serializeCurry(required function func) {
	return function(required any data) {
		return func(data);
	};
}

xmlSerializer = serializeCurry(data2xml);
jsonSerializer = serializeCurry(function(data)  {
	return serializeJSON(data); 
});

//// returns xml
xmlSerializer(d);
//// returns json
jsonSerializer(d);
					</code></pre>
					</section>	
				</section>
				<!-- Overloading -->
				<section>
					<section>
						<h2>Overloading</h2>
						<p>
						<ul>
							<li> Overloading is having several methods with the same name which differ from each other in the type of the input and/or output of the function.</li>
							<li>In strongly typed languages, such as Java or C#, overloading is accomplished by having multiple functions with the same name with different method signatures</li>
							<li>In ColdFusion and other weakly typed languages, this is accomplished via type-sniffing and optional arguments</li>
							<li>jQuery: $(obj).html() versus $(obj).html('Hello World!')</li>
						</ul>
						</p>					
					</section>
					<section>
					<h2>Overloading Example</h2>
					<pre><code data-trim>
public any function query(required string sql, any args, string dsn=This.dsn) {
		//// query without arguments, default dsn
		if (!IsDefined('args')) {
			args = This.dsn;
		}
		////query with arguments
		if (isArray(args)) {
			return This.safeQuery(sql, args, dsn);
		////query without args
		} else {
			dsn = args;
			return This.safeQuery(sql, [], dsn);
		}
	}

db.query('select * from my_table');
db.query('select * from my_table where id=?', [ 5 ]);
db.query('select * from their_table', 'their_dsn');
db.query('select * from their_table where id=?', [ 5 ], 'their_dsn');
					</code></pre>
					</section>
				</section>
				<!-- Code Generation -->
				<section>
					<section>
						<h2>Code Generation</h2>
						<p>
						<ul>
							<li>Write out code to a file (.cfc, .cfm, .js, .css)</li>
							<li>Execute it</li>
						</ul>
						</p>					
					</section>
					
					<section>
					<h2>Example: getDsObject()</h2>
					<p>
						<ul>
							<li>Used in determining the correct cfsqltype for cfsqlparam</li>
							<li>Checks if there is a .cfc file for the requested table in the specified directory (e.g., /cfc/dbtables/tablename.cfc)</li>
							<li>If not,
							<ul>
								<li>Query the database for the table metadata (e.g., information_schema.columns)</li>
								<li>Generate code for a .cfc file, which associates column names with their types</li>
								<li>Write code to .cfc file</li>
							</ul>
							<li>Instantiate and return the object (e.g., return createObject('component', 'cfc.dbtables.tablename');</li>


						</ul>
					</p>
					</section>
				</section>
				<!-- OnMissingMethod() -->
				<section>
					<section>
						<h2>OnMissingMethod()</h2>
						<p>
						<ul>
							<li>Called when a component method is called which does not exist</li>
							<li>Ruby's version, method_missing, uses it for its Active Record model</li>
							<li>I would imagine something similar is used for CF ORM (Hibernate)</li>
							<li>The idea being that methods like get{columnName}() is not manually written, but generated on the fly based on the object's knowledge of the table metadata</li>
						</ul>
						</p>					
					</section>
				</section>
				<!-- Mixins -->
				<section>
					<section>
						<h2>Mixins</h2>
						<p>
						<ul>
							<li>Add functionality to component at runtime</li>
							<li>Mixins can assume variables/methods of parent will be there</li>
						</ul>
						</p>					
					</section>
					<section>
						<h2>Code</h2>
						<p>
						<pre><code data-trim>
	
//// Modified from <a href="http://corfield.org/blog/index.cfm/do/blog.entry/entry/Mixins" target="_blank">corfield.org</a>
public function mixin(type) {
 	var target = createObject("component",arguments.type);
	structAppend(this,target);
	structAppend(variables,target);
	if (structKeyExists(target, 'getVariables')) {
		structAppend(variables, target.getVariables());
	}
}

//// Add to mixin to allow access to variables scope
//// However, this will expose variables scope
public struct function getVariables() {
	return variables;
}
						</code></pre>
						</p>					
					</section>
				</section>
				<!-- Review -->
				<section>
				<h2>Review</h2>				
				<ul>
					<li>Introspection: Use metadata from your programming environment</li>
					<li>Function Passing and Currying: Pass functions by name or inline to add custom behavior (e.g., sorting, parsing)</li>
					<li>Overloading: Before writing a similar function, consider adapting the function 
						based on parameter types</li>
					<li>Code Generation: Generate code files on the fly for custom behavior</li>
					<li>OnMissingMethod(): Groups common method behavior by name to avoid repetitive code</li>
					<li>Mixins: Extend component at run time based on just the extended behavior needed</li>
				</ul>
				</section>				
				<!-- Wrap Up -->
				<section>
				<h2>Wrap Up</h2>
				<p>
				<figure>
				<img src="the_general_problem.png" />
				<figcaption>via <a href="http://xkcd.com/974/" target="_blank">xkcd</a><figcaption>
				</figure>
				</p>
				<p>GitHub: <a href="https://github.com/athill/cfmeta/" target="_blank">https://github.com/athill/cfmeta/</a></p>
				<p>Slideshow engine: <a href="https://github.com/hakimel/reveal.js/" target="_blank">Reveal.js</a></p>
				<p>Questions? <cfoutput>#h.email('andy@andyhill.us')#</cfoutput></p>
				</section>
			</div>
		</div>


		<cfscript>

			// Full list of configuration options available here:
			// https://github.com/hakimel/reveal.js#configuration
			h.script("
			Reveal.initialize({
				controls: true,
				progress: true,
				history: true,
				center: true,

				theme: Reveal.getQueryHash().theme, // available themes are in /css/theme
				transition: Reveal.getQueryHash().transition || 'default', // default/cube/page/concave/zoom/linear/none

				// Optional libraries used to extend on reveal.js
				dependencies: []
			});
			");
		</cfscript>		