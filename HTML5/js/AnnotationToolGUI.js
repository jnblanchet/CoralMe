var AnnotationToolGUI = {	
	addRadialMenus: function(labels, scores) {		
		//update background map
		socket.call('Context.getMap', [],
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
					var h = Math.round(maxH * center[1]);
					var w = Math.round(maxW * center[0]);
					
					var id = 'radialMenu'+i;
					$('#divWorkingArea').append(
						'<div id="parent'+id+'" style="position:absolute; left:'+(w - 180)+'px; top:'+(h - 180)+'px; z-index:100;">' + 
							'<div id="'+id+'"></div>' + 
						'</div>'
					);
					var c = (Array.isArray(colors[i]) ? rgbToHex(colors[i]): rgbToHex(colors));
					var arr = this.fillRadialMenus(labels, i, scoresForThisRegion);
					$('#' + id).igRadialMenu({
						width: '360px',
						height: '360px',
						centerButtonContentHeight: 15,
						centerButtonContentWidth: 15,
						centerButtonClosedStroke: c,
						centerButtonStroke: c,
						centerButtonHotTrackStroke: c,
						outerRingFill : c,
						outerRingThickness: 10,
						menuOpenCloseAnimationDuration : 100,
						items: arr
					});
					var lblId = scoresForThisRegion.indexOf(Math.max(...scoresForThisRegion));
					
					// add tooltip
					$('#divWorkingArea').append(
						'<div id="toolTip'+id+'" style="position:absolute; left:'+(w + 20)+'px; top:'+h+'px; z-index:99; padding:0.5em; border:1px solid ' + c + '" ' +
						'class="ui-widget-content ui-corner-all">' + 
							labels[lblId] + ' (' + scoresForThisRegion[lblId] + '%)' +
						'</div>'
					);
					/*
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
					$('#' + id + ' canvas:first-child').trigger('click');*/
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
		var sliceBrightness = Math.min(255,Math.round(scores[i] * 255 / 80));
		return {
			name: 'button' + i,
			header: n + ' (' + scores[i] + '%)',
			iconUri: 'img/' + n + '.jpg',
			innerAreaFill: rgbToHex([sliceBrightness,sliceBrightness,sliceBrightness]),
			checkedHighlightBrush : "#FF0000",
			checkBehavior: 'radioButton',
			value: false,
			click: function (evt) {
				evt.item.isChecked = true;
				$('#radialMenu' + regionId).igRadialMenu("option", "isOpen", false);
			},
			checked: function (evt) {
				$('#' + 'toolTipradialMenu' + regionId).html(labels[i]);
            }
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