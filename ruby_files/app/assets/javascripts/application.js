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

function displayError(errorMessage)
{
	if(errorMessage.length == 0) return;

	if(!$('#flash').length)
	{
		$('body').prepend(	'<div id="flash" class="alert fade in" style="position:absolute; top:70px; left:2%; width:30%; z-index:1041; display:none;">'+
								'<button type="button" class="close" data-dismiss="alert">&times;</button>'+
								'<div id="flashmsg"></div>'+
							'</div>');
	}

	$('#flashmsg').html(errorMessage);

	$('#flash').removeClass("alert-success").removeClass("alert-danger").addClass("alert-danger");;

	if ($('#flash_notice').length) 	$('#flash').removeClass("alert-danger").addClass("alert-success");
	if ($('#flash_alert').length) 	$('#flash').addClass("alert-danger");

	$('#flash').show();
}