var socket; // global socket variable

$(document).ready(function() {
	updateStep(1);
	
	/*
	* Setup (step 0)
	*/
	// Test connection
	$( "#formTestServer" ).submit(function( event ) {
		var address = $('#inputAddress').val();
		socket = new $.JsonRpcClient({ socketUrl: address });
		socket.call(
			'Context.isReady', [], // Context.isReady always returns true. It is used to open the socket and test the API.
			function(result) { // On success (server replied)
				$('#buttonConnect').removeClass( 'btn-danger' ).addClass( 'btn-success' )
					.html('&#10004; server is up!');
				$('#inputImage').removeClass('hidden');
			},
			function(error)  { // An error was thrown.
				$('#buttonConnect').removeClass( 'btn-success' ).addClass( 'btn-danger' )
				.html('&#9747; error!');
			}
		);
		event.preventDefault();
	});
	
	// Image selection
	$("#selectSegmentationMode").val('');
	
	$('#inputImage').on('change', function(e){
		var file = e.originalEvent.target.files[0];
		var reader = new FileReader();
		
		reader.onload = function(evt){
			//upload image
			socket.notify('Context.setImage', [reader.result]);
			$('#imgWorkingArea').attr("src", reader.result);
			updateStep(2);
		};
		reader.readAsDataURL(file); //base64 format
	});
	
	/*
	* Segmentation (step 1)
	*/
	$( "#selectSegmentationMode" ).change(function() {
		switch($('#selectSegmentationMode').val()){
			case 'SmartRegionSelector':
				socket.call(
					'SmartRegionSelector.isReady', [],
					function(result) { // On success (server replied)
						$('#loader').hide();
					},
					function(error)  { // An error was thrown.
						alert(error);
					}
				);
				$('#loader').show();
				renderCanvas();
				break;
		}
	});
	
});

var H=0,W=0;
function renderCanvas() {
	// check size
	H = $('#imgWorkingArea').height();
	W = $('#imgWorkingArea').width();
	
	// add fresh canvas of the correct size
	$('#canvasWorkingArea').remove();
	var newCanvas = $('<canvas id="canvasWorkingArea" class="overlay" width="' + W + '" height="' + H + '" />');
	$('#imgWorkingAreaOverlay').after(newCanvas);
	$('body').on('contextmenu', '#canvasWorkingArea', function(e){ return false; });
	
	var canvas = oCanvas.create({
		canvas: '#canvasWorkingArea',
		fps: 30
	});
	
	SmartRegionSelectorGUI.init(canvas, H, W, socket, 'imgWorkingAreaOverlay');
}


function updateStep(idStep) {
	$('div[id^=divStep]').hide();
	$('div[id=divStep' + idStep + ']').show();
}