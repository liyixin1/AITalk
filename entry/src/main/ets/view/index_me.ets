// import * as Interfaces from '.././interface';
// @Component
// struct Me{
//   @
//   @Inject('pageInfos') pageInfos: NavPathStack; // 注入导航栈实例
//   setListItem:Array<Interfaces.setListItem> = [
//     {
//       text:$r('app.string.My_Model'),
//       prompt:$r('app.string.My_Model_prompt'),
//       icon:$r('app.media.slider_model'),
//       name:"ModelPage"
//     },
//     {
//       text:$r('app.string.My_NewModel'),
//       prompt:$r('app.string.My_NewModel_prompt'),
//       icon:$r('app.media.new_model'),
//       name:"NewModelPage"
//     },
//     {
//       text:$r('app.string.My_Display'),
//       prompt:$r('app.string.My_Display_prompt'),
//       icon:$r('app.media.display'),
//       name:"DisPlayPage"
//     },
//     {
//       text:$r('app.string.My_Talk'),
//       prompt:$r('app.string.My_Talk_prompt'),
//       icon:$r('app.media.doc_plaintext_and_pencil_talk'),
//       name:"TalkPage"
//     },
//     {
//       text:$r('app.string.My_About'),
//       // prompt:$r('app.string.My_About_prompt'),
//       icon:$r('app.media.about'),
//       name:"AboutPage"
//     },
//   ]
//   build() {
//     Column(){
//       Row(){
//         Text($r('app.string.Index_Tabs_My'))
//           .fontSize(28).fontWeight(FontWeight.Bold)
//       }.width('100%').height('8%')
//       .padding(12).justifyContent(FlexAlign.Start)
//       .alignItems(VerticalAlign.Center)
//       List(){
//         ForEach(this.setListItem,(item:Interfaces.setListItem,index:number)=>{
//           ListItem(){
//             Row(){
//               Image(item.icon)
//                 .width(28)
//                 .height(28)
//                 .fillColor($r('sys.color.icon_primary'))
//               Text(){
//                 Span(item.text)
//                   .fontSize(20)
//                   .fontColor($r('sys.color.font_primary'))
//                 Span('\n')
//                 Span(item.prompt)
//                   .fontSize(16)
//                   .fontColor($r('sys.color.font_secondary'))
//               }
//               .padding(5)
//               Blank()
//               // Image($r('app.media.chevron_right'))
//               //   .width(24)
//               //   .height(24)
//               //   .margin(6)
//               //   .alignSelf(ItemAlign.Auto)
//             }
//             .width('100%')
//             .height('100%')
//             .align(Alignment.Start)
//             .onClick(()=>{
//               this.pageInfos.pushPathByName(item.name,"")
//             })
//           }
//           .width('100%')
//           .height(60)
//           .margin(5)
//         })
//       }
//       .width('100%')
//       .height('100%')
//       .sticky(StickyStyle.Header)
//     }
//     .width('100%').height('100%')
//   }
// }