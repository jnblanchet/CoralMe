var AnnotationToolGUI = {	
	addRadialMenus: function(labels, scores) {		
		//update background map
		socket.call('SmartRegionSelector.getMap', [],
			function(result) {
				$('#imgWorkingAreaOverlay').attr('src', result);
			}
		);
		//get predictions when ready
		socket.call('RegionInfoProvider.getGoodRegionCenters', [], function(centers) {
			socket.call('RegionInfoProvider.getRegionColors', [], function(colors) {
				// position stuff
				var maxH = $('#imgWorkingArea').height();
				var maxW = $('#imgWorkingArea').width();
				// create radial menus everywhere
				for (var i=0;i<centers.length;i++) {
					var scoresForThisRegion = (Array.isArray(scores[i]) ? scores[i]: scores);
					var center = (Array.isArray(centers[i]) ? centers[i]: centers);
					var h = Math.round(maxH * center[1])-160;
					var w = Math.round(maxW * center[0])-160;
					
					var id = 'radialMenu'+i;
					$('#divWorkingArea').append(
						'<div id="parent'+id+'" style="position:absolute; left:'+w+'px; top:'+h+'px; z-index:99;" class="radialmenuclass">' + 
							'<div id="'+id+'"></div>' + 
						'</div>'
					);
					var c = (Array.isArray(colors[i]) ? rgbToHex(colors[i]): rgbToHex(colors));
					var arr = this.fillRadialMenus(labels, i, scoresForThisRegion);
					$('#' + id).igRadialMenu({
						width: '320px',
						height: '320px',
						centerButtonContentHeight: 15,
						centerButtonContentWidth: 15,
						centerButtonClosedStroke: c,
						centerButtonStroke: c,
						centerButtonHotTrackStroke: c,
						outerRingFill : c,
						outerRingThickness: 10,
						menuOpenCloseAnimationDuration : 100,
						items: arr,
						opened: function (evt) {
							$(this).find('canvas').eq(0).igPopover('hide');
						},
						closed: function (evt) {
							var tt = $(this).find('canvas').eq(0);
							tt.igPopover('show');
							tt.trigger('click');
						}
					});
					var lblId = scoresForThisRegion.indexOf(Math.max(...scoresForThisRegion));
					
					// add tooltip
					$('#' + id + ' canvas:first-child').igPopover( {
						direction: 'right',
						position: 'start',
						closeOnBlur: false,
						animationDuration: 150,
						maxHeight: null,
						maxWidth: null,
						headerTemplate: {
							closeButton: true,
							title: labels[lblId] + ' (' + scoresForThisRegion[lblId] + '%)'
						},
						showOn: 'click'
					});
					$('#' + id + ' canvas:first-child').trigger('click');
				}
	
				/*for (var i=0;i<centers.length;i++) {
					$('.radialmenuclass canvas:first-child').
					
				}*/
				
				// on mouse enter 101, bring out, on mouse out, bring back
				/*$('.radialmenuclass canvas:first-child').mouseenter(function() {
					$(this).parent().zIndex(101);
					$(this).parent().parent().zIndex(101);
				});
				$('.radialmenuclass canvas:first-child').mouseleave(function() {
					$(this).parent().zIndex(99);
					$(this).parent().parent().zIndex(99);
				});*/
				

			})
		});

	}
}

function fillRadialMenus(labels, regionId, scores) {
	return jQuery.map( labels, function( n, i ) {
		return {
			name: 'button' + i,
			header: n + ' (' + scores[i] + '%)',
			iconUri: 'img/' + n + '.jpg',
			color: '#99FF33',
			checkedHighlightBrush : "#FF0000",
			checkBehavior: 'radioButton',
			click: function (evt) {
				evt.item.isChecked = true;
				$('#radialMenu' + regionId).igRadialMenu("option", "isOpen", false);
				// Get reference to the menu item object: evt.item;
			},
		}
	});
}

function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(rgb) {
    return "#" + componentToHex(rgb[0]) + componentToHex(rgb[1]) + componentToHex(rgb[2]);
}