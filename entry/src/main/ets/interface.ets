export interface Parameter {
  supplierName: string,
  apiKey:string,
  model: string,
  chatRounds: number,
  maxTokens:number,
  chatPrompt:string,
}
export interface HttpHeaders {
  'Authorization'?: string;
  'Content-Type': string;
}
export interface RequestBody {
  model: string,
  messages: Array<Messages>;
  stream?: boolean,
}
export interface Messages {
  role: string;
  content: Array<ContentItem> | string;
}
export interface ContentItem {
  type:string;
  text:string;
}

//
export interface Providers {
  name:ApiEndpoints,
}
export interface ApiEndpoints {
  model:Array<string>,
  url:string
}

//
export interface UserList{
  name:ListItem
}
export interface ListItem{
  id:string,
  name:string
}

//
export interface MessageHistory{
  id:number,
  name:string,
  datetime:string
}

//聊天记录显示列表
export interface ChatRecord{
  sender: "User" | "Assistant"
  message:string
}

// 定义groq数据
export interface Groq{
  id: string,
  object: string,
  created: number,
  model: string,
  choices:Array<GroqChoices>
  usage: GroqSsage,
  system_fingerprint:string,
  x_groq: GroqX_groq
}
interface GroqChoices{
  index:number,
  message:Messages,
  logprobs:null|string|number,
  finish_reason:string,

}
interface GroqX_groq {
  id: string;
}
interface GroqSsage {
  queue_time: number,
  prompt_tokens: number,
  prompt_time: number,
  completion_tokens: number,
  completion_time: number,
  total_tokens: number,
  total_time: number
}