package sg.gaiaframework.utils 
{
	import com.gaiaframework.api.IAsset;
	import com.gaiaframework.events.AssetEvent;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.events.Event;
	
	/**
	 * Simple utility to load and queue-in on-demand assets with array params in function and also deliver callback when all assets are loaded.
	 * @author Glenn Ko
	 */
	public class ArrayAssetLoader extends EventDispatcher
	{
		private var _loadCount:int = 0;
		public var onComplete:Function;
		public var onCompleteParams:Array;
		public var _assetDict:Dictionary = new Dictionary();
		
		public function ArrayAssetLoader() 
		{
			
		}
		public function clear():void {
			for (var i:Object in _assetDict) {
				(i as IAsset).removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
				(i as IAsset).abort();
				delete _assetDict[i];
			}
			onComplete = null;
			onCompleteParams  = null;
			_loadCount = 0;
		}
		public function load(...params):void {
			var len:int = params.length;
			for (var i:int = 0; i < len; i++) {
				
				var asset:IAsset = params[i] as IAsset;
				trace(asset);
				if (_assetDict[asset]) continue; 
				if ( asset.percentLoaded == 1  && asset.getBytesTotal() > 0) continue;
				_assetDict[asset] = true;
				_loadCount++;
				asset.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
				asset.load();
			}
			
			if (_loadCount == 0) doComplete();
		}
		
		protected function onAssetComplete(e:AssetEvent):void {
			_loadCount--;
			e.target.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			delete _assetDict[e.target];
			
			if (_loadCount != 0) return;
			
			doComplete();
		}
		
		protected function doComplete():void {
			dispatchEvent(new Event(Event.COMPLETE));
			
			if (onCompleteParams != null)  {
				onComplete.apply(null, onCompleteParams);
			}
			else {
				onComplete();
			}
			onComplete = null;
			onCompleteParams = null;
		}
		
	}

}