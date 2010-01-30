package sg.gaiaframework.assets
{
	import com.gaiaframework.api.IPageAsset;
	import com.gaiaframework.assets.ByteArrayAsset;
	import com.gaiaframework.events.AssetEvent;
	import flash.net.URLRequest;

	//import flash.utils.describeType;
	import flash.utils.Dictionary;
	
	import sg.gaiaframework.api.IFlashLibrary;
	// Data types for IFlashLibrary
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	
	
	import flash.errors.EOFError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	

	// Comment this package and dtrace methods to remove debugging 
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
	 */
	public class SWFLoaderAsset extends ByteArrayAsset implements IFlashLibrary
	{
		protected var debug:Boolean = false;  // @attribute
		private var ba:ByteArray;  
		private var l:Loader;
		
		protected var classesNames:Array;
		protected var sort:Boolean;
		protected var classesDictionary:Dictionary = new Dictionary();
		
		protected var _libraryId:String;
		

		public function SWFLoaderAsset() 
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
				
				l.load( new URLRequest(src) );
			}
			else
				dtrace("------------------------------------------------");
				
			
			//_data = loader.data as ByteArray;
			removeListeners(loader);
			//super.onComplete(event);
		
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
		
		
		public function get libraryId():String {
			return _libraryId;
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
			var classCheck:Class = classesDictionary[className] as Class;
			if (classCheck == null) {
				classCheck = l.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
				classesDictionary[className] = classCheck;
			}
			return new classCheck();
		}
		
		
		/**
		 * If existing and extending Sprite, an instance of the class is created and returned as Sprite. (You can cast it to a more special type (like MovieClip) after calling the function!)
		 * 
		 * @param	className The name of the class you want to instantiate, if the name is not in the definitions-array. Otherwise null!
		 * @return	The instance
		 */
		public function getSprite(className:String):Sprite
		{
			return new classesDictionary[className]() as Sprite;
			//return getValidatedClassIfReady(className, "flash.display::Sprite") as Sprite;
			
			//return (classesNames.indexOf(className)!=-1)?DisplayObject(new (l.contentLoaderInfo.applicationDomain.getDefinition(className) as Class)()):null;
		}
		public function getMovieClip(className:String):MovieClip {
			return new classesDictionary[className]() as MovieClip;
		}
		
		/**
		 * If existing and extending DisplayObject, an instance of the class is created and returned as DisplayObject. (You can cast it to a more special type (like MovieClip) after calling the function!)
		 * 
		 * @param	className The name of the class you want to instantiate, if the name is not in the definitions-array. Otherwise null!
		 * @return	The instance
		 */
		public function getDisplayObject(className:String):DisplayObject
		{
			return new classesDictionary[className]() as DisplayObject;
			
			//var classe:Class = getDefinition(className);
			//return new classe() as DisplayObject;
			
			//return (classesNames.indexOf(className)!=-1)?DisplayObject(new (l.contentLoaderInfo.applicationDomain.getDefinition(className) as Class)()):null;
		}
		
		/**
		 * If existing and extending SimpleButton, an instance of the class is created and returned as SimpleButton.
		 * @param	className
		 * @return
		 */
		public function getSimpleButton(className:String):SimpleButton 
		{
			return new classesDictionary[className]() as SimpleButton;
		}
		
		/**
		 * Creates an instance of BitmapData and returns it.
		 * 
		 * @param	className
		 * @return
		 */
		public function getBitmapData(className:String):BitmapData
		{
			return new classesDictionary[className](0,0) as BitmapData;
		}
		
		/**
		 * Creates an instance of Bitmap (using getBitmapData()) and returns it.
		 * @param	className
		 * @return
		 */
		public function getBitmap(className:String):Bitmap
		{
			return new Bitmap(getBitmapData(className));
		}

		
		public function getSound(className:String):Sound
		{
			return new classesDictionary[className]() as Sound;
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