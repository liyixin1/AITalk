import { http } from "@kit.NetworkKit";

export function myRequest<outT, dataT>(
  url: string,
  method: http.RequestMethod,
  header: object,
  requestData: dataT
): Promise<outT> {
  const httpRequest = http.createHttp();

  return new Promise((resolve, reject) => {
    let isRequestCompleted = false;

    try {
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
