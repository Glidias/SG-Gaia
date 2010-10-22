package sg.gaiaframework.api {
	import com.gaiaframework.api.IAsset;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	* ...
	* @author Glenn Ko
	*/
	public interface IRequestAsset extends IAsset {
		
		function sendAndLoad(vars:URLVariables):void;
		function getRequest():URLRequest;
		function set method(val:String):void;
		function get method():String;
	}
	
}