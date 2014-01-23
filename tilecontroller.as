package
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class tilecontroller extends EventDispatcher
	{
		private var _currentSelection:int;
		private var _lockMovement:String;
		private var _lockPosition:Point;
		
		public var tiles:Vector.<Bitmap>;
		
		public function tilecontroller( target:IEventDispatcher=null )
		{
			tiles = new Vector.<Bitmap>();
			tilemanager.instance.tileRotation = 0;
			addStateListeners();
			_lockMovement = "unlock";
			super(target);
		}
		
		public function createMap( layers:int ):void {
			tilemodel.instance.createMap( (g_global.stageHeight - 64) / g_global.GRIDSIZE, g_global.stageWidth / g_global.GRIDSIZE, layers );
		}
		
		/*
		==============
		addStateListeners
		==============
		*/
		private function addStateListeners():void {
			g_global.stage.addEventListener( MouseEvent.MOUSE_DOWN, updateState );
			g_global.stage.addEventListener( MouseEvent.MOUSE_UP, updateState );
		}
		
		/*
		==============
		updateState
		==============
		*/
		private function updateState( e:MouseEvent=null ):void {
			var state:String;
			switch( e.type ) {
				case "mouseUp": 	state = "ready";
					break;
				
				case "mouseDown": 	state = "input";
					break;
				
				case "keyDown":		state = "input";
					break;
				
				case "keyUp":		state = "ready";
					break;
				
				default:			state = "ready";
					break;
			}
			tilemodel.instance.onStateChange( state );
		}
		
		/*
		==============
		setSelection
		
			tile selection has changed
		==============
		*/
		public function setSelection( index:int ):void {
			g_global.echo( "set new selection" );
			_currentSelection = index;
			tilemodel.instance.onSelectionChange();
			tilemanager.instance.setTileDimensions( tiles[_currentSelection].width, tiles[_currentSelection].height );
		}
		public function get currentSelection():int { return _currentSelection; }
		
		/*
		==============
		set currentRotation
		
			this is the rotation the tiles will be at when doing copypixels
		==============
		*/
		public function set currentRotation( val:int ):void { tilemanager.instance.tileRotation = val; }
		public function get currentRotation():int { return tilemanager.instance.tileRotation; }
		
		/*
		==============
		gridSelected
		
			selected the grid, update the tile nearest the mouseX and mouseY
		==============
		*/
		public function gridSelected( event:Event, selection:Object ):void {
			var tileState:String;
			switch( event.type ) {
				case "keyDown":
					var evt:KeyboardEvent = event as KeyboardEvent;
					if ( evt.keyCode == g_keys.SPACE ) {
						tileState = "removeTile";
					}
					if ( evt.keyCode == g_keys.ESCAPE ) {
						tilemodel.instance.onSave( null, hudcontroller.instance.onSave );
						return;
					}
					if ( evt.keyCode == g_keys.DOWN ) {
						//decrease brush size
					}
					if ( evt.keyCode == g_keys.UP ) {
						//increase brush size	
					}
					if ( evt.keyCode == g_keys.SHIFT ) {
						_lockMovement = _lockMovement == "unlock" ? "lock" : _lockMovement;
					}
					break;
				
				case "keyUp":
					g_global.echo( "movement unlocked" );
					_lockMovement = "unlock";
					break;
				
				case "mouseWheel":
					//add or subtract rotation
					if ( ( event as MouseEvent ).delta > 0 ) { currentRotation = currentRotation + 90 >= 360 ? 0 : currentRotation + 90; }
					else { currentRotation = currentRotation - 90 <= -360 ? 0 : currentRotation - 90; }
					return;
						
				default:
					tileState = "addTile";
					break;
			}
			//check to see that we are ready to add a tile and the event type is not a click event
			if ( tileState == "addTile" && event.type != "click" && tilemodel.instance.currentState == "ready" || tileState == "return" ) { return; }
			updateTiles( selection.x, selection.y, selection.tW, selection.tH, tileState, event.type );
		}
		
		/*
		==============
		gridSelected
		
			selected the grid, find the closest X and Y and place tile accordingly
		==============
		*/
		public function updateTiles( mouseX:Number, mouseY:Number, tilewidth:int, tileheight:int, addRemove:String="addTile", eventType:String="null" ):void {
			if ( _lockMovement == "setting" && Point.distance( new Point( mouseX, mouseY ), _lockPosition ) >= g_global.GRIDSIZE ) {
				var mPoint:Point = new Point( mouseX, mouseY );
				if ( Math.abs( mPoint.y - _lockPosition.y ) > Math.abs( mPoint.x - _lockPosition.x ) ) {
					_lockMovement = "x";
				} else {
					_lockMovement = "y";
				}
			} 
			else if ( _lockMovement == "lock" ) {
				//set position to the last tile placed, if that does not exist get the current closest grid position
				_lockPosition = g_global.getClosestGrid( mouseX, mouseY, tilewidth, tileheight );
				_lockMovement = "setting";
			}
			if ( _lockMovement == "setting" ) {
				return;
			}
			var posX:Number = _lockMovement != "x" ? mouseX : _lockPosition.x;
			var posY:Number = _lockMovement != "y" ? mouseY : _lockPosition.y;
			var closestGrid:Point = g_global.getClosestGrid( mouseX, mouseY, tilewidth, tileheight );
			
			if ( _lockMovement == "x" ) {
				closestGrid.x = _lockPosition.x;
			} else if ( _lockMovement == "y" ) {
				closestGrid.y = _lockPosition.y;
			}
			
			//check that we are not overlapping a tile if we are about to add, run this regardless if we are removing
			if ( addRemove == "removeTile" || !tilemodel.instance.evalArea( closestGrid.y / tileheight, closestGrid.x / tilewidth, currentSelection, tiles[ _currentSelection ] ) && addRemove == "addTile" ) {
				tilemanager.instance[addRemove]( closestGrid.x, closestGrid.y, tiles[ _currentSelection ] );
				tilemodel.instance[addRemove]( closestGrid.y / tileheight, closestGrid.x / tilewidth, currentSelection, tiles[ _currentSelection ], currentRotation );
			}
		}
	}
}