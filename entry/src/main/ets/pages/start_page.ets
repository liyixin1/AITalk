import { router } from '@kit.ArkUI';
import { config } from '../config';
@Entry
@Component
struct StartPage {
  @State opacityValue: number = 0.3;

  onPageShow(): void {
    this.opacityValue = 1
  }
  build() {
    Column(){
      Blank()
      Column(){
        Text('探索')
          .fontSize(36)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Text('智慧对话')
          .fontSize(36)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .alignItems(HorizontalAlign.Start)
      .opacity(this.opacityValue)
      .animation({
        duration: 1500,
        onFinish:()=>{
          if (config.isConfigReady) {
            router.replaceUrl({
              url: 'pages/Index'
            })
          }
        }
      })
      Blank()
      Blank()
      Image($r('app.media.app_icon'))
        .width(64)
        .backgroundColor('#00000000')
        .margin({bottom:'10%'})
    }
    .width('100%')
    .height('100%')
    .linearGradient(config.display.theme === 0?{
      colors:[
        ['#1E3A5F',0],['#2D2D2D',1]
      ]
    }:{
      colors:[
        ['#87CEEB',0],['#F8F8F8',1]
      ]
    }
    )
  }
}