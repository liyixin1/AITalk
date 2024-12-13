import * as Interfaces from '.././interface';
import { config } from '../config'
import { aiModel } from '../ai_model'
import { lvMarkdownIn, lvText  } from "@luvi/lv-markdown-in"
import { inputMethod } from '@kit.IMEKit';

@Builder
export function ListItemBuilder() {
  ListItemPage()
}
@Preview
@Component
struct ListItemPage {
  pathStack: NavPathStack | null = null
  @State itemName:string = ""
  @State chatRecord:Array<Interfaces.Messages> = [
    {
      role:'system',
      content:config.ai.chatPrompt
    },
  ]
  @State userInput:string = ""

  aboutToAppear(): void {

  }
  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }){
        Column(){
          List(){
            ForEach(this.chatRecord,(chat:Interfaces.Messages)=>{
              ListItem(){
                if(chat.role == 'assistant'){
                  Row(){
                    Image($r('app.media.huaweilogo1'))
                      .width(48).height(48)
                    lvMarkdownIn({text:chat.content as string})
                      .width('70%')
                  }.width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top)
                }else if(chat.role == 'user'){
                  Row(){
                    lvMarkdownIn({text:(chat.content[0] as Interfaces.ContentItem).text})
                      .width('70%')
                    Image($r('app.media.huaweilogo1'))
                      .width(48).height(48)
                  }.width('100%').justifyContent(FlexAlign.End).alignItems(VerticalAlign.Top)
                }
              }.width('100%')
            })
          }.height('100%')
          .width('100%')
        }
        .width("100%")
        .height('95%')
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.End}){
          Button({ type:ButtonType.Circle }){
            Image($r('app.media.mic_circle'))
          }.width(32)
          .height(32)
          .flexGrow(0)
          .buttonStyle(ButtonStyleMode.TEXTUAL)
          .margin(5)
          TextArea()
            .id('userInput')
            .type(TextAreaType.NORMAL)
            .width('50%')
            .flexGrow(1)
            .margin(5)
            .onChange((value:string)=>{
              this.userInput = value;
            })
          Button({ type:ButtonType.Circle }){
            Image($r('app.media.mic_circle'))
          }.width(32).height(32).flexGrow(0).margin(5).buttonStyle(ButtonStyleMode.TEXTUAL)
          Button('发送',{type:ButtonType.Normal, stateEffect: true })
            .width(64).height(32).buttonStyle(ButtonStyleMode.EMPHASIZED).borderRadius(10).flexGrow(0).margin(5)
            .onClick(async ()=>{
              if(this.userInput != ""){
                this.chatRecord.push(aiModel.toRecordItem('user',this.userInput))
                inputMethod.getController().stopInputSession();
                this.chatRecord.push(aiModel.toRecordItem('assistant',await aiModel.getReply(this.chatRecord)))
                console.log((this.chatRecord[this.chatRecord.length - 1].content[0] as Interfaces.ContentItem).text)
              }
            })
        }.width('100%').constraintSize({maxHeight:"40%"})
      }.width('100%').height('100%')
    }.width('100%').height('100%')
    .title(this.itemName)
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext)=>{
      this.pathStack = context.pathStack

    })
  }
}