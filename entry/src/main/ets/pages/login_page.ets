import { router } from '@kit.ArkUI'
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

@Builder
export function LoginBuilder() {
  LoginPage();
}
@Preview
@Component
struct LoginPage {
  @State userId:string = ""
  @State verifiableCode:string = ""
  @State getCodeButtonText:string = "获取验证码"
  @State isDisabled:boolean = false
  pathStack: NavPathStack | null = null;
  build() {
    NavDestination(){
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
          Text('AITalk账号登陆')
            .fontSize(30)
          TextInput({
            placeholder:'请输入账号'
          })
            .onChange(value => {
              this.userId = value
            })
          Row(){
            TextInput({
              placeholder:'请输入验证码'
            })
              .width("60%")
              .type(InputType.Normal)
              .onChange(value => {
                this.verifiableCode = value
              })
            Button(this.getCodeButtonText)
              .width("40%")
              .buttonStyle(ButtonStyleMode.TEXTUAL)
              .onClick(()=>{
                this.getCodeButtonText = ""
              })
          }
          Button('登录')
            .width('100%')
            .onClick(() => {

            })
          Row() {
            Checkbox()
              .height(15)
              .shape(CheckBoxShape.ROUNDED_SQUARE)
            Text() {
              Span('新用户将自动注册到AITalk，并同意')
              Span('《AITalk使用须知》')
                .fontColor('#3274f6')
              Span('以及')
              Span('《AITalk隐私策略》')
                .fontColor('#3274f6')
            }
            .textAlign(TextAlign.Center)
            .lineHeight(15)
            .fontSize(12)
            .fontColor('#666')
          }
          .width('100%')
          .padding(5)
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
  handleOnClick(){
    if(!this.isDisabled){
      this.getCodeButtonText = "冷却中...";
      this.isDisabled = true;
    }
    let rand = cryptoFramework.createRandom();
    let randData = rand.generateRandomSync(6);

    setTimeout(()=>{
      this.getCodeButtonText = "获取验证码";
      this.isDisabled = false;
    },60000);
  }
}