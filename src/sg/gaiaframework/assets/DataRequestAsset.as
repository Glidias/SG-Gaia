package sg.gaiaframework.assets
{
	import com.gaiaframework.assets.TextAsset;
	import com.gaiaframework.api.IPageAsset;
	import flash.net.URLRequest;

	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLLoader;
	
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import sg.gaiaframework.api.IDataRequestAsset;
	import sg.gaiaframework.utils.VarUtil;
	import sg.gaiaframework.api.IDataAsset;
	
	/**
	* ...
	* @author Glenn Ko
	*/
		
	public class DataRequestAsset extends TextAsset implements IDataRequestAsset
	{
		protected var _dataVars:Object;
		
		public static var BASE_VARS:Object;
		protected var _nodeVars:Object;
		
		protected static const DEFAULT_VAR_DELIMITER:String = ",";
		
		protected var _method:String = URLRequestMethod.POST;
		
		public function DataRequestAsset()
		{
			super();
		}
		public function get data():Object 
		{ 
			return _dataVars; 
		}
		
		public function get method():String { return _method; }
		
		public function set method(value:String):void 
		{
			value = value.toUpperCase();
			if ( value != "POST" && value != "GET" ) throw new Error("Invalid URLRequestMethod assigned!");
			_method = value;
			if (request) request.method = value;
		}
		
		public function getRequest():URLRequest {
			return request;
		}
		
		override public function init():void
		{
			super.init();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			request.method = _method;
			isNoCache = true;
		}
		
		public function sendAndLoad(vars:URLVariables):void {
			if (_dataVars!=null) {  // reload
				abort();
				init();
			}
			request.data = request.data != null ? processVars( request.data as URLVariables )  : processVars( new URLVariables() );
			load();
		}
		
		override public function destroy():void {
			super.destroy();
			_dataVars = null;
		}
		
		protected function processVars(vars:URLVariables):URLVariables {
			if  (_nodeVars != null)  VarUtil.mergeVarsWithBase(vars, _nodeVars);
			if (BASE_VARS != null ) VarUtil.mergeVarsWithBase(vars, BASE_VARS);
			return vars;
		}
		
		override protected function onComplete(event:Event):void
		{
			_dataVars = event.target.data;
			super.onComplete(event);
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
					_nodeVars[str] = attrib[str];
				}
			}
			
			vars = _node.@variables;
			if (vars) {
				var delimiter:String = Boolean(String(_node.@delimiter)) ?_node.@delimiter : DEFAULT_VAR_DELIMITER;
				_nodeVars = _nodeVars!=null ? VarUtil.stringToTargetObject(vars, _nodeVars, delimiter) : VarUtil.stringToTargetObject(vars, {}, delimiter);
			}
		}
		
		override public function preload():void {
			request.data = request.data != null ? processVars( request.data as URLVariables )  : processVars( new URLVariables() );
			super.preload();
		}
		
		override public function toString():String
		{
			return "[DataRequestAsset] " + _id + " : " + _order + " " + _data;
		}
	}
}