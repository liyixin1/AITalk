import { config } from '../../config'
import { aiModel } from '../../ai_model'

@Builder
export function NewModelBuilder() {
  NewModelPage()
}

@Entry
@Component
struct NewModelPage{
  pathStack: NavPathStack | null = null
  @State provider:string = ''
  @State model:string = ''
  @State url:string = ''
  @State apiKey:string = ""
  @State sliderTemperature:number = 1
  @State sliderChatRound:number = 20

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column({space:24}){
        Column({space:5}){
          Text($r('app.string.Model_provider'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
          TextInput({text:$$this.provider})
            .borderRadius(8)
            .fontColor($r('sys.color.font_primary'))
          Text($r('app.string.Model_url'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
          TextInput({text:$$this.url})
            .borderRadius(8)
            .fontColor($r('sys.color.font_primary'))
          Divider()
            .strokeWidth(2)
            .vertical(false)
            .padding({ top:16,bottom:16 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        Column({space:4}){
          Text('ApiKey:')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
          TextInput({text:$$this.apiKey, placeholder: 'API Key'})
            .type(InputType.Password)
            .borderRadius(8)
            .fontColor($r('sys.color.font_primary'))
            // .onChange((value)=>{
            //   this.apiKey = value;
            // })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({space:4}){
          Text($r('app.string.Model_model'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
          TextInput({text:$$this.model})
            .borderRadius(8)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        Text($r('app.string.Model_Temperature'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
        Row({space:4}){
          Slider({
            value: 1,
            min: 0.01,
            max: 2,
            step: 0.01,
            style: SliderStyle.OutSet
          })
            .showTips(true,this.sliderTemperature.toFixed(2))
              // .backgroundColor($r('sys.color.comp_background_secondary'))
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderTemperature = value
              console.info('value:' + value + 'mode:' + mode.toString())
            })
          Text(this.sliderTemperature.toFixed(2)).fontSize(12)
        }.width("90%")
        Text($r('app.string.Model_Context'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
        Row({space:4}){
          Slider({
            value: this.sliderChatRound,
            min: 0,
            max: 30,
            step: 2,
            style: SliderStyle.OutSet
          })
            .showSteps(true)
            .showTips(true,this.sliderChatRound.toFixed(0))
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderChatRound = value
              console.info('value:' + value + 'mode:' + mode.toString())
            })
          Text(this.sliderChatRound.toFixed(0)).fontSize(12)
        }.width('90%')
        Row(){
          Button($r('app.string.Button_Test_Connection'), { type: ButtonType.Normal, stateEffect: true })
            .borderRadius(8)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .onClick(async ()=>{
              const temp = await aiModel.testLink(this.model,this.apiKey,this.url)
              if (temp.token === 0) {
                AlertDialog.show({
                  message: temp.message as string
                })
              }else{
                AlertDialog.show({
                  message: '测试通过'
                })
              }
            })
        }
        Blank()
        Row({space:24}){
          Button($r('app.string.Button_Cancel'),{buttonStyle:ButtonStyleMode.TEXTUAL})
            .onClick(()=>{
              this.pathStack?.pop();
            })
          Button($r('app.string.Button_apply'),{buttonStyle:ButtonStyleMode.TEXTUAL})
            .onClick(()=>{
              config.newModel(this.provider,this.url,this.apiKey,this.model,this.sliderChatRound,this.sliderTemperature)
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
    .title("模型设置")
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext)=>{
      this.pathStack = context.pathStack;
    })
  }
}