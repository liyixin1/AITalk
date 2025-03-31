import { config } from "../../config"
import { i18n } from "@kit.LocalizationKit"
import { BusinessError } from "@kit.BasicServicesKit"

@Builder
export function DisPlayBuilder() {
  DisPlayPage()
}
@Entry
@Component
struct DisPlayPage{
  pathStack: NavPathStack | null = null
  @State currLang:number = 0
  @State currLangText:string = ''
  langIsChang:boolean = false
  @State currFontSize:number = 10
  @State currFontSelect:number = 0
  @State currTheme:number = 0
  @State currThemeText:Resource | string = $r('app.string.Display_Theme_Auto')
  themeIsChang:boolean = false
  @State showNumberOfReplies:boolean = true
  @State showNumberOfTokenExpend:boolean = true
  fontsizeList:SelectOption[] = [{value:'10'},{value:'12'},{value:'14'},{value:'16'},{value:'18'},{value:'20'},{value:'22'},{value:'24'}]

  aboutToAppear(): void {
    this.currLangText = config.display.language;
    this.currLang = config.getLangNum(config.display.language);
    this.currFontSize = config.display.fontsize;
    for (let i = 0; i < this.fontsizeList.length; i++) {
      if (this.currFontSize.toString() == this.fontsizeList[i].value) {
        this.currFontSelect = i;
        break;
      }
    }
    this.currTheme = config.display.theme;
    this.showNumberOfReplies = config.display.showNumberOfReplies;
    this.showNumberOfTokenExpend = config.display.showNumberOfTokenExpend;
    if(this.currTheme === 0){
      this.currThemeText = $r('app.string.Display_Theme_Dark')
    }else if (this.currTheme === 1){
      this.currThemeText = $r('app.string.Display_Theme_Light')
    }
  }
  build() {
    NavDestination() {
      Column({space:24}){
        Column({space:4}){
          Text($r('app.string.Display_Lang'))
          Select([{value:'简体中文'},{value:'English'}])
            .width('100%')
            .selected($$this.currLang)
            .value($$this.currLangText)
            .borderRadius(8)
            .onSelect((index:number,text:string)=>{
              this.currLang = index;
              this.currLangText = text;
              this.langIsChang = true;
            })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)
        Column({space:4}){
          Text($r('app.string.Display_Font_Size'))
          Select(this.fontsizeList)
            .width('100%')
            .selected($$this.currFontSelect)
            .value(this.currFontSize.toString())
            .borderRadius(8)
            .onSelect((index:number,value:string)=>{
              this.currFontSelect = index
              this.currFontSize = Number(value)
            })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)
        Column({space:4}){
          Text($r('app.string.Display_Theme'))
          Select([{value:$r('app.string.Display_Theme_Dark')},{value:$r('app.string.Display_Theme_Light')},{value:$r('app.string.Display_Theme_Auto')}])
            .width('100%')
            .selected(this.currTheme)
            .value(this.currThemeText)
            .borderRadius(8)
            .onSelect((index:number,text:string)=>{
              this.currTheme = index;
              this.currThemeText = text;
              this.themeIsChang = true;
            })
        }.width('100%')
        .alignItems(HorizontalAlign.Start)
        Row({space:4}){
          Toggle({ type: ToggleType.Switch, isOn: $$this.showNumberOfReplies })
          Text($r('app.string.Display_Theme_NumberOfReplies'))
        }
        Row({space:4}){
          Toggle({ type: ToggleType.Switch, isOn: $$this.showNumberOfTokenExpend })
          Text($r('app.string.Display_Theme_NumberOfTokenExpend'))
        }
        Blank()
        Row({space:24}){
          Button($r('app.string.Button_Cancel'),{buttonStyle:ButtonStyleMode.TEXTUAL})
            .onClick(()=>{
              this.pathStack?.pop();
            })
          Button($r('app.string.Button_apply'),{buttonStyle:ButtonStyleMode.TEXTUAL})
            .onClick(()=>{
              config.upDateDisplay(this.currLangText,this.currFontSize,this.currTheme,this.showNumberOfReplies,this.showNumberOfTokenExpend);
              // 设置语言偏好
              try {
                if(this.langIsChang){
                  if(this.currLangText === '简体中文'){
                    i18n.System.setAppPreferredLanguage("zh"); // 设置应用偏好语言
                  }else{
                    i18n.System.setAppPreferredLanguage("en");
                  }
                }
                if(this.themeIsChang){
                  getContext(this).getApplicationContext().setColorMode(this.currTheme)
                }
              } catch(error) {
                let err: BusinessError = error as BusinessError;
                console.error(`call System.setAppPreferredLanguage zh failed, error code: ${err.code}, message: ${err.message}.`);
              }
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
    .title("显示设置")
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavDestinationMode.STANDARD)
    .onReady((context: NavDestinationContext)=>{
      this.pathStack = context.pathStack;
    })
  }
}