package sg.gaiaframework.api
{
	import com.gaiaframework.api.IXml;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface ISeoAsset extends IXml
	{
		function get copy():Object;
		function get innerHTML():XML;
	}
	
}