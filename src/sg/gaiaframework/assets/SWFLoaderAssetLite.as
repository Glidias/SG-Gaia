package sg.gaiaframework.assets
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.ByteArrayAsset;
	import com.gaiaframework.events.AssetEvent;
	
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	
	import sg.gaiaframework.api.ILibrary;
	
	import flash.display.Loader;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import flash.errors.EOFError;
	import flash.events.IOErrorEvent;
	
	// Comment this package and dtrace methods to remove debugging (and save file size too)
	import com.gaiaframework.debug.GaiaDebug;
	
	/**
	 * ...
	 *  @author kris
	 *  Original class: de.kris.utils.SWFLoader
	 * 	http://krisrok.de/flash/classes/de/kris/utils/SWFLoader.as
	 * 
	 * repackaged by: Glenn Ko 
	 * 
	 * Also uses dictionary hash instead with already saved definitions to allow for fast retreival of instances.
	 * 
	 * --------------------------------------
	 * NOTE: This is a Lite version which doesn't import Flash-specific data types. You must manually cast
	 * your retrieved class instance objects through the generic ILibrary.getClassInstance():Object method.
	 * 
	 */
	public class SWFLoaderAssetLite extends ByteArrayAsset implements ILibrary
	{
		private var debug:Boolean = false;  // @attribute
		private var ba:ByteArray;  
		private var classesNames:Array;
		private var l:Loader;
		
			
		protected var sort:Boolean;
		
		protected var _libraryId:String;
		
		private var classesDictionary:Dictionary = new Dictionary();

		public function SWFLoaderAssetLite() 
		{
			super();
		}
		
		private function dtrace(msg:Object):void
		{
			if(debug)
				GaiaDebug.log("[SWFLoader] " + msg.toString());
				
		}
		
				
		override public function destroy():void {
			super.destroy();
		}
		
		override public function parseNode(page:IPageAsset):void {
			super.parseNode(page);
			debug = _node.@debug == "true";
			sort = _node.@sort == "true";
			_libraryId =  Boolean( String(_node.@libraryId) ) ? _node.@libraryId :  getNodePath();
		}
		
		override protected function onComplete(event:Event):void
		{
			var tmp:ByteArray = new ByteArray();
			ba = new ByteArray();
			
			var ul:URLLoader = event.target as URLLoader;
			tmp.writeObject(ul.data);
			tmp.position = tmp.length - ul.bytesLoaded;
			tmp.readBytes(ba);
			
			ba.position = 0;
			
			switch(ba.readUTFBytes(3))	
			{
				case "CWS":
					dtrace("compressed movie loaded.");
					decompressSWF();
				break;
				
				case "FWS":
					dtrace("uncompressed movie loaded.");
				break;
				
				default:
					dtrace("not a valid swf!");
					dtrace("------------------------------------------------");
			}
			
			if (readClasses())
			{	
				l = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, onLComplete);
				l.loadBytes(ba);
			}
			else
				dtrace("------------------------------------------------");
				
			
			//_data = loader.data as ByteArray;
			removeListeners(loader);
			//super.onComplete(event);
		
		}
		
		public function get libraryId():String {
			return _libraryId;
		}
				
		protected function getNodePath():String {
			var str:String = _node.@id;
			var anode:XML = _node.parent();
			while (anode) {
				var tryId:String = anode.@id;
				if (! Boolean( String(tryId) ) ) break;
				str = tryId + "/" + str;
				anode = anode.parent();
			}
			
			return str;
		}
		
		private function onLComplete(e:Event):void
		{
			l.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLComplete);
			
			dtrace("ready to instantiate.");
			dtrace("------------------------------------------------");

			
			//ul = null;
			
			//super.onComplete(event);
			//dispatchEvent(new Event(Event.COMPLETE));
			
			
			parseClasses();
			dispatchEvent(new AssetEvent(AssetEvent.ASSET_COMPLETE, false, false, this));
		}
		
		protected function registerClassName(id:String):void {
			classesNames.push(id);
			classesDictionary[id] = true;
		}
		
		protected function parseClasses():void {
			for (var i:Object in classesDictionary) {
				classesDictionary[i] = l.contentLoaderInfo.applicationDomain.getDefinition(i as String);
			}
		}
		
		
				
		/**
		 * Returns the class.
		 * 
		 * @param	className
		 * @return 	The class definition itself. (useful for fonts or other shizzle)
		 */
		public function getDefinition(className:String):Class
		{
			return classesDictionary[className];
		//	return (classesNames.indexOf(className)!=-1)?(l.contentLoaderInfo.applicationDomain.getDefinition(className) as Class):null;
		}
		
		public function get definitions():Array {
			return classesNames;
		}
		
		public function getClassInstance(className:String):Object {
			return new classesDictionary[className]();
		}
		
		
		
		
		private function decompressSWF():void
		{
			dtrace("decompressing...");
			//uncompressed bytearray
			var uba:ByteArray = new ByteArray();
			//temp bytearray
			var tmp:ByteArray = new ByteArray();
			
			//put first 8 uncompressed bytes in uba
			ba.position = ba.length - loader.bytesLoaded;
			ba.readBytes(tmp, 0, 8);
			uba.writeBytes(tmp);
			
			//set first 3 bytes to FWS for uncompressed
			uba.position=0;
			uba.writeUTFBytes("FWS");
			
			//read compressed bytes into tmp and uncompress
			ba.readBytes(tmp, 0, 0);
			tmp.uncompress();
			
			//put uncompressed bytes after 8byte-header
			uba.position = 8;
			uba.writeBytes(tmp);
			
			//et voila
			dtrace("complete! before: " + ba.length + "B, after: " + uba.length + "B");
			ba = uba;
			uba = null;
			
			
		}
		
		
		
		private function readClasses():Boolean
		{
			dtrace("");
			dtrace("reading classes..");
			
			//searching for dictionary-tag
			var dictOffset:uint = 0;
			var classesNum:uint = 0;
			
			ba.position = 8;
			
			try
			{
				while(ba.bytesAvailable && dictOffset==0)
				{
					if (ba.readUnsignedByte() == 0)
						if (ba.readUnsignedByte() == 0)
							if (ba.readUnsignedByte() == 0)
								if (ba.readUnsignedByte() == 63)
									if (ba.readUnsignedByte() == 19)
					
					dictOffset = ba.position;
				}

				//read number of available definitions
				ba.position+=4;
				classesNum = ba.readUnsignedByte();
				dtrace( classesNum + " definition(s) found:");
				
			
				
				//getting definition-names
				classesNames = new Array();
				ba.position+=1;
				var tmpName:String;
				var tmpID:uint;
				var char:uint;
			
				while(classesNum>0)
				{
					tmpID = ba.readUnsignedByte();
					ba.position++;
					
					tmpName = "";
					char = 0;
					while((char = ba.readUnsignedByte())!=0)
					{
						tmpName += String.fromCharCode(char);
					}
	//					trace(tmpID + " - " + tmpName);
					
				
				
					registerClassName(tmpName);
					
					classesNum--;
				}
			}
			catch ( e:EOFError )
			{
				dtrace(e);
				dtrace("no symbols in library found or some unkown error");
				return false;
			}
			
			if (sort) classesNames.sort();
			
			// Trace
			/*
			tmpName = "";
			for (var i:int = 0; i < classesNames.length; i++ )
				tmpName += i + ") " + classesNames[i] + ", ";
			dtrace(tmpName.slice(0,tmpName.length-2));
			*/
			
			return true;
		}
		
	}

}