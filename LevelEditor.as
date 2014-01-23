package
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
	/*
	===============================================================================
	
		Level Editor - startup controller, asset loading, and display items
	
	===============================================================================
	*/
    
    //SET SWF W/H here ( add tile height to height for hud area )
    [SWF(frameRate="30", width="960", height="768")]
    public class LevelEditor extends Sprite
    {
        //set asset list and file path
        private const ASSETPATH		:String = "../assets/";
        private const ASSETLIST		:String = "assetList.txt";
        
        private var _assetList		:Array;
        private var _assetsLoaded	:Boolean;
		private var _assetHud		:Sprite;
		private var _controlHud		:Sprite;
		private var _grid			:Sprite;
		private var _tilecontroller	:tilecontroller;
		private var _debugInfo		:Sprite;
        
        public function LevelEditor()
        {			
			//adjust g_global stage and stage width
			g_global.stage = stage;
			g_global.stageWidth = stage.stageWidth;
			g_global.stageHeight = stage.stageHeight;
			g_global.addLayers( stage );
			
            _assetList = [];
			
			showGrid();
            getAssetList();
			
			_tilecontroller = new tilecontroller();	
			showDebugInformation();
        }
		
		/*
		==============
		showGrid
		==============
		*/
		private function showGrid():void {
			if ( !_grid ) { _grid = new Sprite(); }
			var columns:Number = (g_global.stageWidth - 64) / g_global.GRIDSIZE;
			var rows:Number = (g_global.stageHeight - 64) / g_global.GRIDSIZE;
			var spr:Sprite
			var i:int;
			
			//create grid, leaving 64px room for bottom and right side hud
			for ( i = 0; i <= rows; i++ ) {
				spr = new Sprite();
				spr.graphics.lineStyle( 1, 0 );
				spr.graphics.moveTo( 0, i * g_global.GRIDSIZE );
				spr.graphics.lineTo( g_global.stageWidth - 64, i * g_global.GRIDSIZE );
				_grid.addChild( spr );
			}
			for ( i = 0; i <= columns; i++ ) {
				spr = new Sprite();
				spr.graphics.lineStyle( 1, 0 );
				spr.graphics.moveTo( i * g_global.GRIDSIZE, 0 );
				spr.graphics.lineTo( i * g_global.GRIDSIZE, stage.stageHeight - 64 );
				_grid.addChild( spr );
			}
			g_global.getAsset( "grid" ).addChild( _grid );
			
			//make overlay for click detectionx
			var tileLayer:Sprite = g_global.getAsset( "tiles" );
			tileLayer.mouseEnabled = true;
			tileLayer.graphics.beginFill( 0xFF0000, 0 );
			tileLayer.graphics.drawRect( 0, 0, g_global.stageWidth, g_global.stageHeight );
		}
		
		private function updateDebug():void {
			if ( _debugInfo ) {
				(_debugInfo.getChildByName( "currentPosition" ) as TextField).text = "X: " + mouseX + " , Y: " + mouseY;
				(_debugInfo.getChildByName( "currentTile" ) as TextField).text = "Current Tile: \t" + _tilecontroller.currentSelection;
				(_debugInfo.getChildByName( "currentRotation" ) as TextField).text = "Tile rotation: \t" + _tilecontroller.currentRotation;
			}
		}
		
		/*
		==============
		onGridSelection
		
			Call controller grid selection
		==============
		*/
		private function onGridSelection( e:Event=null ):void {
			//g_global.echo(" GRID SELECTED: " + e ? e.type : " " );
			_tilecontroller.gridSelected( e, { x:mouseX, y:mouseY, tW:g_global.GRIDSIZE, tH:g_global.GRIDSIZE } );
			updateDebug();
		}
		
		/*
		==============
		createAssetHud
		==============
		*/
		private function createAssetHud():void {
			_assetHud = new Sprite();
			_assetHud.graphics.lineStyle( 2, 0 );
			_assetHud.graphics.drawRect(0, 0, g_global.stageWidth, 64 );
			_assetHud.y = g_global.stageHeight - 64;
			g_global.getAsset( "hud" ).addChild( _assetHud );
			
			_assetHud.mouseChildren = true;
		}
		
		/*
		==============
		addAssetsToHud
		==============
		*/
		private function addAssetsToHud():void {
			var i:int;
			for ( ; i < _assetList.length; i++ ) {
				_tilecontroller.tiles.push( _assetList[i] );
				var container:Sprite = new Sprite();
				container.addChild( _assetList[ i ] );
				_assetList[ i ] = container;
				_assetList[ i ].x = i * 64;
				_assetHud.addChild( _assetList[i] );
			}
			//import swc of controls
			_controlHud = new controlhud();
			_controlHud.x = g_global.stageWidth - _controlHud.width;
			_controlHud.y = g_global.stageHeight - _controlHud.height - _assetHud.height;
			addControlHudListeners();
			g_global.getAsset( "hud" ).addChild( _controlHud );
		}
		
		/*
		==============
		addControlHudListeners
		==============
		*/
		private function addControlHudListeners():void {
			var i:int;
			for ( ; i < _controlHud.numChildren; i++ ) {
				_controlHud.addEventListener( MouseEvent.CLICK, onControlSelected );
			}
		}
		
		/*
		==============
		onControlSelected
		==============
		*/
		private function onControlSelected( e:MouseEvent ):void {
			removeTileListeners();
			switch( e.target.name ) {
				case "collision":	hudcontroller.instance.onCollisionSelected( addTileListeners );
					break;
			}
		}
		
		/*
		==============
		addTileListeners
		
			Add listeners to tiles in the hud and to tile layer
		==============
		*/
		private function addTileListeners():void {
			var i:int;
			for ( ; i < _assetList.length; i++ ) {
				_assetList[ i ].addEventListener( MouseEvent.CLICK, onTileSelect );
			}
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onGridSelection );
			g_global.getAsset( "tiles" ).addEventListener( MouseEvent.MOUSE_WHEEL, onGridSelection );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onGridSelection );
			stage.addEventListener( KeyboardEvent.KEY_UP, onGridSelection );
		}
		
		private function removeTileListeners():void {
			var i:int;
			for ( ; i < _assetList.length; i++ ) {
				_assetList[ i ].removeEventListener( MouseEvent.CLICK, onTileSelect );
			}
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onGridSelection );
			g_global.getAsset( "tiles" ).removeEventListener( MouseEvent.CLICK, onGridSelection );
			g_global.getAsset( "tiles" ).removeEventListener( MouseEvent.MOUSE_WHEEL, onGridSelection );
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onGridSelection );
			stage.removeEventListener( KeyboardEvent.KEY_UP, onGridSelection );
		}
		
		/*
		==============
		onTileSelect
		
			Call the controller set selection
		==============
		*/
		private function onTileSelect( e:MouseEvent ):void {
			var i:int;
			var index:int = -1;
			for ( ; i < _assetList.length; i++ ) {
				if ( _assetList[ i ] == e.target ) {
					index = i;
					break;
				}
			}
			if ( index != -1 ) { 
				_tilecontroller.setSelection( i ); 
				updateDebug();
			}
			if ( !g_global.getAsset( "tiles" ).hasEventListener( MouseEvent.CLICK ) ) {
				g_global.getAsset( "tiles" ).addEventListener( MouseEvent.CLICK, onGridSelection );
			}
		}
		
		/*
		===============================================================================
		
			Asset Loading
		
		===============================================================================
        ==============
        getAssetList
        
        	Level editor needs an asset list text file containing all the assets that need to be loaded
        ==============
        */
        private function getAssetList():void {
            var fileList:URLLoader = new URLLoader();
            fileList.addEventListener( Event.COMPLETE, loadAssets );
            fileList.addEventListener( IOErrorEvent.IO_ERROR, onError );
            fileList.load( new URLRequest( ASSETPATH + ASSETLIST ) );
        }
        
        /*
        ==============
        loadAssets
        ==============
        */
        private function loadAssets( e:Event ):void {
            var list:Array = e.target.data.split( "\r" );
            var i:int;
            for ( ; i < list.length; i++ ) {
				list[ i ] = list[ i ].replace( "\n", "" );
				
                if ( i < list.length - 1 ) {
                    r_loader.instance.getAsset( list[i], onAssetLoaded );
                } else {
                    r_loader.instance.getAsset( list[i], onAssetsComplete );
                }
            }
        }
		
		/*
		==============
		onAssetsComplete
		
			All assets loaded
		==============
		*/
		private function onAssetsComplete( asset:Bitmap ):void {
			g_global.echo( "assets Loaded" );
			onAssetLoaded( asset );
			_tilecontroller.createMap( _assetList.length );
			createAssetHud();
			addAssetsToHud();
			addTileListeners(); 
			_tilecontroller.setSelection( 0 );
		}
        
		/*
		==============
		onAssetLoaded
		==============
		*/
        private function onAssetLoaded( asset:Bitmap ):void { _assetList.push( asset ); }
        private function onError( error:IOErrorEvent ):void { throw new Error( "--> Loading Asset List failed: " + error.text ); }
		
		/*
		===============================================================================
		
		Debug Information
		
		===============================================================================
		*/
		private function showDebugInformation():void {
			//debug sprite
			_debugInfo = new Sprite();
			_debugInfo.graphics.beginFill( 0x111111, 0.7 );
			_debugInfo.graphics.drawRect( 0, 0, 150, 75 );
			_debugInfo.x = stage.stageWidth - _debugInfo.width;
			_debugInfo.mouseChildren = false;
			g_global.getAsset( "hud" ).addChild( _debugInfo );
			
			//textfields
			var currentTile:TextField = new TextField();
			var currentPosition:TextField = new TextField();
			var currentRotation:TextField = new TextField();
			
			//text format
			var tf:TextFormat = new TextFormat();
			tf.size = 16;
			tf.align = "right";
			tf.font = "Arial";
			tf.color = 0xFFFFFF;
			
			//setup current tile textfield
			currentTile.selectable = false;
			currentTile.name = "currentTile";
			currentTile.autoSize = "left";
			currentTile.defaultTextFormat = tf;
			currentTile.text = "Current Tile: \t" + _tilecontroller.currentSelection;
			
			//setup current position textfield
			tf.color = 0xFF0000;
			currentPosition.selectable = false;
			currentPosition.name = "currentPosition";
			currentPosition.defaultTextFormat = tf;
			currentPosition.autoSize = "left";
			currentPosition.text = "X:" + mouseX + " , Y: " + mouseY;
			currentPosition.y = currentTile.height;
			
			//setup current rotation textfield
			tf.color = 0x0099CC;
			currentRotation.selectable = false;
			currentRotation.name = "currentRotation";
			currentRotation.defaultTextFormat = tf;
			currentRotation.autoSize = "left";
			currentRotation.text = "Tile rotation: \t" + _tilecontroller.currentRotation;
			currentRotation.y = currentPosition.y + currentPosition.height;
			
			_debugInfo.addChild( currentTile );
			_debugInfo.addChild( currentPosition );
			_debugInfo.addChild( currentRotation );
			_debugInfo.addEventListener( MouseEvent.MOUSE_OVER, hideDebug );
		}
		
		private function hideDebug( e:MouseEvent = null ):void {
			_debugInfo.visible = false;
			stage.addEventListener( MouseEvent.MOUSE_MOVE, showDebug );
		}
		
		private function showDebug( e:MouseEvent = null ):void {
			if ( mouseX < _debugInfo.x || mouseY > _debugInfo.y + _debugInfo.height ) {
				_debugInfo.visible = true;
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, showDebug );
			}
		}
    }
}