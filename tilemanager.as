package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class tilemanager
	{
		private var _parent:DisplayObjectContainer;
		private var _canvas:Bitmap;
		private var _tileRotation:int;
		private var _tileWidth:int;
		private var _tileHeight:int;
		
		public var lastTile:Point;
		
		private static var _instance:tilemanager;
		
		public function tilemanager( pvt:privateclass ) { 
			_parent = g_global.getAsset( "tiles" );
			_canvas = new Bitmap( new BitmapData( g_global.getAsset( "grid" ).width, g_global.getAsset( "grid" ).height, true, 0 ) );
			_parent.addChild( _canvas );
		}
		
		public function setTileDimensions( w:int, h:int ):void {
			_tileWidth = w;
			_tileHeight = h;
		}
		
		public function addTile( x:Number, y:Number, tile:Bitmap, brushSize:int=g_global.GRIDSIZE ):void {
			var bmd:BitmapData = tile.bitmapData;
			_canvas.bitmapData.unlock();
			//copy new tile
			if ( _tileRotation != 0 ) {
				//create a matrix and position it for the rotation of the tile
				var mat:Matrix = new Matrix();
				mat.translate( -_tileWidth / 2, -_tileHeight / 2 );
				mat.rotate( tileRotation * Math.PI / 180 );
				mat.translate( _tileWidth /2, _tileHeight / 2 );
			
				//create new bitmap data
				var matrixBmd:BitmapData = new BitmapData( _tileWidth, _tileHeight, false, 0 );
				matrixBmd.draw( tile.bitmapData, mat );
				bmd = matrixBmd;
				
				//add to canvas
				_canvas.bitmapData.copyPixels( bmd, tile.bitmapData.rect, new Point( x, y ), null, null, true );
				
				//remove created bitmap data
				bmd.dispose();
			} else {
				_canvas.bitmapData.copyPixels( bmd, tile.bitmapData.rect, new Point( x, y ), null, null, true );
			}
			lastTile = new Point( x, y );
			_canvas.bitmapData.lock();
		}
		
		public function removeTile( x:Number, y:Number, tile:Bitmap, brushSize:int=g_global.GRIDSIZE ):void {
			_canvas.bitmapData.unlock();
			//clear this tile location
			_canvas.bitmapData.fillRect( new Rectangle( x, y, brushSize, brushSize ), 0xFFFFFF );
			_canvas.bitmapData.lock();
		}
		
		/*
		===============================================================================
		
		Accessors and Mutators
		
		===============================================================================
		*/
		//read only
		public function get tileWidth():int { return _tileWidth; }
		public function get tileHeight():int { return _tileHeight; }
		public function get parent():DisplayObjectContainer { return _parent; }
		public function get tileRotation():int { return _tileRotation; }
		
		//write
		public function set tileRotation( rotate:int ):void { _tileRotation = rotate; }
		public function set parent( p:DisplayObjectContainer ):void { _parent = p; }
		
		//singleton instance
		public static function get instance():tilemanager { return _instance = !_instance ? new tilemanager( new privateclass() ) : _instance; }
	}
}

class privateclass{}