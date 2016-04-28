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
	$('#resizeFactorSpRange').on("change mousemove", function() {
		$('#resizeFactorSpDisplay').html($(this).val() + ' %');
	});
	$('#regionSizeRange').on("change mousemove", function() {
		$('#regionSizeDisplay').html($(this).val() + ' px');
	});
	$('#regularizerRange').on("change mousemove", function() {
		$('#regularizerDisplay').html(Math.round(Math.pow(10,$(this).val() / 10)));
	});
	$('#graphCutRatioRange').on("change mousemove", function() {
		$('#graphCutRatioDisplay').html($(this).val() + ' %');
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
		switch($('#selectSegmentationMode').val()) {
			case 'SmartRegionSelector':
				socket.call(
					'SmartRegionSelector.isReady', [],
					function(result) { // On success (server replied)
						done();
						initSmartRegionSelector();
					}
				);
				loading();
				
				break;
			case 'SuperPixelExtractor':
				socket.call(
					'SuperPixelExtractor.isReady', [],
					function(result) {
						initSuperPixelExtractor();
						done();
					}
				);
				loading();
				break;
		}
	});
	$('#doneSegmentationButton').click(function() {
		updateStep(3);
		jQuery("#divWorkingArea").detach().appendTo('#divWorkingArea2'); // keep background image
		$('#canvasWorkingArea').remove(); // remove any existing canvas
		renderCanvas(2, 'imgWorkingAreaOverlay');
	});
	
	/*
	 * Segmentation (step 2)
	 */
		
	
	
});

function initSmartRegionSelector() {
	// set parameters
	loading();
	socket.call('SmartRegionSelector.getResizeFactor', [],
		function(result) {
			$("#resizeFactorRange").val(Math.round(result * 100));
			$('#resizeFactorDisplay').html(Math.round(result*100) + ' %');
		}
	);
	socket.call('SmartRegionSelector.getKernelSize', [],
			function(result) {
				$("#kernelSizeRange").val(result);
				$('#kernelSizeDisplay').html(result + ' px');
				done();
			}
		);

	// set binding for future parameter tuning
	$("#resizeFactorRange").change(function() {
		loading();
		socket.call('SmartRegionSelector.setResizeFactor', [parseInt($("#resizeFactorRange").val()) / 100],
			function(result) {renderCanvas(1); done();}
		);
	});
	$("#kernelSizeRange").change(function() {
		loading();
		socket.call('SmartRegionSelector.setKernelSize', [parseInt($("#kernelSizeRange").val())],
			function(result) {renderCanvas(1); done();}
		);
	});
	
	renderCanvas(1);
}

var H=0,W=0;
var canvas = null;
function renderCanvas(stepId) {	
	// check size
	H = $('#imgWorkingArea').height();
	W = $('#imgWorkingArea').width();
	
	// add fresh canvas of the correct size
	$('#canvasWorkingArea').remove();
	var newCanvas = $('<canvas id="canvasWorkingArea" class="overlay" width="' + W + '" height="' + H + '" />');
	$('#imgWorkingAreaOverlay').after(newCanvas);
	$('body').on('contextmenu', '#canvasWorkingArea', function(e){ return false; });
	
	if(canvas)
		canvas.destroy();
	
	canvas = oCanvas.create({
		canvas: '#canvasWorkingArea',
		fps: 30
	});
	
	if (stepId == 1) {
		$('#imgWorkingAreaOverlay').attr('src', '');
		SmartRegionSelectorGUI.init(canvas, H, W, socket, 'imgWorkingAreaOverlay');
		// show and init properties
		$('.options').hide();
		$('#SmartRegionSelectorProperties').show();
	}
	else if(stepId == 2){
		GraphCutMergeToolGUI.init(canvas, H, W, socket, 'imgWorkingAreaOverlay');
	}
}

function initSuperPixelExtractor() {	
	// set parameters
	loading();
	socket.call('SuperPixelExtractor.getResizeFactor', [],
		function(result) {
			$("#resizeFactorSpRange").val(Math.round(result * 100));
			$('#resizeFactorSpDisplay').html(Math.round(result*100) + ' %');
		}
	);
	socket.call('SuperPixelExtractor.getRegionSize', [],
			function(result) {
				$("#regionSizeRange").val(result);
				$('#regionSizeDisplay').html(result + ' px');
				done();
			}
		);
	socket.call('SuperPixelExtractor.getRegularizer', [],
			function(result) {
				$("#regularizerRange").val(Math.round(Math.log(result)/0.23025)); // log(10) * 1/10 (log base conversion * slider multiplier)
				$('#regularizerDisplay').html(Math.round(result));
				done();
			}
		);
	socket.call('SuperPixelExtractor.getGraphCutRatio', [],
			function(result) {
			$("#graphCutRatioRange").val(Math.round(result * 100));
			$('#graphCutRatioDisplay').html(Math.round(result*100) + ' %');
				done();
			}
		);
		
	// set binding for futur parameter tuning
	$("#resizeFactorSpRange").change(function() {
		loading();
		socket.call('SuperPixelExtractor.setResizeFactor', [parseInt($("#resizeFactorSpRange").val()) / 100],
			function(result) { done();}
		);
	});
	$("#regionSizeRange").change(function() {
		loading();
		socket.call('SuperPixelExtractor.setRegionSize', [parseInt($("#regionSizeRange").val())],
			function(result) { done(); }
		);
	});
	$("#regularizerRange").change(function() {
		loading();
		socket.call('SuperPixelExtractor.setRegularizer', [Math.pow(10,parseInt($("#regularizerRange").val()) / 10)],
			function(result) { done(); }
		);
	});
	$("#graphCutRatioRange").change(function() {
		loading();
		socket.call('SuperPixelExtractor.setGraphCutRatio', [parseInt($("#graphCutRatioRange").val()) / 100],
			function(result) { done(); }
		);
	});
	// empty the overlay
	$('#imgWorkingAreaOverlay').attr('src', '');
	
	// bind button to update
	$('#updateSuperpixelsButton').click(function() {
		loading();
		socket.call('SuperPixelExtractor.getMap', [],
			function(result) {
				$('#imgWorkingAreaOverlay').attr("src", result);
				done();
			}
		);
	});


	// show and init properties
	$('.options').hide();
	$('#SuperPixelExtractorProperties').show();
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