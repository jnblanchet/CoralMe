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
	
	// Image selection and other parameters
	$("#selectSegmentationMode").val('');
	$('#resizeFactorRange').on("change mousemove", function() {
		$('#resizeFactorDisplay').html($(this).val() + ' %');
	});
	$('#kernelSizeRange').on("change mousemove", function() {
		$('#kernelSizeDisplay').html($(this).val() + ' px');
	});
	
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
						done();
					},
					function(error)  { // An error was thrown.
						alert(error);
					}
				);
				loading();
				initSmartRegionSelector();
				break;
		}
	});
	
});

function initSmartRegionSelector() {
	// set parameters
	loading();
	socket.call('SmartRegionSelector.getResizeFactor', [],
		function(result) {
			$("#resizeFactorRange").val(Math.round(result * 100));
			$('#resizeFactorDisplay').html(Math.round(result*100) + ' %');
			renderCanvas();
		}
	);
	socket.call('SmartRegionSelector.getKernelSize', [],
			function(result) {
				$("#kernelSizeRange").val(result);
				$('#kernelSizeDisplay').html(result + ' px');
				renderCanvas();
				done();
			}
		);

	// set binding for futur parameter tuning
	$("#resizeFactorRange").change(function() {
		loading();
		socket.call('SmartRegionSelector.setResizeFactor', [$("#resizeFactorRange").val() / 100],
			function(result) {done();}
		);
	});
	$("#kernelSizeRange").change(function() {
		loading();
		socket.call('SmartRegionSelector.setKernelSize', [$("#kernelSizeRange").val()],
			function(result) {done();}
		);
	});
	
	renderCanvas();
}

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
	
	// show and init properties
	$('.options').hide();
	$('#SmartRegionSelectorProperties').show();
}


function updateStep(idStep) {
	$('div[id^=divStep]').hide();
	$('div[id=divStep' + idStep + ']').show();
}

function loading() {
	$('#loader').show();
	$("input[type='range']").prop('disabled', true);
}

function done() {
	$('#loader').hide();
	$("input[type='range']").prop('disabled', false);
}