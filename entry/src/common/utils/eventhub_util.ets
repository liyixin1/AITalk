let context = getContext(this)
let eventhub = context.eventHub

export class EventHubUtil {
  /// 订阅事件
  static on(eventName: string, callback: Function) {
    eventhub.on(eventName, callback)
  }

  /// 取消订阅事件
  static off(eventName: string, callback?: Function) {
    eventhub.off(eventName, callback)
  }

  /// 触发事件
  static emit(eventName: string, ...params: Object[]) {
    eventhub.emit(eventName, params)
  }
}
