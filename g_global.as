package
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;

	public class g_global
    {
		public static const LAYER_NAMES:Array	= [ "grid","tiles","collisions","hud" ];
		public static const GRIDSIZE:int = 16;
        public static var stageWidth:int = 960;
        public static var stageHeight:int = 768;
		public static var stage:Stage;
        
		/*
		==============
        addLayers
		==============
		*/
		public static function addLayers( parent:DisplayObjectContainer=null ):void {
			var i:int;
			parent = !parent ? stage : parent;
			for ( ; i < LAYER_NAMES.length; i++ ) {
				var spr:Sprite = new Sprite();
				spr.name = LAYER_NAMES[ i ];
                parent.addChild( spr );
			}
		}
		
		/*
		==============
		addLayersTo
		
			Adds multiple containers to a parent already created
		==============
		*/
		public static function addLayersTo( parentName:String, layers:int ):void {
			var parent:DisplayObjectContainer = getAsset( parentName );
			var i:int;
			for ( ; i < layers; i++ ) {
				var spr:Sprite = new Sprite();
				spr.name = parentName + "_" + i;
				parent.addChild( spr );
			}
		}
		
		/*
		==============
		getAsset
		==============
		*/
		public static function getAsset( name:String, parent:DisplayObjectContainer=null ):Sprite {
			parent = !parent ? stage : parent;
			return parent.getChildByName( name ) as Sprite;
		}
		
		/*
		==============
		getDate
		==============
		*/
		public static function getDate():String {
			var date:Date = new Date();
			return date.fullYear + "_" + (date.month+1) + "_" + date.date;
		}
		
		/*
		==============
		echo
		
			Better trace
		==============
		*/
		public static function echo( str:* ):void { 
			//get the caller name
			var stack:Array = new Error().getStackTrace().split( "\n" );
			stack = stack[2].split( " " );
			stack[1] = stack[1].replace( /\$/g, "" );
			var className:String = stack[1].split( "/" )[0];
			
			trace( "[" +  className + "] --> " + str ); 
		}
		
		/*
		==============
		getClosestGrid
		==============
		*/
		public static function getClosestGrid( x:Number, y:Number, tilewidth:int=16, tileheight:int=16 ):Point {
			var closestX:int, closestY:int, i:int;
			var max:int 		= int.MAX_VALUE;
			var rows:Number 	= ( g_global.stageHeight - 64 ) / tileheight; //subtract 64 to compensate for hud
			var columns:Number 	= ( g_global.stageWidth - 64 ) / tilewidth;
			var d:Number;
			
			//find the closest Y value to mouseY
			for ( i = 0; i < rows; i++ ) {
				d = Math.abs( y - ( i * tileheight + tileheight/2 ) );
				if ( d < max ) { max = d; closestY = i * tileheight; }
			}
			
			max = int.MAX_VALUE;
			//find the closest X value to mouseX
			for ( i = 0; i < columns; i++ ) {
				d = Math.abs( x - ( i * tilewidth + tilewidth/2 ) );
				if ( d < max ) { max = d; closestX = i * tilewidth; }
			}
			
			return new Point( closestX, closestY );
		}
	}
}