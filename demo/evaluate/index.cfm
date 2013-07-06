<form action="" method="post" id="eval-form">
	<h2>Operate on Two Numbers</h2>
	<p>Supported Operators are +,-,*, and /.</p>
	<label for="a">First Number:</label>
	<input type="number" name="a" id="a">
	<label for="op">Operator:</label>
	<input type="text" name="op" id="op" size="1" maxlength="1">
	<label for="b">Second Number:</label>
	<input type="number" name="b" id="b">
	<input type="submit" value="Operate">
</form>

<cfscript>
//////////////////////
//// handle form
/////////////////////
if (structKeyExists(Form, 'a')) {	
	if (validateIt()) {
		answer = evaluateIt();
		// answer = caseswitchIt();	
		writeoutput('#Form.a# #Form.op# #Form.b# = <strong>#answer#</strong>');
	}
}
///////////////////
//// helpers
////////////////////

//// use case/switch
function caseswitchIt() {
	switch (Form.op) {
		case '+':
			return Form.a + Form.b;
		case '-':
			return Form.a - Form.b;
		case '*':
			return Form.a * Form.b;
		case '/':
			return Form.a / Form.b;
	}
}

//// use evaluate
function evaluateIt() {
	return  evaluate("#Form.a# #Form.op# #Form.b#");
}

////validate input
function validateIt() {
	var validOps = "+,-,*,/";
	////first number
	if (!IsNumeric(Form.a)) {
		err('First Number must be numeric, you entered "#Form.a#".');
		return false;
	//// second number
	} else if (!IsNumeric(Form.b)) {
		err('Second Number must be numeric, you entered "#Form.b#".');
		return false;
	//// operand
	} else if (!listFind(validOps, Form.op)) {
		err('Operator must by one of '&validOps&', you entered "#Form.op#".');
		return false;
	}
	//// divide by zero
	if (Form.op == '/' && Form.b == 0) {
		err('Division by zero is not allowed.');
		return false;
	}		
	return true;
}
////display error message
function err(required string mssg) {
	writeoutput('<div class="error">'&mssg&'</div>');
}
</cfscript>
<script>
var x = document.getElementById("eval-form");
x.elements[0].focus();
</script>
</script>