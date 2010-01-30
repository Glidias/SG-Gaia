package sg.gaiaframework.api 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.media.Sound;
	
	/**
	 * Basic interface to retrieve common Flash library item items by linkage id.
	 * @author Glenn Ko
	 */
	public interface IFlashLibrary extends ILibrary
	{
		function getDisplayObject(className:String):DisplayObject;  // common method to cast to any type of Displayobject
		function getSimpleButton(className:String):SimpleButton;   // get Button symbol
		function getBitmapData(className:String):BitmapData;	   // get BitmapData symbol
		function getBitmap(className:String):Bitmap;			   // get new Bitmap based on BitmapData
		function getSound(className:String):Sound;				   // get Sound symbol
		function getSprite(className:String):Sprite;  			   // get Sprite symbol. Can be manually casted to MovieClip
		function getMovieClip(className:String):MovieClip;		   // get MovieClip symbol
	}
	
}