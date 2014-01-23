package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class r_loader extends Loader
	{
		private var _loadedAssets:Dictionary;
		private var _assetPath:String;0
		private var _callback:Function;
		private var _loadState:String;
		private var _loadQue:Vector.<Object>;
		
		private static var _instance:r_loader;
		
		public function r_loader( pvt:privateclass ) {
			_loadedAssets = new Dictionary();
			_loadQue = new Vector.<Object>();
			_assetPath = "../assets/";
			_loadState = "ready";
			this.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
		}
		
		/*
		==============
		loadAsset
		==============
		*/
		private function loadAsset( path:String ):void {
			g_global.echo( "loading asset: " + path );
			_loadState = "loading";
			load( new URLRequest( path ) );
		}
		
		/*
		==============
		onComplete
		
		Asset finished loading, store asset into loaded array and do callback
		Continue through loadQue while it contains assets to be loaded
		==============
		*/
		private function onComplete( e:Event ):void {
			var bitmap:Bitmap = content as Bitmap;
			bitmap.smoothing = true;
			_loadedAssets[bitmap.name] = bitmap;
			_loadState = "ready";
			
			_callback( bitmap );
			
			if ( _loadQue.length > 0 ) {
				getAsset( _loadQue[ 0 ].name, _loadQue[0].callback );
				_loadQue.splice( 0, 1 );
			}
		}
		
		/*
		==============
		getAsset
		
		Return asset or load asset if it is not stored in the loadedAssets container
		If an asset is currently loading when getAsset is called, we add that asset to the loadQue vector
		==============
		*/
		public function getAsset( name:String, callback:Function=null ):* {
			if ( _loadedAssets[name] ) { 
				return _loadedAssets[name];
			}
			if ( _loadState != "loading" ) { 
				_callback = callback;
				loadAsset( _assetPath+name );
			} 
			else if ( _loadQue.indexOf( name ) == -1 ) {
				_loadQue.push( { name:name, callback:callback } );
			}
		}
		
		
		/*
		===============================================================================
		
		Accessors and Mutators
		
		===============================================================================
		==============
		assetPath
		
		Set path to load asset from, default is /assets/ folder
		==============
		*/
		public function set assetPath( path:String ):void { _assetPath = path; }
		public function get assetPath():String { return _assetPath; }
		
		//singleton instance
		public static function get instance():r_loader { return _instance ? _instance : _instance = new r_loader( new privateclass() ); }
	}
}

class privateclass{}