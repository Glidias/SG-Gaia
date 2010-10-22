﻿/*****************************************************************************************************
* Gaia Framework for Adobe Flash ©2007-2009
* Author: Steven Sacks
*
* blog: http://www.stevensacks.net/
* forum: http://www.gaiaflashframework.com/forum/
* wiki: http://www.gaiaflashframework.com/wiki/
* 
* By using the Gaia Framework, you agree to keep the above contact information in the source code.
* 
* Gaia Framework for Adobe Flash is released under the GPL License:
* http://www.opensource.org/licenses/gpl-2.0.php 
*****************************************************************************************************/

package com.gaiaframework.assets
{
	import com.gaiaframework.debug.GaiaDebug;
	import flash.events.Event;
	import sg.gaiaframework.api.ISeoAsset;

	public class SEOAsset extends XMLAsset implements ISeoAsset
	{	
		private var _copy:Object;
		
		function SEOAsset()
		{
			super();
		}
		public function get copy():Object
		{
			return _copy;
		}
		public function get innerHTML():XML {
			return _copy ? _copy.innerHTML : getEmptyXML();
		}
		
		protected function getEmptyXML():XML {
			GaiaDebug.log("SEOAsset:: getEmptyXML() from innerHTML. No inner html found.");
			return new XML();
		}
		
		override protected function onComplete(event:Event):void
		{
			var prevIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
			var prevPrettyPrinting:Boolean = XML.prettyPrinting;
			
			parseCopy(event.target.data);
			
			XML.ignoreWhitespace = prevIgnoreWhitespace;
			XML.prettyPrinting = prevPrettyPrinting;
			
			super.onComplete(event);
		}
		private function parseCopy(data:String):void
		{
			_copy = {}; 
			XML.ignoreWhitespace = false;
			XML.prettyPrinting = false;
			default xml namespace = new Namespace("http://www.w3.org/1999/xhtml");
			var html:XML = XML(data);
			var copyTags:XMLList = html..div.(hasOwnProperty("@id") && @id == "copy")..p;
			var copyTag:XML;
			
			_copy.innerHTML = XMLList(html..div.(hasOwnProperty("@id") && @id == "copy").toXMLString().replace(/\s+xmlns(:[^=]+)?=\"[^=]*?\"/g, ""))[0];
			
			for each (copyTag in copyTags)
			{
				var str:String = "";
				var len:int = copyTag.children().length();
				for (var i:int = 0; i < len; i++)
				{
					str += copyTag.children()[i].toXMLString();
				}
				_copy[copyTag.@id] = str.replace(/\s+xmlns(:[^=]+)?=\"[^=]*?\"/g, "");
			}
		}
		override public function toString():String
		{
			return "[SEOAsset] " + _id;
		}
	}
}