import { config } from "../../config"

@Builder
export function TalkBuilder() {
  TalkPage()
}
@Entry
@Component
struct TalkPage{
  pathStack: NavPathStack | null = null
  @State chatPrompt:string = config.ai.chatPrompt
  @State autoTitle:boolean = true
  @State autoSync:boolean = false
  @State button_apply:boolean = false
  build() {
    NavDestination() {
      Column({space:24}){
        Column({space:4}){
          Text($r('app.string.Talk_NewChat_Prompt'))
          TextArea({text:$$this.chatPrompt})
            .width('100%')
            .height('30%')
            .onChange(()=>{
              this.button_apply = true
            })
          Button($r('app.string.Button_Reset_Prompt'),{ buttonStyle:ButtonStyleMode.TEXTUAL })
            .type(ButtonType.Normal)
            .borderRadius(8)
            .onClick(()=>{
              if(config.display.language === '简体中文'){
                this.chatPrompt = "你是一个知识渊博且细致的助手，能够以专业、简洁和友好的语气回答问题。无论用户提出的问题有多复杂，你都要提供清晰、有条理的回答。请使用中文回答问题。";
              }else{
                this.chatPrompt = "You are a knowledgeable and meticulous assistant, able to answer questions with professionalism, conciseness, and friendliness. No matter how complex the questions posed by users are, you provide clear and organized responses.Please respond in English.";
              }
            })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)
        Row({space:4}){
          Toggle({ type: ToggleType.Switch, isOn: $$this.autoTitle })
            .onChange(()=>{
              this.button_apply = true
            })
          Text($r('app.string.Talk_Auto_Title'))
        }
        Row({space:4}){
          Toggle({ type: ToggleType.Switch, isOn: this.autoSync })
            .onChange(async (isOn: boolean)=>{
              if (isOn){
                const hasPermission = await config.checkPermission(); // 预检查权限状态
                if (!hasPermission) {
                  const isGranted = await config.requestDistributedSyncPermission();
                  this.autoSync = isGranted; // 根据最终授权结果设置状态
                } else {
                  this.autoSync = true; // 已有权限直接生效
                }
              } else {
                this.autoSync = false; // 关闭开关无需处理权限
              }
            })
          Text($r('app.string.Talk_Auto_Title'))
        }
        Blank()
        Row({space:24}){
          Button($r('app.string.Button_Cancel'),{buttonStyle:ButtonStyleMode.TEXTUAL})
            .onClick(()=>{
              this.pathStack?.pop();
            })
          Button($r('app.string.Button_apply'),{buttonStyle:ButtonStyleMode.TEXTUAL})
            .enabled(this.button_apply)
            .onClick(()=>{
              config.upDateChatPrompt(this.chatPrompt,this.autoTitle);
              this.pathStack?.pop();
            })
        }.width('100%')
        .alignSelf(ItemAlign.End)
        .justifyContent(FlexAlign.End)
      }
      .width('100%').height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .padding(20)
    }
    .width('100%').height('100%')
    .title("对话设置")
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext)=>{
      this.pathStack = context.pathStack;
    })
  }
}