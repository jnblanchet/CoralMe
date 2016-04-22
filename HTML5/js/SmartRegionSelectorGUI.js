var SmartRegionSelectorGUI = SmartRegionSelectorGUI || {

	ocanvas: null, //ref to oCanvas
	H: [0],
	W: [0],
	imgDisplay: '',
	targetMarker: null, //currently selected marker
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
		
		ocanvas.bind('click', function (clickEvent) {
			if (clickEvent.which == 1 || clickEvent.which == 2)
				SmartRegionSelectorGUI.clickHandler(clickEvent, clickEvent.which);
		});
				
		ocanvas.bind('mousemove', function (moveEvent) {
			SmartRegionSelectorGUI.mouseMoveHandler(moveEvent);
		});
		
		ocanvas.bind("keydown", function (e) {
			if(e.which == SmartRegionSelectorGUI.ocanvas.keyboard.ESC)
				SmartRegionSelectorGUI.escKeyPressedHandler(e);
			if(e.which == 46) // delete 
				SmartRegionSelectorGUI.deleteKeyPressedHandler(e);
		});

	},
	
	copyingId: -1,
	clickHandler: function(clickEvent, buttonId) {
		switch (this.state) {
			case this.states.IDLE: // create (right click) or copy (left click)
				if (!this.targetMarker || buttonId == 2) {
					this.copyingId = -1; // first marker on new image is always create
				} else if (buttonId == 1) {
					this.copyingId = this.targetMarker.id;
				}
				
				var marker = this.createMarker(clickEvent.x,clickEvent.y);
				this.clearSelection(); this.updateSelection(marker);
				this.state = this.states.RESIZING;
				break;
			case this.states.RESIZING: // lock size
				this.targetMarker.removeChild(this.sizeCircle);
				this.state = this.states.IDLE;
				var y = this.targetMarker.x / this.W;
				var x = this.targetMarker.y / this.H;
				var r = (this.sizeCircle) ? this.sizeCircle.radius / this.W : 0.15;
				this.sizeCircle = null;
				obj = this;
				if (this.copyingId == -1) {
					// create blob
					this.connectedSocket.call(
						'SmartRegionSelector.createBlob', [x,y,r],
						function(result) {
							// update backgroundImage
							obj.idMap[obj.targetMarker.id] = result;
							obj.updateBackground();
						}
					);
				} else {
					var id = obj.idMap[this.copyingId];
					// copy blob
					this.connectedSocket.call(
						'SmartRegionSelector.copyBlobToLocation', [id,x,y,r],
						function(result) {
							// update backgroundImage
							obj.idMap[obj.targetMarker.id] = result;
							obj.updateBackground();
						}
					);
				}
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
	
	escKeyPressedHandler: function(keyEvent) {
		switch (this.state) {
			case this.states.IDLE: // clear selection
				this.clearSelection();
				this.ocanvas.redraw();
				break;
			case this.states.RESIZING: // cancel blob creation
				this.targetMarker.removeChild(this.sizeCircle);
				this.sizeCircle = null;
				this.ocanvas.removeChild(this.targetMarker);
				this.clearSelection();
				this.state = this.states.IDLE;
				this.ocanvas.redraw();
				break;
			case this.states.MOVING:
				break;
		}
	},
	deleteKeyPressedHandler: function(keyEvent) {
		switch (this.state) {
			case this.states.IDLE: // clear selection
				obj = this;
				this.connectedSocket.call('SmartRegionSelector.deleteBlob', [this.idMap[this.targetMarker.id]],
					function(result) {
						// update backgroundImage
						obj.ocanvas.removeChild(obj.targetMarker);
						obj.idMap.delete(obj.targetMarker.id);
						obj.targetMarker = null;
						obj.updateBackground();
					}
				);	
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
	},
	
	clearSelection: function(){
		if (this.targetMarker) {
			this.targetMarker.stroke = '2px #f90'; // normal settings
			this.targetMarker.radius = 5;
		}
		this.targetMarker = null;
	},
	updateSelection: function(marker){
		this.clearSelection();
		this.targetMarker = marker; // selection settings
		this.targetMarker.stroke = '2px #0f0';
		this.targetMarker.radius = 7;
	},
	
	createMarker: function(x,y){
		var marker = this.ocanvas.display.arc({
					x: x,
					y: y,
					radius: 4,
					start: 0,
					end: 360,
					fill: '#fff'
				});
		this.ocanvas.addChild(marker);
		return marker;
	}
};