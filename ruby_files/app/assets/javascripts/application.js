// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require_tree .

Turbolinks.enableTransitionCache();

NProgress.configure({
  	showSpinner: false,
  	ease: 'ease',
  	speed: 100
});

function toggleSearch(searchForm,searchButton,searchToggle,toggleTextBefore,toggleTextAfter,toggleButtonAddClass) {
	if ( !($(searchForm).length) || !($(searchButton).length) || !($(searchToggle).length) ) return;
	if ( $(searchForm).is(":visible") ) {
		$(searchForm).hide("fast");
		$(searchButton).hide("fast");
		$(searchToggle).hide("fast", function() {
			$(searchToggle).html(toggleTextBefore);
			$(searchToggle).removeClass(toggleButtonAddClass);
			$(searchToggle).show("fast");
		});
	} else {
		$(searchForm).show("fast");
		$(searchButton).show("fast");
		$(searchToggle).hide("fast", function() {
			$(searchToggle).html(toggleTextAfter);
			$(searchToggle).addClass(toggleButtonAddClass);
			$(searchToggle).show("fast");
		});
	}
}