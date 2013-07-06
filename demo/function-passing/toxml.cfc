<cfcomponent displayName="To XML" hint="Set of utility functions to generate XML" output="false">

<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML">
	<cfargument name="data" type="array" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfset var s = "<?xml version=""1.0"" encoding=""UTF-8""?>">
	<cfset var x = "">
	
	<cfset s = s & "<" & arguments.rootelement & ">">
	<cfloop index="x" from="1" to="#arrayLen(arguments.data)#">
		<cfset s = s & "<" & arguments.itemelement & ">" & xmlFormat(arguments.data[x]) & "</" & arguments.itemelement & ">">
	</cfloop>
	
	<cfset s = s & "</" & arguments.rootelement & ">">
	
	<cfreturn s>
</cffunction>

<cffunction name="listToXML" returnType="string" access="public" output="false" hint="Converts a list into XML.">
	<cfargument name="data" type="string" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="delimiter" type="string" required="false" default=",">
	
	<cfreturn arrayToXML( listToArray(arguments.data, arguments.delimiter), arguments.rootelement, arguments.itemelement)>
</cffunction>

<cffunction name="queryToXML" returnType="string" access="public" output="false" hint="Converts a query to XML">
	<cfargument name="data" type="query" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="cDataCols" type="string" required="false" default="">
	
	<cfset var s = "<?xml version=""1.0"" encoding=""UTF-8""?>">
	<cfset var col = "">
	<cfset var columns = arguments.data.columnlist>
	<cfset var txt = "">
	
	<cfset s = s & "<" & arguments.rootelement & ">">
	<cfloop query="arguments.data">
		<cfset s = s & "<" & arguments.itemelement & ">">

		<cfloop index="col" list="#columns#">
			<cfset txt = arguments.data[col][currentRow]>
			<cfif isSimpleValue(txt)>
				<cfif listFindNoCase(arguments.cDataCols, col)>
					<cfset txt = "<![CDATA[" & txt & "]]" & ">">
				<cfelse>
					<cfset txt = xmlFormat(txt)>
				</cfif>
			<cfelse>
				<cfset txt = "">
			</cfif>

			<cfset s = s & "<" & col & ">" & txt & "</" & col & ">">

		</cfloop>
		
		<cfset s = s & "</" & arguments.itemelement & ">">
	</cfloop>
	
	<cfset s = s & "</" & arguments.rootelement & ">">
	
	<cfreturn s>
</cffunction>

<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts a struct into XML.">
	<cfargument name="data" type="struct" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">

	<cfset var s = "<?xml version=""1.0"" encoding=""UTF-8""?>">
	<cfset var keys = structKeyList(arguments.data)>
	<cfset var key = "">
	
	<cfset s = s & "<" & arguments.rootelement & ">">
	<cfset s = s & "<" & arguments.itemelement & ">">

	<cfloop index="key" list="#keys#">
		<cfset s = s & "<#key#>#xmlFormat(arguments.data[key])#</#key#>">
	</cfloop>
	
	<cfset s = s & "</" & arguments.itemelement & ">">
	<cfset s = s & "</" & arguments.rootelement & ">">
	
	<cfreturn s>		
</cffunction>

</cfcomponent>