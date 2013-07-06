$(function() {
	if (typeof hljs == 'object') {
		hljs.initHighlightingOnLoad();
	}
	if (typeof $.fn.treeview == 'function') {
		$('#tree-menu').treeview({ collapsed: true, persist: 'location', animate: 'slow' });
	}

});