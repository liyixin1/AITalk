import { config } from '../../config'
import { aiModel } from '../../ai_model'
import { preferenceUtil } from '../../common/Index'
import * as Interfaces from '../../interface';
@Builder
export function ModelBuilder() {
  ModelPage()
}

@Entry
@Component
struct ModelPage{
  pathStack: NavPathStack | null = null
  @State currSelectProviderText:string = ''
  @State currSelectModelText:string = ''
  @State url:string = ''
  @State apiKey:string = ""
  @State currProvider:number = 0
  @State currModel:number = 0
  @State sliderTemperature:number = 1
  @State sliderChatRound:number = 1
  provider:Array<SelectOption> = []
  model:Array<Array<SelectOption>> = []

  aboutToAppear(): void {
    if (!config.isConfigReady) {
      setTimeout(() => this.aboutToAppear(), 100); // 轮询等待
      return;
    }
    this.currSelectProviderText = config.currSupplier
    this.currSelectModelText = config.ai.model
    this.apiKey = config.ai.apiKey
    this.sliderTemperature = config.ai.temperature
    this.sliderChatRound = config.ai.chatRounds
    this.provider = config.providerName;
    this.model = config.providerModel;
    this.currProvider = this.provider.findIndex((item:SelectOption)=>item.value.toString() === this.currSelectProviderText)
    this.url = config.ai.url
  }
  @Builder selectProvider(data:Array<SelectOption>){
    Select(data)
      .width('50%')
      .borderRadius(8)
      .selected($$this.currProvider)
      .value($$this.currSelectProviderText)
      .font({ size: 16, weight: 500 })
      .fontColor($r('sys.color.font_primary'))
      .selectedOptionFont({ size: 16, weight: 400 })
      .optionFont({ size: 16, weight: 400 })
      .menuAlign(MenuAlignType.START, {dx:0, dy:0})
      .optionWidth(200)
      .optionHeight(300)
      .onSelect((index:number, text: string)=>{
        console.info('Select:' + index)
        let val = preferenceUtil.readDate(this.currSelectProviderText,config.ai) as Interfaces.Parameter;
        this.url = val.url;
        this.apiKey = val.apiKey;
        this.currSelectModelText = val.model != ""?val.model:this.model[index][0].value as string
        this.currModel = this.model[index].findIndex((item:SelectOption)=>item.value.toString() === val.model);
        this.sliderTemperature = val.temperature;
        this.sliderChatRound = val.chatRounds;
        this.currSelectProviderText = text
      })
  }
  build() {
    NavDestination() {
      Column({space:24}){
        Column({space:4}){
          Text($r('app.string.Model_provider'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
          Row({space:8}){
            this.selectProvider(this.provider)
            if(this.currProvider >= 3){
              Button($r('app.string.Model_Delete_Button'),{type:ButtonType.Normal,buttonStyle:ButtonStyleMode.EMPHASIZED,controlSize:ControlSize.SMALL})
                .borderRadius(8)
                .backgroundColor($r('sys.color.comp_background_emphasize'))
                .onClick(()=>{
                  this.provider.splice(this.currProvider,1);
                  this.currProvider -= 1;
                  this.currSelectProviderText = this.provider[this.currProvider].value.toString()
                  let val = preferenceUtil.readDate(this.currSelectProviderText,config.ai) as Interfaces.Parameter;
                  this.url = val.url;
                  this.apiKey = val.apiKey;
                  this.currSelectModelText = val.model
                  this.currModel = this.model[this.currProvider].findIndex((item:SelectOption)=>item.value.toString() === val.model);
                  this.sliderTemperature = val.temperature;
                  this.sliderChatRound = val.chatRounds;
                  config.deleteUserDefinedModel();
                })
            }
          }
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
          TextInput({text:this.apiKey, placeholder: 'API Key'})
            .type(InputType.Password)
            .borderRadius(8)
            .fontColor($r('sys.color.font_primary'))
            .onChange((value)=>{
              this.apiKey = value;
            })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)

        Column({space:4}){
          Text($r('app.string.Model_model'))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
            Select(this.model[this.currProvider] ?? [])
              .width('80%')
              .borderRadius(8)
              .selected($$this.currModel)
              .value($$this.currSelectModelText)
              .font({ size: 16, weight: 500 })
              .fontColor($r('sys.color.font_primary'))
              .selectedOptionFont({ size: 16, weight: 400 })
              .optionFont({ size: 16, weight: 400 })
              .menuAlign(MenuAlignType.START, {dx:0, dy:0})
              .optionWidth(200)
              .optionHeight(300)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        Text($r('app.string.Model_Temperature'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
        Row({space:4}){
          Slider({
            value: $$this.sliderTemperature,
            min: 0.01,
            max: 2,
            step: 0.01,
            style: SliderStyle.OutSet
          })
            .showTips(true,this.sliderTemperature.toFixed(2))
            // .backgroundColor($r('sys.color.comp_background_secondary'))
            // .onChange((value: number, mode: SliderChangeMode) => {
            //   this.sliderTemperature = value
            //   console.info('value:' + value + 'mode:' + mode.toString())
            // })
          Text(this.sliderTemperature.toFixed(2)).fontSize(12)
        }.width("90%")
        Text($r('app.string.Model_Context'))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
        Row({space:4}){
          Slider({
            value: $$this.sliderChatRound,
            min: 0,
            max: 30,
            step: 2,
            style: SliderStyle.OutSet
          })
            .showSteps(true)
            .showTips(true,this.sliderChatRound.toFixed(0))
            // .onChange((value: number, mode: SliderChangeMode) => {
            //   this.sliderChatRound = value
            //   console.info('value:' + value + 'mode:' + mode.toString())
            // })
          Text(this.sliderChatRound.toFixed(0)).fontSize(12)
        }.width('90%')
        Row(){
          Button($r('app.string.Button_Test_Connection'), { type: ButtonType.Normal, stateEffect: true })
            .borderRadius(8)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .onClick(async ()=>{
              const temp = await aiModel.testLink(this.currSelectModelText,this.apiKey,this.url)
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
              config.upDateModelSet(this.currSelectProviderText,this.url,this.apiKey,this.currSelectModelText,this.sliderChatRound,this.sliderTemperature);
              aiModel.upData();
              this.pathStack?.pop()
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