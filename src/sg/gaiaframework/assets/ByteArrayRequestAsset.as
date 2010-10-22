/*****************************************************************************************************
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


package sg.gaiaframework.assets
{
	import com.gaiaframework.api.IByteArray;
	import com.gaiaframework.assets.AssetLoader;
	import com.gaiaframework.assets.ByteArrayAsset;
	import com.gaiaframework.api.IPageAsset;
	import flash.net.URLRequest;
	
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import sg.gaiaframework.api.IByteArrayRequestAsset;
	import sg.gaiaframework.utils.VarUtil;
	
	/**
	 * @author Glenn Ko
	 */
	public class ByteArrayRequestAsset extends ByteArrayAsset implements IByteArrayRequestAsset
	{
		
		protected var _nodeVars:Object;
		public static var BASE_VARS:Object;
		protected var _method:String = URLRequestMethod.POST;
		
		protected static const DEFAULT_VAR_DELIMITER:String = ",";
		
		function ByteArrayRequestAsset()
		{
			super();
		}
		
		override public function init():void {
			super.init();
			request.method = _method;
		}
		
		public function getRequest():URLRequest {
			return request;
		}
		
		public function sendAndLoad(vars:URLVariables):void {
			if (loader.data != null) {
				abort();
				init();
			}
			request.data = request.data != null ? processVars( request.data as URLVariables )  : processVars( new URLVariables() );
			load();
		}
		
		protected function processVars(vars:URLVariables):URLVariables {
			if  (_nodeVars != null)  VarUtil.mergeVarsWithBase(vars, _nodeVars);
			if (BASE_VARS != null ) VarUtil.mergeVarsWithBase(vars, BASE_VARS);
			return vars;
		}
		
		override public function preload():void {
			request.data = request.data != null ? processVars( request.data as URLVariables )  : processVars( new URLVariables() );
			super.preload();
		}
		
		override public function parseNode(page:IPageAsset):void
		{
			super.parseNode(page);
			_preloadAsset = (_node.@preload == "true");
			_method = _node.@method != undefined ? node.@method.toString().toLowerCase() == "get" ? URLRequestMethod.GET : URLRequestMethod.POST   : URLRequestMethod.POST;
			
			var vars:String = _node.@vars;
			if (vars)   {
				_nodeVars = { };
				var attrib:XMLList = _node.attributes();
				var chkVars:Array = vars.split(",");
				for each(var str:String in chkVars) {
					_nodeVars[str] = node["@"+str];
				}
			}
			
			vars = _node.@variables;
			if (vars) {
				var delimiter:String = Boolean(String(_node.@delimiter)) ?_node.@delimiter : DEFAULT_VAR_DELIMITER;
				_nodeVars = _nodeVars!=null ? VarUtil.stringToTargetObject(vars, _nodeVars, delimiter) : VarUtil.stringToTargetObject(vars, {}, delimiter);
			}
		}
	
		override public function toString():String
		{
			return "[ByteArrayRequestAsset] " + _id + " : " + _order + " ";
		}
		
		public function get method():String { return _method; }
		
		public function set method(value:String):void 
		{
			value = value.toUpperCase();
			if ( value != "POST" && value != "GET" ) throw new Error("Invalid URLRequestMethod assigned!");
			_method = value;
			if (request) request.method = value;
		}
	}
}