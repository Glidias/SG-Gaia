package sg.gaiaframework.assets {

	import com.gaiaframework.assets.XMLAsset;
	import com.gaiaframework.api.IPageAsset;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import sg.gaiaframework.api.IRequestAsset;
	import sg.gaiaframework.utils.VarUtil;
	import flash.net.URLRequestMethod;
	
	/**
	* ...
	* @author Glenn Ko
	*/
	public class XMLRequestAsset extends XMLAsset implements IRequestAsset{
		
		protected var _nodeVars:Object;
		public static var BASE_VARS:Object;
		
		protected static const DEFAULT_VAR_DELIMITER:String = ",";
		
		public function XMLRequestAsset() {
			super();
		}
		
		public function getRequest():URLRequest {
			return request;
		}
		
		override public function init():void {
			super.init();
			request.method = URLRequestMethod.POST;
			isNoCache = true;
		}
		public function sendAndLoad(vars:URLVariables):void {
			if (xml!=null) {  // reload
				abort();
				init();
			}
			request.data = vars;  
			load();
		}
		
		protected function processVars(vars:URLVariables):URLVariables {
			if  (_nodeVars != null)  VarUtil.mergeVarsWithBase(vars, _nodeVars);
			if (BASE_VARS != null ) VarUtil.mergeVarsWithBase(vars, BASE_VARS);
			return vars;
		}
		
		override public function parseNode(page:IPageAsset):void
		{
			super.parseNode(page);				
			_preloadAsset = (_node.@preload == "true");
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
		
		override public function preload():void {
			request.data = request.data != null ? processVars( request.data as URLVariables )  : processVars( new URLVariables() );
			//VarUtil.traceVars(request.data);
			super.preload();
		}
		
		
		override public function toString():String
		{
			return "[XMLRequestAsset] " + _id + " : " + _order + " -" + xml;
		}
	
	}
}
	
