Meta-Programming in ColdFusion
==============================

Presentation I made for [CFMeetup](http://www.meetup.com/coldfusionmeetup/) covering:

- Evaluate()
- Introspection
- Function Passing
- Overloading
- Code Generation
- OnMissingMethod()
- Mixins

Requirements
------------

- [ColdFusion 10](http://www.adobe.com/products/coldfusion-enterprise.html)
- [MySQL 5.1](http://dev.mysql.com/downloads/) (for Code Generation Demo)

Installation
------------
- Clone or unzip cfmeta folder into {CF-Install}/wwwroot
- If appropriate, change the value of variables.maproot in application.cfc to reflect the 
	location of your coldfusion installation.
- For MySQL/Code Generation demo, add a datasource to ColdFusion Administrator named 'mysql' that points to the sakila database that comes with MySQL
- Should be ready to go to http://127.0.0.1:8500/cfmeta/

Code Layout
-----------

<pre>
- components - CFCs specific to this site
- css - CSS specific to this site
- demo - Code for demonstrations
- global - If maintaining multiple sites, this could be a virtual folder/symbolic link
	- cfc - CFCs available for any site
	- css -  CSS available for any site
	- js  - JavaScript available for any site
- js - JavaScript specific to this site
- slideshow - Reveal.js slideshow
- application.cfc 
- index.cfm
- menu.xml - Menu structure
- slideshow.pdf - PDF of slideshow
</pre>



