import { config } from './config'
import * as Interfaces from './interface';
import { myRequest } from '../../common/Index'
import { http } from '@kit.NetworkKit';
import json from '@ohos.util.json';

class AIModel{
  headers:Interfaces.HttpHeaders;
  url:string;
  constructor(){
    this.headers = {
      'Authorization': "Bearer " + config.ai.apiKey,
      // 'Authorization': "Bearer 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",
      'Content-Type': 'application/json'
    }
    this.url = "https://api.groq.com/openai/v1/chat/completions"
  }
  html:string = ""
  body:Interfaces.RequestBody = {
    "model": "gemma-7b-it",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            type:"text",
            text:'你好'
          }
        ]
      }
    ],
    stream:false
  }
  async getReply(chatRecord:Array<Interfaces.Messages>):Promise<string> {
    chatRecord = this.limitChatRounds(chatRecord);
    this.body = this.toHttpBody(chatRecord);
    try {
      if (config.ai.supplierName == 'Groq') {
        let resp =
          await myRequest<Interfaces.Groq, Interfaces.RequestBody>(this.url, http.RequestMethod.POST, this.headers,
            this.body);
        return resp.choices[0].message.content as string
      }else{
        return "";
      }
    } catch (error) {
      console.error('错误:', error);
      return ""
    }
  }
  // {"error":{"message":"invalid data (sid: cha000b3160@dx193b39d1d36b8f2532)","type":"invalid_request_error","param":null,"code":"10003"}}
  //{"code":0,"message":"Success","sid":"cha000b502f@dx193b39e5239b894532","choices":[{"message":{"role":"assistant","content":"你好，有什么我可以帮助你的吗？"},"index":0}],"usage":{"prompt_tokens":9,"completion_tokens":9,"total_tokens":18}}

  toHttpBody(chatRecord:Array<Interfaces.Messages>):Interfaces.RequestBody{
    let body:Interfaces.RequestBody = {
      model:config.ai.model,
      messages:chatRecord,
      stream:false
    }
    return body
  }

  toRecordItem(name:string,input:string):Interfaces.Messages{
    let messages:Interfaces.Messages;
    if(name === 'assistant'){
      messages = {
        role:name,
        content:input
      }
    }else{
      messages = {
        role:name,
        content:[
          {
            type:"text",
            text:input
          }
        ]
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
}
const aiModel = new AIModel();
export { aiModel };