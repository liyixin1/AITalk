// import * as Interfaces from '.././interface';
// import { dbUtil } from '../../../common/Index'
// import { config } from '../config';
// import { relationalStore } from '@kit.ArkData';
// import { LengthMetrics } from '@kit.ArkUI';
//
// @Entry
// @Component
// struct Index {
//   @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
//   @State isRefresh:boolean = false;
//   @State currentIndex: number = 0;
//   @State messageList:Array<Interfaces.MessageHistory> = [];
//   @State userID:number | null = null;
//   @State hideTitle:boolean = false;
//   private listScroller: ListScroller = new ListScroller();
//   TooBar:Array<ToolbarItem> = [
//     {value: $r('app.string.Index_Tabs_Conversations'),
//       icon: $r('app.media.message'),
//       action: ()=> {
//         this.currentIndex = 0;
//         this.hideTitle = false;
//       },
//       activeIcon:$r('app.media.message_active'),
//       status:ToolbarItemStatus.NORMAL
//     },
//     // {'value': $r('app.string.Index_Tabs_Explore'),
//     //   'icon': $r('app.media.ic_public_add_light'),
//     //   'action': ()=> {
//     //     this.currentIndex = 1;
//     //     this.hideTitle = true;
//     //   }},
//     {value: $r('app.string.Index_Tabs_My'),
//       icon: $r('app.media.person'),
//       action: ()=> {
//         this.currentIndex = 2;
//         this.hideTitle = true;
//       },
//       activeIcon:$r('app.media.person_active'),
//       status:ToolbarItemStatus.NORMAL
//     }
//   ];
//
//   TooTmp:Array<NavigationMenuItem> = [
//     {'value': "",
//       'icon': "common/img/plus.svg",
//       'action': async ()=> {
//         let date = new Date().toLocaleDateString()
//         let id = await dbUtil.insertDataR('myList',{NAME:"新对话",CREEATE_TIME:date});
//         dbUtil.createRecordTable(`record${id.toString()}`);
//         if(id > 0){
//           this.messageList.unshift({
//             id:id,
//             name:"新对话",
//             datetime:date
//           })
//           this.currentIndex = 3;
//           this.pageInfos.pushPathByName("ListItemPage",this.messageList[0],(popInfo) => {
//             if((popInfo.result as Interfaces.ListParam).name !== ""){
//               this.messageList[0].name = (popInfo.result as Interfaces.ListParam).name;
//               dbUtil.upDataById("myList",id,{NAME:(popInfo.result as Interfaces.ListParam).name});
//             }else{
//               this.messageList.shift();
//               dbUtil.deleteById("myList",id);
//               dbUtil.deleteRecordTable(`record${id.toString()}`);
//             }
//             this.currentIndex = 0;
//             console.log(JSON.stringify(popInfo.result));
//           })
//         }
//       }}
//   ];
//
//
//   setListItem:Array<Interfaces.setListItem> = [
//     {
//       text:$r('app.string.My_Model'),
//       prompt:$r('app.string.My_Model_prompt'),
//       icon:$r('app.media.slider_model'),
//       name:"ModelPage"
//     },
//     {
//       text:$r('app.string.My_Display'),
//       prompt:$r('app.string.My_Display_prompt'),
//       icon:$r('app.media.paintpalette_display'),
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
//       prompt:$r('app.string.My_About_prompt'),
//       icon:$r('app.media.about'),
//       name:"AboutPage"
//     },
//   ]
//
//   @Builder itemEnd(index:number) {
//     // 构建尾端滑出组件
//     Row(){
//       Button({ type: ButtonType.Normal }) {
//         Image($r('app.media.ic_public_trash_fill'))
//           .width(28)
//           .height(28)
//       }
//       .width(100)
//       .height(64)
//       .backgroundColor($r('sys.color.warning'))
//       .onClick(() => {
//         const id = this.messageList[index].id;
//         this.listScroller.closeAllSwipeActions()
//         dbUtil.deleteSyncById("myList",id);
//         console.log(`Deleted item at index: ${index}`);
//         this.messageList.splice(index,1);
//       })
//     }
//   }
//
//   @Builder messages() {
//     // 消息页面
//     List({ space: 10,scroller:this.listScroller}){
//       ForEach(this.messageList,(item:Interfaces.MessageHistory,index:number)=>{
//         ListItem(){
//           Text(){
//             Span(item.name + '\n')
//               .fontSize(18)
//               .fontColor($r('sys.color.font_primary'))
//             Span(item.datetime)
//               .fontSize(14)
//               .fontColor($r('sys.color.font_secondary'))
//           }
//         }
//         .width('100%')
//         .height(64)
//         .align(Alignment.Start)
//         .borderRadius(10)
//         .swipeAction({
//           end:{
//             builder:() => {
//               this.itemEnd(index)
//             }
//           }
//         })
//         .onClick(()=>{
//           console.log(`index:${JSON.stringify(this.messageList[index])}`);
//           this.pageInfos.pushPathByName("ListItemPage",this.messageList[index])
//         });
//       }, (item: Interfaces.MessageHistory) => item.id.toString())
//     }
//     .padding(10)
//     .backgroundColor($r('sys.color.comp_background_list_card'))
//     .alignListItem(ListItemAlign.Center)
//     .height('100%')
//     .scrollBar(BarState.Auto)
//   }
//   @Builder me(){
//     Column(){
//       Row(){
//         Text('我的')
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
//               // .fillColor(config.display.theme === 0?$r('sys.color.'))
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
//       .sticky(StickyStyle.Header)
//     }
//     .width('100%').height('100%')
//   }
//   @Builder explore(){
//     Column(){
//       Button('点点')
//         .onClick(()=>{
//           const value:relationalStore.ValuesBucket = {
//             PHONE_NUMBER:123456789,
//             PASSWORD:88888888,
//             EMAIL:'123@qq.com',
//             NAME:'nihao'
//           }
//           dbUtil.insertData('users',value);
//         })
//       Button('删除')
//         .onClick(()=>{
//           dbUtil.deleteById('users',1)
//         })
//     }.width('100%').height('100%')
//   }
//
//   aboutToAppear(): void {
//     this.messageList = config.messageList;
//   }
//
//   build() {
//     Navigation(this.pageInfos){
//       if (this.currentIndex == 0){
//         this.messages();
//       }else if(this.currentIndex == 1){
//         this.explore();
//       }else if(this.currentIndex == 2){
//         this.me();
//       }else{
//
//       }
//     }
//     .backgroundColor($r('sys.color.background_primary'))
//     .mode(NavigationMode.Auto)
//     .titleMode(NavigationTitleMode.Mini)
//     .hideBackButton(true)
//     .title($r('app.string.Index_Title'))
//     .menus(this.TooTmp)
//     .toolbarConfiguration(this.TooBar)
//     .hideTitleBar(this.hideTitle)
//   }
// }
