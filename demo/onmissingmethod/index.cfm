<cfscript>
h.osection('id="my-section"');
h.div('Here''s some text', 'class="myclass"');
h.csection('/my-section');


h.oform('action="submit.cfm" method="post" id="my-form"');
h.ofieldset();
h.legend('My Form');
h.label('My Text Label:', 'for="my-text"');
h.input('type="text" name="my-text" id="my-text" value="textbox"');
h.br();	
h.input('type="checkbox" name="test1" value="a" id="test1_a"');
h.label('a', 'for="a"');
h.input('type="checkbox" name="test1" value="b" id="test1_b"');
h.label('b', 'for="b"');
h.input('type="checkbox" name="test1" value="c" id="test1_c"');
h.label('b', 'for="c"');
h.br();
h.input('type="submit" name="s" id="s" value="Submit"');
h.cfieldset();
h.cform('/my-form');

h.oul('id="my-list"');
h.li('one');
h.li('two');
h.li('three');
h.cul();
</cfscript>