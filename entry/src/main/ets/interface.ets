// 模型参数
export interface Parameter {
  url:string,
  apiKey:string,
  model: string,
  chatRounds:number,
  temperature: number,
  chatPrompt:string,
  autoTitle:boolean
}
// // 模型
// export interface Models {
//   url:string,
//   apiKey:string,
//   model: string,
//   chatRounds:number,
//   temperature: number,
//   chatPrompt:string,
//   autoTitle:boolean
// }
// Token消耗
export interface TokenUsage{
  groq:TokenUsageItem,
  openai:TokenUsageItem
}
// 显示设置参数
export interface Display {
  language:string,
  fontsize:number,
  theme:number
  showNumberOfReplies:boolean,
  showNumberOfTokenExpend:boolean
}

export interface HttpHeaders {
  'Authorization'?: string;
  'Content-Type'?: string;
}
export interface RequestBody {
  model: string,
  messages: Array<Messages>;
  stream?: boolean,
  temperature:number,
}
export interface Messages {
  role: string,
  content: Array<ContentItem> |string
}
export interface Messages2 {
  role: string,
  content: Array<ContentItem> |string,
  token:string
}
export interface ContentItem {
  type:string,
  text?:string,
  image_url?:ContentItemImage
}
export interface ContentItemImage {
  url:string
}
export interface ContentAssistant {
  text:string,
  tokenUsage:number
}

//
export interface UserList{
  name:ListItem
}
export interface ListItem{
  id:string,
  name:string
}

// list返回带参
export interface ListParam {
  name:string
}

//
export interface MessageHistory{
  id:number,
  name:string,
  datetime:string
}

// //聊天记录显示列表
// export interface ChatRecord{
//   sender: "User" | "Assistant"
//   message:string
// }

//model.json数据结构
export interface Provider{
  name:string,
  model:Array<string>,
  url:string
}

// 我的界面列表项
export interface setListItem{
  text:Resource,
  prompt?:Resource,
  icon:ResourceStr | null,
  name:string
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
  x_groq?: GroqX_groq
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
interface GroqError{
  error:GroqErrorContent
}
interface GroqErrorContent{
  message:string,
  type:string
}
export interface ReturnData{
  token:number,
  message:string | DeepSeekMessage
}

// 定义openai通用数据
export interface OpenAI{
  id: string,
  object: string,
  created: number,
  model: string,
  choices:Array<OpenAIChoices>
  usage: OpenAIUsage,
}
interface OpenAIChoices{
  index:number,
  message:Messages,
  logprobs?:null|string|number,
  finish_reason:string,
}
interface OpenAIUsage{
  prompt_tokens: number,
  completion_tokens: number,
  total_tokens: number
}
interface OpenAIError{
  error:OpenAIErrorContent
}
interface OpenAIErrorContent{
  code:string | null,
  message:string,
  type:string
}


export interface DeepSeek{
  id: string,
  object: string,
  created: number,
  model: string,
  choices:Array<OpenAIChoices>,
  usage: OpenAIUsage,
  system_fingerprint:string
}
interface DeepSeekChoices{
  finish_reason:string,
  index:number,
  message:DeepSeekMessage,
  logprobs:null|string|number,
}
export interface DeepSeekMessage{
  content:string,
  reasoning_content:string
  tool_calls: Array<DeepSeekToolCalls>
  role:string
}
interface DeepSeekToolCalls{
  id:string,
  type:string
  function:DeepSeekFunction
}
interface DeepSeekFunction{
  name:string,
  arguments:string
}
interface DeepSeekLogprobs{
  content:Array<DeepSeekLogprobsContent>
}
interface DeepSeekLogprobsContent{
  token:string,
  logprob:number,
  bytes:Array<number>
  top_logprobs:Array<DeepSeekLogprobsContentTopLogprobs>
}
interface DeepSeekLogprobsContentTopLogprobs{
  token:string,
  logprob:number,
  bytes:Array<number>
}

//sm.ms图床
export interface SmMs{
  success:boolean,
  code:string,
  message:string,
  data:SmMsData,
  RequestId:string
}
export interface SmMsData{
  ile_id: number,
  width: number,
  height: number,
  filename: string,
  storename: string,
  size: number,
  path: string,
  hash: string,
  url: string,
  delete: string,
  page: string
}

export interface TokenUsageItem{
  total:number,
  account_balance:number,
}
