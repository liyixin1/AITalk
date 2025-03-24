//DeepSeek
export interface DeepSeekStream{
  choices:Array<DeepSeekChoices>,
  created:number,
  id:string,
  model:string,
  object:string,
  usage?:DeepSeekUsage | null
  system_fingerprint:string
}
interface DeepSeekChoices{
  delta:DeepSeekChoicesDelta,
  finish_reason:string | null,
  index:number,
  logprobs:string | null
}
interface DeepSeekUsage{
  completion_tokens:number,
  prompt_tokens:number,
  total_tokens:number,
}
interface DeepSeekChoicesDelta{
  content:string,
  role:string
}
//Groq
export interface GroqStream{
  choices:Array<GroqChoices>,
  created:number,
  id:string,
  model:string,
  object:string,
  system_fingerprint:string
  x_groq?:GroqStreamx_groq
}
interface GroqChoices{
  delta:GroqChoicesDelta,
  finish_reason:string | null,
  index:number,
  logprobs:string | null
}
interface GroqChoicesDelta{
  content:string,
  role?:string
}
interface GroqStreamx_groq{
  id:string,
  usage?:StreamUsage
}
interface StreamUsage{
  queue_time:number,
  completion_tokens:number,
  completion_time:number,
  prompt_tokens:number,
  prompt_time:number,
  total_tokens:number,
  total_time:number
}
//openai
export interface OpenAIStream{
  id:string,
  object:string,
  created:number,
  model:string,
  system_fingerprint:string
  choices:Array<OpenAIChoices>
}
interface OpenAIChoices{
  delta:OpenAIChoicesDelta,
  finish_reason:string | null,
  index:number
}
interface OpenAIChoicesDelta{
  content:string,
  role?:string
}
// //claude
// export interface ClaudeStream{
//
// }
// //Ollama
// export interface OllamaStream{
//
// }
