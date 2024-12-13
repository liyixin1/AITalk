import { http } from "@kit.NetworkKit";

export function myRequest<outT,dataT>(url:string,method:http.RequestMethod,header:object,requestDate:dataT){
  const httpRequest = http.createHttp();
  return new Promise((resolve:(value:outT)=>void,reject:(value?:string)=>void) => {
    httpRequest.request(
      url,
      {
        method:method,
        header:header,
        extraData:JSON.stringify(requestDate) || "",
        connectTimeout:6000,
        readTimeout:6000
      },(error:Error,data:http.HttpResponse)=>{
        if(!error){
          console.log(data.result as string)
          resolve(JSON.parse(data.result as string));
        }else{
          reject(error.message);
        }
      httpRequest.destroy();
    }
    )
  })
}