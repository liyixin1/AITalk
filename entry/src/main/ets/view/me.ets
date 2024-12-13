import { router } from "@kit.ArkUI";

@Component
export struct Me {
  @State userID:number | null = null;
  build() {
    Column(){
      Row({space:5}){
        Image($r('app.media.person_crop_circle_fill'))
          .width(48)
          .borderRadius(20)
        Column(){
          Text(){
            Span('登录/注册\n')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
            Span('您还未登录，点击前往登录账号')
              .fontSize(15)
          }
        }
      }
      .width('100%').height(90)
      .padding(10)
      .onClick(()=>{
        router.pushUrl({
          url:"pages/login_page"
        })
      })
    }
    .width('100%').height('100%')

  }
}