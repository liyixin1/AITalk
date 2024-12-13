import { router } from '@kit.ArkUI'

@Entry
@Component
struct LoginPage {
  @State user_id:string = ""
  @State user_pwd:string = ""
  build() {
    Column() {
      Stack(){
        Button({type:ButtonType.Circle}){
          Image($r('app.media.chevron_left'))
            .height(48)
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(()=>{
          router.back();
        })
      }
      .width('100%')
      .align(Alignment.TopStart) // 设置对齐方式为左上角
      Blank()
      Image($r('app.media.huaweilogo1'))
        .width(100)
      Blank()
      Column({ space:15 }){
        Text('GPTalks账号登陆')
          .fontSize(30)
        TextInput({
          placeholder:'请输入账号'
        })
          .onChange(value => {
            this.user_id = value
          })
        TextInput({
          placeholder:'请输入密码'
        })
          .type(InputType.Password)
          .onChange(value => {
            this.user_pwd = value
          })
        Button('登录')
          .width('100%')
          .onClick(() => {

          })
        Row() {
          Checkbox()
            .height(15)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
          Text() {
            Span('新用户将自动注册到GPTalks，并同意')
            Span('《GPTalks使用须知》')
              .fontColor('#3274f6')
            Span('以及')
            Span('《GPTalks隐私策略》')
              .fontColor('#3274f6')
          }
          .textAlign(TextAlign.Center)
          .lineHeight(15)
          .fontSize(12)
          .fontColor('#666')
        }
        .width('100%')
        .padding(5)
        Row({ space:15 }) {
          Button('短信验证码登录')
            .buttonStyle(ButtonStyleMode.TEXTUAL)
          Button('忘记密码')
            .buttonStyle(ButtonStyleMode.TEXTUAL)
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#F5F5F5')
      .borderRadius(20)
      .opacity(0.9)
      Blank()
      Blank()
      Blank()
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      colors:[
        ['#87CEEB',0],['#F8F8F8',1]
      ]
    })
    .align(Alignment.Center)
  }
}