package reportconverter
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	public class FileReadCollection extends ArrayCollection
	{
		private var _toLoad:Number = 0;
		
		[Bindable("complete")]
		[Bindable("progress")]
		public function get toLoad():Number {
			return _toLoad;
		}
		
		[Bindable("complete")]
		[Bindable("progress")]
		public function get loaded():Boolean {
			return _toLoad == 0;
		}
		
		public function FileReadCollection(source:Array=null)
		{
			super(source);
			
			addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
		}
		
		private function incUnloaded():void {
			_toLoad++;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		private function decUnloaded():void {
			_toLoad--;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			if (loaded)
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function checkAdd(item:Object):void {
			if (item.hasOwnProperty("loaded") && !item.loaded)
				incUnloaded();
		}
		
		private function checkRemove(item:Object):void {
			if (item.hasOwnProperty("loaded") && !item.loaded)
				decUnloaded();
		}
		
		private function onCollectionChange(event:CollectionEvent):void {
			if (event.kind == CollectionEventKind.UPDATE) {
				for each (var pce:PropertyChangeEvent in event.items) {
					if (pce.property == "loaded" && pce.newValue != pce.oldValue) {
						if (pce.newValue)
							decUnloaded();
						else
							incUnloaded();
					}
				}
			} else if (event.kind == CollectionEventKind.REPLACE) {
				for each (pce in event.items) {
					checkAdd(pce.newValue);
					checkRemove(pce.oldValue);
				}
			} else if (event.kind == CollectionEventKind.ADD) {
				for each (var o:Object in event.items) {
					checkAdd(o);
				}
			} else if (event.kind == CollectionEventKind.REMOVE) {
				for each (o in event.items) {
					checkRemove(o);
				}
			}
		}
	}
}
