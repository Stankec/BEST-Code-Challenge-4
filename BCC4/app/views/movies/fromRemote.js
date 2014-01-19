if (!$('#content-helper').length)
{
	$('body').append("<div id=\"content-helper\"></div>");
}
if (!$('#tempModal').length)
{
	$("#content-helper").html  (''+
								'<div class="modal fade" id="tempModal" tabindex="-1" role="dialog" aria-labelledby="tempModal" aria-hidden="true">'+
								  	'<div class="modal-dialog">'+
								  	  	'<div class="modal-content">'+
								  	  	  	'<div class="modal-header">'+
								  	  	  	  	'<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>'+
								  	  	  	  	'<h4 class="modal-title" id="tempModalHeader">Modal title</h4>'+
								  	  	  	'</div>'+
								  	  	  	'<div class="modal-body" id="tempModalBody">'+
								  	  	  	  '	<p>One fine body&hellip;</p>'+
								  	  	  	'</div>'+
								  	  	  	'<div class="modal-footer" id="tempModalFooter">'+
								  	  	  	  	'<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>'+
								  	  	  	'</div>'+
								  	  	'</div>'+
								  	'</div>'+
								'</div>'+
								'');
	$('#tempModal').on('hidden', function () {
		$('#tempModal').remove();
	});
}

$('#tempModalHeader').html(	'New Movie');
$('#tempModalBody').html(	'<%= j render :partial => "remoteAdd", :locals => {:movie => Movie.new } %>' );
$('#tempModalFooter').html(	'<button type="button" class="btn btn-default" data-dismiss="modal">'+
								'<i class="icon-remove"></i> Cancel'+
							'</button>'+
							'<div style="float:right; margin-left:5px; display:none;" id="moviePreviewSave">'+
								'<%= link_to '<i class="icon-ok"></i> Save'.html_safe, "#", 
									 :remote => true,
									 :class => 'btn btn-primary', 
									 :onclick => '$(".new_movie").submit()' %>'+
							'</div>'+
							'<div style="float:right; margin-left:5px;">'+
								'<button class="btn btn-info" id="moviePreviewButton"><i class="icon-search"></i> Preview</div>'+
							'</div>'+
							'<div style="float:left; margin-left:5px;" id="moviePreviewButtonText">'+
								''+
							'</div>' );

$('#tempModal').modal();

$('#moviePreviewButton').click(function(e){
	var queryString = "http://www.omdbapi.com/?t=";
	if ($('#remoteTitle').length && $('#remoteTitle').val().length != 0)
		queryString += encodeURIComponent($('#remoteTitle').val());
	if ($('#remoteYear').length && $('#remoteYear').val().length != 0)
		queryString += "&y=" + encodeURIComponent($('#remoteYear').val());
	$('#moviePreviewButtonText').html('<i class="fa fa-spinner fa-spin fa-2x"></i>');
	$('#moviePreviewSave').hide("fast");
	$('#moviePreview').hide("fast");
	$.ajax({
	  	url: queryString,
	  	dataType: 'json',
	  	success: function(result){
	  	  	//alert("token recieved: " + result.token);
	  	},
	  	error: function(request, textStatus, errorThrown) {
	  	  	$('#moviePreviewButtonText').html('<font style="color:red">An error has occured!</font>');
	  	},
	  	complete: function(request, textStatus) { //for additional info
	  	  	var json = $.parseJSON(request.responseText);
	  	  	if (json.Response !== "True") 
	  	  	{
	  	  		$('#moviePreviewButtonText').html('<font style="color:red">That movie does not exist!</font>');
	  	  		return;
	  	  	}
			$('#moviePreview').show("fast");
	  		$('#moviePreviewButtonText').html('');
	  		$('#moviePreviewSave').show("fast");
			if (json.length == 0) return;
	  	  	$.each(json, function(key,val) {
	  	  		if ($('#moviePreview'+key).length)
			  		$('#moviePreview'+key).html(val);
			  	if (key == "Poster")
			  		$('#moviePreview'+key).html("<center><img src=\""+val+"\" style=\"max-width:50%; height:auto;\" /></center>");
			});
	  	}
	});
});

