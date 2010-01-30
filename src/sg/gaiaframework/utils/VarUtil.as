package sg.gaiaframework.utils 
{
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class VarUtil
	{
		public static function traceVars (obj:Object):void {
			trace("Tracing vars:");
			for (var i:String in obj) {
				trace (i + ": " + obj[i]);
			}
		}
		
		public static function cloneVars (toClone:Object):Object {
			var obj:Object = { };
			for (var i:String in toClone) {
				obj[i] = toClone[i];
			}
			return obj;
		}
		
		public static function mergeVarsWithBase (objA:Object, base:Object):Object {
			for (var i:String in base) {
				objA[i] = objA[i] ? objA[i] : base[i];
			}
			return objA;
		}	
		
		public static function stringToTargetObject(str:String, obj:Object, dataDelimiter:String, propDelimiter:String=":"):Object {
			var list : Array = str.split( dataDelimiter );
			var total : Number = list.length;
			for (var i : Number = 0; i < total ; i ++) 
			{
				var prop : Array = list[i].split( propDelimiter );
				obj[prop[0]] = prop[1];
			}
			return obj;
		}
	}
	
}