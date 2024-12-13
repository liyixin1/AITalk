import { preferenceUtil } from '../../common/Index'
import * as Interfaces from './interface';
export class ConfigManager{
  // 配置模型参数
  ai:Interfaces.Parameter;
  messageList:Array<Interfaces.MessageHistory>;
  // provider:Interfaces.Providers
  // ListItem:Interfaces.UserList
  constructor(){
    this.ai = {
      "supplierName": "Groq",
      "apiKey": "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",
      "model": "mixtral-8x7b-32768",
      "chatRounds": 1000,
      "maxTokens": 4096,
      "chatPrompt": "请使用中文回复我。如果发现我的语句不通顺，先显式纠正，再根据纠正后的语句回答，注意区分口语和书面语。尽可能使用更加人性化的语气。",
    }
    this.messageList = [
      {
        id:10001,
        name:'第一次对话',
        datetime:'2000.1.1'
      }
    ]
    if(preferenceUtil.readDate('isFirstRun',false)){
      preferenceUtil.upData('isFirstRun',false);
      preferenceUtil.insertData('ai',this.ai);
      preferenceUtil.insertData('messageList',this.messageList)
    }else{
      this.ai = preferenceUtil.readDate('ai',this.ai) as Interfaces.Parameter
      this.messageList = preferenceUtil.readDate('messageList',this.messageList) as Array<Interfaces.MessageHistory>
    }
  }
  deleteListItem(index:number){
    this.messageList.splice(index,1);
    preferenceUtil.upData('messageList',this.messageList);
  }
}

const config = new ConfigManager();
export { config };