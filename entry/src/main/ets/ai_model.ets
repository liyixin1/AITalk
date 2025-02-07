import { config } from './config'
import * as Interfaces from './interface';
import { myRequest } from '../../common/Index'
import { http } from '@kit.NetworkKit';
class AIModel{
  headers:Interfaces.HttpHeaders;
  url:string;
  body:Interfaces.RequestBody;
  constructor(){
    this.headers = {
      'Authorization': "Bearer " + config.ai.apiKey,
      'Content-Type': 'application/json'
    }
    this.url = config.ai.url
    this.body = {
      "model": "",
      "messages": [
        {
          "role": "user",
          "content": [
            {
              type:"text",
              text:''
            }
          ]
        }
      ],
      stream:false,
      temperature:config.ai.temperature,
    }
  }
  upData(){
    this.headers = {
      'Authorization': "Bearer " + config.ai.apiKey,
      'Content-Type': 'application/json'
    }
    this.url = config.ai.url;
  }
  async getReply(chatRecord:Array<Interfaces.Messages>):Promise<Interfaces.ReturnData> {
    chatRecord = this.limitChatRounds(chatRecord);
    let body = this.toHttpBody(chatRecord);
    let resp:Interfaces.Groq | Interfaces.OpenAI | Interfaces.DeepSeek;
    try {
      if (config.currSupplier === 'Groq') {
        resp =
          await myRequest<Interfaces.Groq, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
            body);
      }else if (config.currSupplier === 'DeepSeek'){
        resp =
          await myRequest<Interfaces.DeepSeek, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
            body);
      }else{
        resp =
          await myRequest<Interfaces.OpenAI, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
            body);
      }
      if (!resp || !resp.choices || resp.choices.length === 0 || !resp.choices[0].message || !resp.choices[0].message.content) {
        throw new Error("响应数据不完整");
      }
      let dataR:Interfaces.ReturnData
      if(config.currSupplier === 'DeepSeek'){
        dataR = {
          token:resp.usage.total_tokens,
          message:resp.choices[0].message as Interfaces.DeepSeekMessage
        }
      }else{
        dataR = {
          token:resp.usage.total_tokens,
          message:resp.choices[0].message.content as string
        }
      }
      return dataR

    } catch (error) {
      console.error('错误:', JSON.stringify(error));
      let dataR:Interfaces.ReturnData = {
        token:0,
        message:''
      };
      if(config.currSupplier === 'OpenAI'){
        if(JSON.parse(error)?.code === "insufficient_quota"){
          dataR.message = 'Token余额不足';
        }else if(JSON.parse(error)?.code === "invalid_api_key"){
          dataR.message = 'Key错误';
        }else if(JSON.stringify(error) === '网络问题' || JSON.stringify(error) === 'Request timed out'){
          dataR.message = `网络错误。请检查当前的网络状态，以及与${config.ai.url}的连接情况。`;
        }else{
          dataR.message = '意料之外的错误';
        }
      }
      return dataR
    }
  }
   async getItemName(chatRecord:Array<Interfaces.Messages>):Promise<Interfaces.ReturnData> {
     let data:Array<Interfaces.Messages> = [...chatRecord];
     data.push({role:"user",content:[{type:'text',text:"请你基于以上对话，给我们此次交流的主题命名，要求不超过30字，且你只答复名字本身，不要包含其他内容，名字本身不需要用《》等符号包裹。"}]})
     let body1:Interfaces.RequestBody = this.toHttpBody(data);
     let resp:Interfaces.Groq | Interfaces.OpenAI;
     try {
       if (config.currSupplier === 'Groq') {
         resp =
           await myRequest<Interfaces.Groq, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
             body1);
       }else if (config.currSupplier === 'DeepSeek'){
         resp =
           await myRequest<Interfaces.OpenAI, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
             body1);
       }else{
         resp =
           await myRequest<Interfaces.OpenAI, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
             body1);
       }
       if (!resp || !resp.choices || resp.choices.length === 0 || !resp.choices[0].message || !resp.choices[0].message.content) {
         throw new Error("响应数据不完整");
       }
       const dataR:Interfaces.ReturnData = {
         token:resp.usage.total_tokens,
         message:resp.choices[0].message.content as string
       }
       return dataR

     } catch (error) {
       console.error('错误:', error);
       let dataR:Interfaces.ReturnData = {
         token:0,
         message:''
       };
      if(config.currSupplier === 'OpenAI'){
          if(JSON.parse(error)?.code === "insufficient_quota"){
            dataR.message = 'Token余额不足';
          }else if(JSON.parse(error)?.code === "invalid_api_key"){
            dataR.message = 'Key错误';
          }else if(JSON.stringify(error) === '网络问题' || JSON.stringify(error) === 'Request timed out'){
            dataR.message = `网络错误。请检查当前的网络状态，以及与${config.ai.url}的连接情况。`;
          }else{
            dataR.message = '意料之外的错误';
          }
      }
       return dataR
     }
   }
  async testLink(model:string,apiKey:string,url:string):Promise<Interfaces.ReturnData> {
    let body:Interfaces.RequestBody = {
      model:model,
      messages:[
        {
          role:'user',
          content:[
            {
              type:'text',
              text:'你好'
            }
          ]
        }
      ],
      temperature:1
    }
    let headers:Interfaces.HttpHeaders = {
      'Authorization': "Bearer " + apiKey,
      'Content-Type': 'application/json'
    }
    let resp:Interfaces.Groq | Interfaces.OpenAI | Interfaces.DeepSeek;
    try {
      if (config.currSupplier === 'Groq') {
        resp =
          await myRequest<Interfaces.Groq, Interfaces.RequestBody>(url, http.RequestMethod.POST, headers,
            body);
      }else if (config.currSupplier === 'DeepSeek'){
        resp =
          await myRequest<Interfaces.DeepSeek, Interfaces.RequestBody>(url, http.RequestMethod.POST, this.headers,
            body);
      }else{
        resp =
          await myRequest<Interfaces.OpenAI, Interfaces.RequestBody>(url, http.RequestMethod.POST, this.headers,
            body);
      }
      if (!resp || !resp.choices || resp.choices.length === 0 || !resp.choices[0].message || !resp.choices[0].message.content) {
        throw new Error("响应数据不完整");
      }
      const dataR:Interfaces.ReturnData = {
        token:resp.usage.total_tokens,
        message:resp.choices[0].message.content as string
      }
      return dataR

    } catch (error) {
      console.error('错误:', error);
      let dataR:Interfaces.ReturnData = {
        token:0,
        message:''
      };
      if(config.currSupplier === 'OpenAI'){
        if(JSON.parse(error)?.code === "insufficient_quota"){
          dataR.message = 'Token余额不足';
        }else if(JSON.parse(error)?.code === "invalid_api_key"){
          dataR.message = 'Key错误';
        }else if(JSON.stringify(error) === '网络问题' || JSON.stringify(error) === 'Request timed out'){
          dataR.message = `网络错误。请检查当前的网络状态，以及与${config.ai.url}的连接情况。`;
        }else{
          dataR.message = '意料之外的错误';
        }
      }
      return dataR
    }
  }

  toHttpBody(chatRecord:Array<Interfaces.Messages>):Interfaces.RequestBody{
    let body:Interfaces.RequestBody = {
      model:config.ai.model,
      messages:chatRecord,
      stream:false,
      temperature:config.ai.temperature
    }
    return body
  }

  toRecordItem(name:string,data:Interfaces.ReturnData | string,ImageUrl:Array<string>):Interfaces.Messages{
    let messages:Interfaces.Messages;
    if(name == 'assistant'){
      messages = {
        role:name,
        content: (data as Interfaces.ReturnData).message as string
      }
    }else{
      messages = {
        role:name,
        content:[
          {
            type:"text",
            text:data as string
          }
        ]
      }
    }
    if(name != 'assistant'){
      for(let i=0;i<ImageUrl.length;i++){
        (messages.content as Array<Interfaces.ContentItem>).push(
          {
            type:"image_url",
            image_url:{
              "url":`data:image/jpeg;base64,{${ImageUrl[i]}}`
            }
          }
        )
      }
    }
		return messages;
	}

  limitChatRounds(chatRecord:Array<Interfaces.Messages>):Array<Interfaces.Messages>{
    if((chatRecord.length - 1) / 2 > config.ai.chatRounds){
      return chatRecord.splice(0,1).concat(chatRecord.splice(chatRecord.length - config.ai.chatRounds));
    }else{
      return chatRecord;
    }
  }
  async toImageUrl(file:ArrayBuffer): Promise<string>{
    console.log("获取图片链接中：" + file)
    let headers: Interfaces.HttpHeaders = {'Authorization': 's1v5Y67DfUvQkjA1GSF6a3bbgI5VYT7n'}
    let url = 'https://sm.ms/api/v2/upload';
    let resp:Interfaces.SmMs;
    try {
      resp = await myRequest<Interfaces.SmMs,ArrayBuffer>(url,http.RequestMethod.POST,headers,file);
      return resp.data.url;
    } catch (error) {
      console.log("上传错误" + error);
      return "上传失败";
    }
  }
}

const aiModel = new AIModel();
export { aiModel };