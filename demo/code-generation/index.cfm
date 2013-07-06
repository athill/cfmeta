<cfscript>
args = {
	first_name='another',
	last_name='record'
};
id = Request.db.insertid('actor', args, 'actor_id', 'mysql');
writeOutput(id);
</cfscript>