package
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class tilemodel extends EventDispatcher
	{
		private var _currentState:String;
		private var _map:Vector.<Vector.<Vector.<Object>>>;
		
		private static var _instance:tilemodel;
		
		public function tilemodel( pvt:privateclass ) {
			_map = new Vector.<Vector.<Vector.<Object>>>();
			_currentState = "ready";
		}
		
		public function createMap( rows:int, columns:int, layers:int ):void {
			var i:int, j:int, m:int;
			for ( m = 0; m < layers; m++ ) {
				_map[m] = new Vector.<Vector.<Object>>();
				for ( i = 0; i < rows; i++ ) {
					_map[m][i] = new Vector.<Object>();
					for ( j = 0; j < columns; j++ ) {
						_map[m][i][j] = null;
					}
				}
			}
			g_global.echo( "map created: " + rows + " , " + columns + " Layers: " + layers );
		}
		
		public function addTile( row:int, column:int, layer:int, tile:Bitmap, rotation:int=0 ):void {
			//all textures are n^2
			if ( tile.width > g_global.GRIDSIZE ) {
				var currentRow:int = row;
				var currentColumn:int = column;
				var currentSelection:Number = layer;
				var a:int = Math.pow( tile.width / g_global.GRIDSIZE, 2 );
				var i:int;
				//g_global.echo( "current value @: " + _map[layer][currentRow] );
				for ( i = 0; i < a; i++ ) {
					//row and column refers not only the grid but what ^2 pixel we are at in the tile for blitting later.
					//this will allow us to keep track of grid spaces that are sections of a bitmap
					//_map[layer] refers to which layer we need to access in relation to our asset index
					_map[layer][currentRow][currentColumn] = { tile:currentSelection, row:currentRow, column:currentColumn, rotation:rotation };
					//we are going to denote that the following grids are part of a larger tile
					currentSelection += .001;
					
					if ( currentRow + 1 < row + ( tile.height / g_global.GRIDSIZE ) ) {
						currentRow += 1;
					} else {
						currentRow -= ( ( tile.height / g_global.GRIDSIZE ) - 1 );
						currentColumn = currentColumn + 1 < column + ( tile.width / g_global.GRIDSIZE ) ? currentColumn + 1 : currentColumn;
					}
					//keep the storage inside the grid boundaries
					if ( currentRow >= _map[layer].length || currentColumn >= _map[layer][row].length ) { 
						return; 
					}
				}
			}
		}
		
		public function removeTile( row:int, column:int, layer:int, ...args ):void {
			_map[layer][row][column] = null;
		}
		
		
		public function evalArea( row:int, column:int, layer:int, tile:Bitmap ):Boolean {
			if ( _map[layer][row][column] == null ) {
				var i:int;
				var currentRow:int = row;
				var currentColumn:int = column;
				var a:int = Math.pow( tile.width / g_global.GRIDSIZE, 2 );
				for ( i = 0; i < a; i++ ) {
					//check for overlap
					if ( _map[layer][currentRow][currentColumn] ) { return true; }
					
					//no overlap, continue checking area
					if ( currentRow + 1 < row + ( tile.height / g_global.GRIDSIZE ) && currentRow + 1 < _map[layer].length ) {
						currentRow += 1;
					} else if ( currentColumn < _map[layer][row].length ) {
						currentRow -= ( ( tile.height / g_global.GRIDSIZE ) - 1 );
						currentColumn = currentColumn + 1 < column + ( tile.width / g_global.GRIDSIZE ) && currentColumn + 1 < _map[layer][row].length ? currentColumn + 1 : currentColumn;
					}
				}
			} 
			else { 
				return true; 
			}
			return false;
		}
		
		public function onSelectionChange():void { tilemanager.instance.tileRotation = 0; }
		public function onStateChange( type:String ):void { _currentState = type; }
		
		public function onSave( mapName:String = null, callback:Function = null ):void {
			mapName = mapName ? mapName : "map_" + g_global.getDate();
			
			var mapBytes:ByteArray = new ByteArray();
			mapBytes.writeObject( _map );
			
			var saveFile:FileReference = new FileReference();
			if ( callback != null ) {
				saveFile.addEventListener( Event.COMPLETE, callback );
			}
			saveFile.save( mapBytes, mapName + ".txt" );
		}
		
		/*
		===============================================================================
		
		Accessors and Mutators
		
		===============================================================================
		*/
		public function get currentState():String { return _currentState; }
		
		//singleton instance
		public static function get instance():tilemodel { return !_instance ? _instance = new tilemodel( new privateclass() ) : _instance; }
	}
}

class privateclass{}