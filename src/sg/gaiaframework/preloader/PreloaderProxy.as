package sg.gaiaframework.preloader
{
	import com.gaiaframework.api.IPreloader;
	import com.gaiaframework.templates.AbstractPreloader;
	import flash.events.Event;
	import sg.gaiaframework.api.IPreloaderProxy;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class PreloaderProxy extends AbstractPreloader implements IPreloaderProxy
	{
		protected var _proxy:IPreloader;
		
		public function PreloaderProxy() 
		{
			super();
		}
		
		public function setPreloaderProxy(proxy:IPreloader):void {
			_proxy = proxy;
		}
		

		/// Registers an event listener object with an EventDispatcher object so that the listener receives notification of an event.
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
			_proxy.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/// Dispatches an event into the event flow.
		override public function dispatchEvent (event:Event) : Boolean {
			return _proxy.dispatchEvent(event);
		}

		/// Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
		override public function hasEventListener (type:String) : Boolean {
			return _proxy.hasEventListener(type);
		}

		/// Removes a listener from the EventDispatcher object.
		override public function removeEventListener (type:String, listener:Function, useCapture:Boolean = false) : void {
			_proxy.removeEventListener(type, listener, useCapture);
		}

		/// Checks whether an event listener is registered with this EventDispatcher object or any of its ancestors for the specified event type.
		override public function willTrigger (type:String) : Boolean {
			return _proxy.willTrigger(type);
		}
		
		

		

		override public function transitionIn():void {
			_proxy.transitionIn();
		}
		/**
		 * Gaia calls this method on a page or preloader when it needs to transition out.
		 */
		override public function transitionOut():void {
			_proxy.transitionOut();
		}
		/**
		 * Pages call this method to let Gaia know when they are finished transitioning in.
		 */
		override public function transitionInComplete():void {
			_proxy.transitionInComplete();
		}
		/**
		 * Pages and preloaders call this method to let Gaia know when they are finished transitioning out.
		 */
		override public function transitionOutComplete():void {
			_proxy.transitionOutComplete();
		}
		
		
	}

}