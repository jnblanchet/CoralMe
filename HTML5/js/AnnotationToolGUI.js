var AnnotationToolGUI = {	
	addRadialMenus: function(labels, scores) {		
			//scores = predictClasses(this,trainDsName, testDsName)
			//get predictions when ready
		socket.call('RegionInfoProvider.getGoodRegionCenters', [],
				function(centers) {
					// position stuff
					var maxH = $('#imgWorkingArea').height();
					var maxW = $('#imgWorkingArea').width();
					// create radial menus everywhere
					for (var i=0;i<centers.length;i++) {
						var scoresForThisRegion = scores[i];
						var center = (Array.isArray(centers[i]) ? centers[i]: centers);
						var h = Math.round(maxH * center[1])-160;
						var w = Math.round(maxW * center[0])-160;
						
						var id = 'radialMenu'+i;
						$('#divWorkingArea').append(
							'<div id="parent'+id+'" style="position:absolute; left:'+w+'px; top:'+h+'px; z-index:99;" class="radialmenuclass">' + 
								'<div id="'+id+'"></div>' + 
							'</div>'
						);
						var arr = this.fillRadialMenus(labels, i, scoresForThisRegion);
						$('#' + id).igRadialMenu({
							width: '320px',
							height: '320px',
							centerButtonContentHeight: 15,
							centerButtonContentWidth: 15,
							centerButtonClosedStroke: '#000',
							centerButtonStroke: '#000',
							centerButtonHotTrackStroke: '#66CC00',
							outerRingFill : '#339900',
							outerRingThickness: 10,
							menuOpenCloseAnimationDuration : 100,
							items: arr
						});
						var id = scoresForThisRegion.indexOf(Math.max(...scoresForThisRegion));
						
						// add tooltip
						$('#parent' + id).igPopover( {
							direction: 'right',
							position: 'start',
							closeOnBlur: false,
							animationDuration: 150,
							maxHeight: null,
							maxWidth: null,
							headerTemplate: {
								closeButton: true,
								title: labels[id] + ' (' + scoresForThisRegion[id] + '% certainty)'
							},
							showOn: "mouseenter"
						});
					}
					$('.radialmenuclass canvas:first-child').zIndex(102);
					
					// on mouse enter 101, bring out, on mouse out, bring back
					$('.radialmenuclass canvas:first-child').mouseenter(function() {
						$(this).parent().zIndex(101);
						$(this).parent().parent().zIndex(101);
					});
					$('.radialmenuclass canvas:first-child').mouseleave(function() {
						$(this).parent().zIndex(99);
						$(this).parent().parent().zIndex(99);
					});
				}
			);

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