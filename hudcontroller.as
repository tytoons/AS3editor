package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	public class hudcontroller
	{
		private static var _instance:hudcontroller;
		
		private var _collisionMap:Vector.<Sprite>;
		private var _onCompleteCallback:Function;
		private var _collisionBox:Sprite;
		
		public var activeLayer:DisplayObjectContainer;
		
		public function hudcontroller( pvt:privateclass ) {
			_collisionMap = new Vector.<Sprite>();
			activeLayer = g_global.getAsset( "tiles" );
		}
		
		public function onCollisionSelected( callback:Function = null ):void {
			_onCompleteCallback = callback;
			activeLayer.addEventListener( MouseEvent.MOUSE_DOWN, onGridSelect ); 
		}
		
		private function onGridSelect( e:MouseEvent ):void {
			g_global.echo( "adding collision" );
			var origin:Point = g_global.getClosestGrid( activeLayer.mouseX, activeLayer.mouseY );
			var newCollision:Sprite = new Sprite();
			newCollision.graphics.beginFill( 0x00FF00, 0.75 );
			newCollision.graphics.drawRect( 0, 0, 16, 16 );
			newCollision.graphics.endFill();
			newCollision.x = origin.x;
			newCollision.y = origin.y;
			newCollision.name = "collisionBox_" + _collisionMap.length;
			_collisionBox = newCollision;
			g_global.getAsset( "collisions" ).addChild( _collisionBox );
			
			
			activeLayer.removeEventListener( MouseEvent.MOUSE_DOWN, onGridSelect );
			g_global.stage.addEventListener( MouseEvent.MOUSE_MOVE, updateCollision );
			g_global.stage.addEventListener( MouseEvent.MOUSE_UP, stopCollision );
		}
		
		private function updateCollision( e:MouseEvent = null ):void {
			var nextPoint:Point = g_global.getClosestGrid( activeLayer.mouseX, activeLayer.mouseY );
			if ( nextPoint.x == _collisionBox.x && nextPoint.y == _collisionBox.y ) { return; }
			
			_collisionBox.graphics.clear();
			_collisionBox.graphics.beginFill( 0x00FF00, 0.5 );
			_collisionBox.graphics.drawRect( 0,0, nextPoint.x - _collisionBox.x, nextPoint.y - _collisionBox.y );
			_collisionBox.graphics.endFill();
		}
		
		private function stopCollision( e:MouseEvent ):void {
			g_global.echo( "collision box complete" );
			
			g_global.stage.removeEventListener( MouseEvent.MOUSE_MOVE, updateCollision );
			g_global.stage.removeEventListener( MouseEvent.MOUSE_UP, stopCollision );
			
			_collisionMap.push( _collisionBox );
			
			if ( _onCompleteCallback != null ) {
				_onCompleteCallback();
			}
		}
		
		//this is called automatically from the tilemodel when passed from tilecontroller
		public function onSave( e:Event ):void {
			var mapName:String = "map_" + g_global.getDate();
			
			var mapBytes:ByteArray = new ByteArray();
			mapBytes.writeObject( _collisionMap );
			
			var saveFile:FileReference = new FileReference();
			saveFile.save( mapBytes, mapName + "_collisions.txt" );
		}
		
		public static function get instance():hudcontroller { return _instance = _instance ? _instance : new hudcontroller( new privateclass() ); }
	}
}

class privateclass{}