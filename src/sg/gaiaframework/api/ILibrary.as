package sg.gaiaframework.api 
{
	
	/**
	 * Basic interface to retrieve linkages from library .swf. Must manually cast to specific data
	 * types since this interface is bare bones.
	 * 
	 * @author Glenn Ko
	 */
	public interface ILibrary 
	{
		// identifies library by a unique id (This is required for registering libraries with multiton/stack asset-managers.)
		// Usually determines a unique domain prefix base path from which linkages are received.
		function get libraryId():String; 
		
		function getClassInstance(className:String):Object; // get instance of class definition
		function getDefinition(className:String):Class; 	// get class definition
		
		// Convention: reflects all available class definition names of library in array format, 
		// allowing for random/indexed access.
		function get definitions():Array;  
		
	}
	
}