var GraphCutMergeToolGUI = {

	ocanvas: null, //ref to oCanvas
	H: [0],
	W: [0],
	imgDisplay: '',
	states: {IDLE: 1, MERGING: 2},
	state: null,
	connectedSocket: null,
	
	init: function(ocanvas, H, W, connectedSocket, imgDisplay) {
		// set all variables to their initial state
		this.isUpdating = false;
		this.requeueUpdate = false;
		// set others using arguments
		this.ocanvas = ocanvas;
		this.H = H; this.W = W;
		this.imgDisplay = imgDisplay;
		this.state = this.states.IDLE;
		this.connectedSocket = connectedSocket;
		
		obj = this;				
		ocanvas.bind('mousedown', function (clickEvent) {
			obj.mouseDownHandler(clickEvent);
		});
		
		ocanvas.bind('mouseup', function (clickEvent) {
			obj.mouseUpHandler(clickEvent);
		});
		ocanvas.bind('mousemove', function (moveEvent) {
			obj.mouseMoveHandler(moveEvent);
		});
		ocanvas.bind("keydown", function (keyEvent) {
			if(e.which == obj.ocanvas.keyboard.ESC)
				obj.escKeyPressedHandler(keyEvent);
		});

	},
	
	cutLine: null,
	mouseMoveHandler: function(moveEvent) {
		switch (this.state) {
			case this.states.IDLE:
				break;
			case this.states.MERGING:
			if (!this.cutLine)
			{
				this.cutLine = this.ocanvas.display.line({
					start: { x: this.startPoint[0], y: this.startPoint[1] },
					end: { x: moveEvent.x, y: moveEvent.y },
					stroke: "3px #ff0",
					cap: "round"
				});
				this.ocanvas.addChild(this.cutLine);
			}
			this.cutLine.end = { x: moveEvent.x, y: moveEvent.y };
			this.ocanvas.redraw();
				break;
		}
	},
	
	startPoint: null,
	mouseDownHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.IDLE:
					this.startPoint = new Array(clickEvent.x,clickEvent.y);
					this.state = this.states.MERGING;
				break;
		}
	},
	mouseUpHandler: function(clickEvent) {
		switch (this.state) {
			case this.states.MERGING:
				this.mergeCut(clickEvent.which == 1);
				this.clearCutLine();
				break;
		}
	},
	escKeyPressedHandler: function(keyEvent) {
		switch (this.state) {
			case this.states.IDLE:
				break;
			case this.states.MERGING:
				clearCutLine();
				break;
		}
	},

		
	clearCutLine: function(keyEvent) {
		this.ocanvas.removeChild(this.cutLine);
		this.cutLine = null;
		this.state = this.states.IDLE;
	},
	
	mergeCut: function(isMerge) {
		var x0 = this.cutLine.start['y'] / this.H, // matlab uses (y,x)
			x1 = this.cutLine.end['y'] / this.H,
			y0 = this.cutLine.start['x'] / this.W,
			y1 = this.cutLine.end['x'] / this.W;
		obj = this;
		var method = isMerge ? 'merge' : 'cut';
		this.connectedSocket.call('GraphCutMergeTool.' + method, [x0,y0,x1,y1],
			function(result) {
				obj.updateBackground();
			}
		);
	},
	
	isUpdating: false,
	requeueUpdate: false,
	updateBackground: function() {
		if(this.isUpdating){
			this.requeueUpdate = true;
		} else {
			loading();
			obj = this;
			this.connectedSocket.call('GraphCutMergeTool.getMap', [],
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
	}
};