import { dbUtil } from '../../common/Index'
import * as Interfaces from '../../interface'
import { PromptActionClass } from './PromptActionClass'

@Builder
export function changName(params: Interfaces.MessageHistory) {
  Column({space:8}) {
    Text($r('app.string.Chang_Name'))
      .fontSize(30)
      .fontWeight(FontWeight.Bold)
      .alignSelf(ItemAlign.Center)
    TextInput({text: params.name})
      .caretColor('#90EE90')
      .onChange((value:string)=>{
        params.name = value
      })
    Row({space:4}){
      Button($r('app.string.Button_Cancel'))
        .width('35%')
        .borderRadius(8)
        .onClick(()=>{
          PromptActionClass.closeDialog()
        })
      Button($r('app.string.Button_apply'))
        .width('35%')
        .borderRadius(8)
        .onClick(()=>{
          dbUtil.upDataById("myList",params.id,{NAME:params.name});
          PromptActionClass.closeDialog()
        })
    }
    .justifyContent(FlexAlign.Center)
  }
  .width('80%')
  .height('30%')
  .borderRadius(16)
  .backgroundColor($r('sys.color.background_primary'))
}
