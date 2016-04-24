var SmartRegionSelectorGUI = SmartRegionSelectorGUI || {

	ocanvas: null, //ref to oCanvas
	H: [0],
	W: [0],
	imgDisplay: '',
	idMap: new Map(), // a map object mapping local ids to server ids
	states: {IDLE: 1, RESIZING: 2, MOVING: 3},
	state: null,
	connectedSocket: null,
	
	init: function(ocanvas, H, W, connectedSocket, imgDisplay) {
		this.ocanvas = ocanvas;
		this.H = H; this.W = W;
		this.imgDisplay = imgDisplay;
		this.state = this.states.IDLE;
		this.connectedSocket = connectedSocket;
		
		obj = this;
		ocanvas.bind('click', function (clickEvent) {
			if (clickEvent.which == 1)
				obj.leftClickHandler(clickEvent);
			else if (clickEvent.which == 2)
				obj.rightClickHandler(clickEvent);
		});
				
		ocanvas.bind('mousedown', function (clickEvent) {
			if (clickEvent.which == 2)
				obj.mouseDownHandler(clickEvent);
		});
		
		ocanvas.bind('mouseup', function (clickEvent) {
			if (clickEvent.which == 2)
				obj.mouseUpHandler(clickEvent);
		});
		ocanvas.bind('mousemove', function (moveEvent) {
			obj.mouseMoveHandler(moveEvent);
		});
		
		ocanvas.bind("keydown", function (e) {
			if(e.which == obj.ocanvas.keyboard.ESC)
				obj.escKeyPressedHandler(e);
			if(e.which == 46) // delete 
				obj.deleteKeyPressedHandler(e);
		});

	},
	
	copyingId: -1,
	leftClickHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.IDLE: //  extend (copy) current selected group, or create a new one
				this.createOrCopyMarker(clickEvent);
				break;
			case this.states.RESIZING: // lock size
				this.confirmMarkerSize(clickEvent);
				break;
			case this.states.MOVING:
				break;
		}
	},
	rightClickHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.IDLE:
				this.selectNearestMarker(clickEvent.x,clickEvent.y); // select nearest marker
				break;
			case this.states.RESIZING: // lock size
				this.selectNearestMarker(clickEvent.x,clickEvent.y);
				break;
			case this.states.MOVING:
				break;
		}
	},
	mouseMoveHandler: function(moveEvent) {
		switch (this.state) {
			case this.states.IDLE:
				break;
			case this.states.RESIZING:
				this.selectingMarkerSize(moveEvent.x,moveEvent.y);
				break;
			case this.states.MOVING:
				this.selectedMarker.x = moveEvent.x;
				this.selectedMarker.y = moveEvent.y;
				this.ocanvas.redraw();
				break;
		}
	},
	mouseDownHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.IDLE:
				if (this.selectedMarker) {
					this.selectedMarker.x = clickEvent.x;
					this.selectedMarker.y = clickEvent.y;
					this.ocanvas.redraw();
					this.state = this.states.MOVING;
				}
				break;
			case this.states.RESIZING:
				break;
			case this.states.MOVING:
				break;
		}
	},
	mouseUpHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.IDLE:
				break;
			case this.states.RESIZING:
				break;
			case this.states.MOVING:
				this.moveMarkerToLocation(this.selectedMarker,clickEvent.x,clickEvent.y);
				this.state = this.states.IDLE;
				break;
		}
	},
	escKeyPressedHandler: function(keyEvent) {
		switch (this.state) {
			case this.states.IDLE: // clear selection
				this.clearSelection();
				break;
			case this.states.RESIZING:
				this.cancelBlobCreation();
				break;
			case this.states.MOVING:
				break;
		}
	},
	deleteKeyPressedHandler: function(keyEvent) {
		switch (this.state) {
			case this.states.IDLE: // clear selection
				obj = this;
				this.connectedSocket.call('SmartRegionSelector.deleteBlob', [this.idMap[this.selectedMarker.id]],
					function(result) {
						// update backgroundImage
						obj.ocanvas.removeChild(obj.selectedMarker);
						obj.idMap.delete(obj.selectedMarker.id);
						obj.selectedMarker = null;
						obj.updateBackground();
					}
				);	
				break;
		}
	},
	
	selectedMarker: null, //currently selected marker
	markerInProgress: null, //creation in progress marker
	createOrCopyMarker: function(clickEvent) {
		if (this.selectedMarker) //  TODO: remove this comment "&& this.selectedMarker.id in this.idMap" if markers are created too quickly, they do not register with server fast enough: we treat it as a create instead of copy
			this.copyingId = this.selectedMarker.id;
		else
			this.copyingId = -1;
		
		this.markerInProgress = this.createMarker(clickEvent.x,clickEvent.y);
		this.state = this.states.RESIZING;
	},
		
	confirmMarkerSize: function(moveEvent) {
		this.markerInProgress.removeChild(this.sizeCircle);
		this.state = this.states.IDLE;
		var y = this.markerInProgress.x / this.W;
		var x = this.markerInProgress.y / this.H;
		var params = (this.sizeCircle) ? [x,y,this.sizeCircle.radius/this.W] : [x,y]; //include radius if it was defined
		this.sizeCircle = null;
		obj = this;
		
		if (this.copyingId == -1) {
			// create blob
			this.connectedSocket.call(
				'SmartRegionSelector.createBlob', params,
				function(result) {
					// update backgroundImage
					obj.idMap[obj.markerInProgress.id] = result;
					if(!obj.selectedMarker)
						obj.updateSelection(obj.markerInProgress);
					obj.updateBackground();
				}
			);
		} else {
			params.unshift(obj.idMap[this.copyingId]);
			// copy blob
			this.connectedSocket.call(
				'SmartRegionSelector.copyBlobToLocation', params,
				function(result) {
					// update backgroundImage
					obj.idMap[obj.markerInProgress.id] = result;
					obj.updateBackground();
				}
			);
		}
	},
		
	sizeCircle: null,
	selectingMarkerSize: function(x,y) {
		if (!this.sizeCircle)
		{
			this.sizeCircle = this.ocanvas.display.arc({
				x: 0,
				y: 0,
				radius: 10,
				start: 0,
				end: 360,
				stroke: '2px #ff0',
			});
			this.markerInProgress.addChild(this.sizeCircle);
		}
		this.sizeCircle.radius = Math.round(Math.sqrt((this.markerInProgress.x - x)*(this.markerInProgress.x - x)+(this.markerInProgress.y - y)*(this.markerInProgress.y - y)));
		this.ocanvas.redraw();
	},	
		
	cancelBlobCreation: function(keyEvent) {
		this.markerInProgress.removeChild(this.sizeCircle);
		this.sizeCircle = null;
		this.ocanvas.removeChild(this.markerInProgress);
		this.state = this.states.IDLE;
	},
	
	
	isUpdating: false,
	requeueUpdate: false,
	updateBackground: function() {
		if(this.isUpdating){
			this.requeueUpdate = true;
		} else {
			loading();
			obj = this;
			this.connectedSocket.call('SmartRegionSelector.getMap', [],
				function(result) {
					obj.isUpdating = false;
					$('#' + obj.imgDisplay).attr("src", result);
					
					if(obj.requeueUpdate) { // call it again if needed
						requeueUpdate = false;
						obj.updateBackground();
					}
					done();
				}
			);
		}
	},
	
	moveMarkerToLocation: function(marker,x,y) {
		obj = this;
		y = this.markerInProgress.x / this.W;
		x = this.markerInProgress.y / this.H;
		this.connectedSocket.call (
			'SmartRegionSelector.moveBlob', [obj.idMap[marker.id], x, y],
			function(result) {
				// update backgroundImage
				obj.updateBackground();
			}
		);
	},
	
	clearSelection: function(){
		if (this.selectedMarker) {
			this.selectedMarker.stroke = '2px #f90'; // normal settings
			this.selectedMarker.radius = 5;
		}
		this.selectedMarker = null;
		this.ocanvas.redraw();
	},
	updateSelection: function(marker){
		this.clearSelection();
		this.selectedMarker = marker; // selection settings
		this.selectedMarker.stroke = '2px #0f0';
		this.selectedMarker.radius = 7;
		this.ocanvas.redraw();
	},
	
	createMarker: function(x,y){
		var marker = this.ocanvas.display.arc({
					x: x,
					y: y,
					radius: 4,
					start: 0,
					end: 360,
					stroke: '2px #f90',
					fill: '#fff'
				});
		this.ocanvas.addChild(marker);
		return marker;
	},
	
	selectNearestMarker: function(x,y){
		var bestDist = 10e10;
		var bestMarker = null;
		for (i = 0; i < this.ocanvas.children.length; i++) {
			var object = this.ocanvas.children[i];
			if(!object.id in this.idMap)
				continue;
			var d = (object.x - x)*(object.x - x)+(object.y - y)*(object.y - y);
			if (d < bestDist) {
				bestDist = d;
				bestMarker = object;
			}
		}
		if (bestMarker)
			this.updateSelection(bestMarker);
	}
	
};