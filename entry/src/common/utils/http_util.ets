import { http } from "@kit.NetworkKit";
import { util } from '@kit.ArkTS';
import connection from '@ohos.net.connection';
import { systemDateTime } from "@kit.BasicServicesKit";

export function myRequest<outT, dataT>(
  url: string,
  method: http.RequestMethod.POST,
  header: object,
  requestData: dataT
): Promise<outT> {
  const httpRequest = http.createHttp();

  return new Promise((resolve, reject) => {
    let isRequestCompleted = false;

    try {
      const startTime = systemDateTime.getTime()
      httpRequest.request(
        url,
        {
          method: method,
          header: header,
          extraData: JSON.stringify(requestData) || "",
          connectTimeout: 6000,
          readTimeout: 6000,
        },
        (error: Error, data: http.HttpResponse) => {
          isRequestCompleted = true;
          const endTime = systemDateTime.getTime()
          console.log(`HTTP:Request took ${endTime - startTime} milliseconds`)
          // 销毁请求对象
          if (httpRequest) {
            httpRequest.destroy();
          }

          // 错误处理
          if (error) {
            console.error("HTTP请求失败:", error.message);
            reject(`Request failed: ${error}`);
            return;
          }

          if (!data || !data.result) {
            console.error("HTTP响应数据无效");
            reject("Invalid response data");
            return;
          }

          const resultStr = data.result as string;

          try {
            // 检查返回值是否包含错误信息
            if (resultStr.includes("Error") || resultStr.includes("error") ) {
              console.error("接口返回错误信息:", resultStr);
              if(resultStr.includes("you have been blocked")){
                reject('网络问题');
              }
              reject(`${resultStr}`);
            } else {
              console.log("请求成功，返回数据:", resultStr);
              resolve(JSON.parse(resultStr));
            }
          } catch (parseError) {
            console.error("解析返回数据时出错:", parseError);
            reject("Failed to parse response data");
          }
        }
      );

      // 处理未触发回调的超时情况
      setTimeout(() => {
        if (!isRequestCompleted) {
          console.error("请求超时");
          if (httpRequest) {
            httpRequest.destroy();
          }
          reject("Request timed out");
        }
      }, 6500); // 超时设为比 readTimeout 略高
    } catch (exception) {
      console.error("发生意外错误:", exception);
      if (httpRequest) {
        httpRequest.destroy();
      }
      reject("Unexpected error occurred");
    }
  });
}

export class myStreamRequest{
  httpRequest: http.HttpRequest | null = null;
  private listeners: Map<string, Function> = new Map();
  constructor(){
    this.initHttpRequest();
  }
  private initHttpRequest(): void {
    // 创建HTTP请求对象
    this.httpRequest = http.createHttp();
  }
  /**
   * 发送流式请求到OpenAI API
   * @param prompt 用户输入的提示
   * @param model 模型名称，默认为"gpt-3.5-turbo"
   * @param apiKey OpenAI API密钥
   * @returns Promise<number> 响应码
   */
  public fetchStreamRequest<T>(url: string, header: object, requestData: T,): Promise<number> {
    if (!this.httpRequest) {
      this.initHttpRequest();
    }
    // 注册事件处理器
    this.registerEventHandlers();
    try {
      const promise = this.httpRequest!.requestInStream(url, {
        method: http.RequestMethod.POST,
        connectTimeout: 60000,
        readTimeout: 60000,
        header: header,
        extraData: JSON.stringify(requestData) || "",
      });
      return promise
    }catch (err) {
      console.error("HTTP请求发生意外错误:", err.code);
      if (this.httpRequest) {
        this.httpRequest.destroy();
      }
      return Promise.reject(err); // 将错误包装为拒绝的Promise
    }
  }
  /**
   * 安全地触发事件
   * @param eventName 事件名称
   * @param data 事件数据
   */
  // private triggerEvent(eventName: string, data?: unknown): void {
  //   const callback = this.listeners.get(eventName);
  //   if (callback && typeof callback === 'function') {
  //     callback(data);
  //   }
  // }

  private registerEventHandlers(): void {
    if (!this.httpRequest) return;
    // 用于订阅HTTP响应头事件
    this.httpRequest.on('headersReceive', (header: Object) => {
      console.info('接收到响应头: ' + JSON.stringify(header));
      // this.triggerEvent('headersReceive', header);
      const callback = this.listeners.get('headersReceive');
      if (callback && typeof callback === 'function') {
        callback(header);
      }
    });
    // 用于订阅HTTP流式响应数据接收事件
    let responseBuffer = new ArrayBuffer(0);
    this.httpRequest.on('dataReceive', (data: ArrayBuffer) => {
      // 合并数据
      const newBuffer = new ArrayBuffer(responseBuffer.byteLength + data.byteLength);
      const newView = new Uint8Array(newBuffer);
      newView.set(new Uint8Array(responseBuffer));
      newView.set(new Uint8Array(data), responseBuffer.byteLength);
      responseBuffer = newBuffer;

      // 处理数据
      let textDecoder = util.TextDecoder.create('utf-8')
      const chunk = textDecoder.decodeToString(new Uint8Array(data))

      // OpenAI返回的数据格式为: data: {...}\n\n
      // 需要解析这种格式
      const lines = chunk.split('\n');
      lines.forEach(line => {
        if (line.startsWith('data: ') && line !== 'data: [DONE]') {
          try {
            console.log(line)
            // const jsonData: T = JSON.parse(line.substring(6));
            const Data:string = line.substring(6);
            const callback = this.listeners.get('dataReceive');
            if (callback && typeof callback === 'function') {
              callback(Data);
            }
          } catch (e) {
            console.error('解析JSON失败:', e);
          }
        }
      });
    });
    // 用于订阅HTTP流式响应数据接收完毕事件
    this.httpRequest.on('dataEnd', () => {
      console.info('数据接收完毕');
      const callback = this.listeners.get('dataEnd');
      if (callback && typeof callback === 'function') {
        callback();
      }
    });
    // 用于订阅HTTP流式响应数据接收进度事件
    class ProgressData {
      receiveSize: number = 0;
      totalSize: number = 0;
    }

    this.httpRequest.on('dataReceiveProgress', (data: ProgressData) => {
      console.log("接收进度: " + data.receiveSize + "/" + data.totalSize);
      const callback = this.listeners.get('dataReceiveProgress');
      if (callback && typeof callback === 'function') {
        callback(data);
      }
    });
  }

  /**
   * 添加事件监听器
   * @param event 事件名称
   * @param callback 回调函数
   */
  public on(event: string, callback: Function): void {
    this.listeners.set(event, callback);
  }
  /**
   * 清理资源
   */
  private cleanup(): void {
    if (this.httpRequest) {
      // 取消所有事件订阅
      this.httpRequest.off('headersReceive');
      this.httpRequest.off('dataReceive');
      this.httpRequest.off('dataReceiveProgress');
      this.httpRequest.off('dataEnd');

      // 销毁HTTP请求对象
      this.httpRequest.destroy();
      this.httpRequest = null;
    }
  }
  /**
   * 销毁服务
   */
  public destroy(): void {
    this.cleanup();
    this.listeners.clear();
  }
}
