var SmartRegionSelectorGUI = SmartRegionSelectorGUI || {

	ocanvas: null, //ref to oCanvas
	H: [0],
	W: [0],
	imgDisplay: '',
	targetMarker: null, //currently selected marker
	idMap: {}, // a map object mapping local ids to server ids
	states: {IDLE: 1, RESIZING: 2, MOVING: 3},
	state: null,
	connectedSocket: null,
	
	init: function(ocanvas, H, W, connectedSocket, imgDisplay) {
		this.ocanvas = ocanvas;
		this.H = H; this.W = W;
		this.imgDisplay = imgDisplay;
		this.state = this.states.IDLE;
		this.connectedSocket = connectedSocket;
		
		ocanvas.bind('click', function (clickEvent) {
			switch (clickEvent.which) {
				case 1: // left click
					SmartRegionSelectorGUI.leftClickHandler(clickEvent);
					break;
			}
		});
		ocanvas.bind('mousemove', function (moveEvent) {
			SmartRegionSelectorGUI.mouseMoveHandler(moveEvent);
		});
	},
	
	leftClickHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.IDLE:
				var marker = this.ocanvas.display.arc({
						x: clickEvent.x,
						y: clickEvent.y,
						radius: 4,
						start: 0,
						end: 360,
						stroke: '2px #ff0',
						fill: '#f90'
					});
				this.targetMarker = marker;
				this.ocanvas.addChild(marker);
				this.state = this.states.RESIZING;
				break;
			case this.states.RESIZING:
				this.targetMarker.removeChild(this.sizeCircle);
				this.state = this.states.IDLE;
				var y = this.targetMarker.x / this.W;
				var x = this.targetMarker.y / this.H;
				var r = this.sizeCircle.radius / this.W;
				this.sizeCircle = null;
				obj = this;
				// create blob
				this.connectedSocket.call(
					'SmartRegionSelector.createBlob', [x,y,r],
					function(result) {
						// update backgroundImage
						obj.idMap[obj.targetMarker.id] = result;
						obj.updateBackground();
					}
				);
				
				break;
			case this.states.MOVING:
				break;
		}
	},
	
	sizeCircle: null,
	mouseMoveHandler: function(moveEvent) {
		switch (this.state) {
			case this.states.IDLE:
				break;
			case this.states.RESIZING:
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
					this.targetMarker.addChild(this.sizeCircle);
				}
				this.sizeCircle.radius = Math.round(Math.sqrt((this.targetMarker.x - moveEvent.x)*(this.targetMarker.x - moveEvent.x)+(this.targetMarker.y - moveEvent.y)*(this.targetMarker.y - moveEvent.y)));
				this.ocanvas.redraw();
				break;
			case this.states.MOVING:
				break;
		}
	},
	
	isUpdating: false,
	requeueUpdate: false,
	updateBackground: function() {
		if(this.isUpdating){
			this.requeueUpdate = true;
		} else {
			$('#loader').show();
			obj = this;
			this.connectedSocket.call('SmartRegionSelector.getMap', [],
				function(result) {
					obj.isUpdating = false;
					$('#' + obj.imgDisplay).attr("src", result);
					
					if(obj.requeueUpdate) { // call it again if needed
						requeueUpdate = false;
						obj.updateBackground();
					}
					$('#loader').hide();
				}
			);
		}

	}
};