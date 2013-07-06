<cfscript>

h.mixin('global.cfc.mixins.html.Form');

h.oform('submit.cfm', 'post', 'id="my-form"');
h.ofieldset('My Form');
h.label('my-text', "My Text Label:");
h.intext('my-text', 'textbox');
h.br();
h.choicegrid(name='test1',vals='a,b,c');
h.br();
h.submit('s', 'Submit');
h.cfieldset();
h.cform('my-form');

h.mixin('global.cfc.mixins.html.List');

h.liArray('ul', ['one', 'two', 'three']);
</cfscript>