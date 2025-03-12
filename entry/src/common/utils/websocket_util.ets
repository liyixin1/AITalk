// import webSocket from '@ohos.net.webSocket';
// import { BusinessError } from '@kit.BasicServicesKit';
// import * as Interfaces from '../../main/ets/interface'
// import { config } from '../../main/ets/config';
//
// interface GeneratedTypeLiteralInterface_1 {
//   onSuccess: () => void;
//   onFailure: (err: string) => void;
// }
//
// class WebSocketClient {
//   private ws:webSocket.WebSocket | null = null
//   private onMessageCallback: (data: string) => void = () => {};
//   private url:string = ''
//   // initWebSocket(callback: GeneratedTypeLiteralInterface_1)
//   initWebSocket(){
//     this.ws = webSocket.createWebSocket()
//
//     this.ws.connect(
//       this.url,
//       {
//         header:{
//           'Authorization': "Bearer " + config.ai.apiKey,
//           'Content-Type': 'application/json'
//
//         },
//       },
//       (err: BusinessError) => {
//       if (!err) {
//         this.registerEvents();
//         callback.onSuccess();
//       } else {
//         callback.onFailure(`连接失败: ${err.code} ${err.message}`);
//       }
//     });
//
//   }
//   // 在WebSocketUtil中注册核心事件
//   private registerEvents() {
//     // 连接建立事件
//     if(this.ws !== null){
//       this.ws.on('open', (err, value) => {
//         console.log("WebSocket connected");
//       });
//
//       // 消息接收事件
//       this.ws.on('message', (err, message: string | ArrayBuffer) => {
//         if ((typeof message === 'string')) {
//           this.onMessageCallback(message);
//         }
//       });
//       // 错误处理事件
//       this.ws.on('error', (err) => {
//         console.error("WebSocket error:", err);
//       });
//     }
//   }
//   // 发送消息
//   sendMessage(content: string, sessionId: string) {
//     if(this.ws !== null){
//       this.ws.send(JSON.stringify(content), (err: BusinessError) => {
//         if (err) {
//           console.error("消息发送失败:", err);
//         }
//       });
//     }
//   }
//   // 设置消息回调
//   setOnMessageCallback(callback: (data: string) => void) {
//     this.onMessageCallback = callback;
//   }
//   // 关闭连接
//   closeConnection() {
//     if(this.ws !== null){
//       this.ws.close();
//     }
//   }
//
// }
// const websocketUtil = new WebSocketClient();
// export { websocketUtil };