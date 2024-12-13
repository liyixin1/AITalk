import { config } from '../config'
import * as Interfaces from '../interface'

@Component
export struct Messages{
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State messageList:Array<Interfaces.MessageHistory> = config.messageList;
  private listScroller: Scroller = new Scroller();
  @Builder itemEnd(index: number) {
    // 构建尾端滑出组件
    Button({ type: ButtonType.Circle }) {
      Image($r('app.media.ic_public_trash_fill'))
        .width(20)
        .height(20)
    }
    .onClick(() => {
      this.messageList.splice(index, 1);
      config.deleteListItem(index)
    })
  }
  build() {
    List({ space: 10,scroller:this.listScroller}){
      ForEach(this.messageList,(item:Interfaces.MessageHistory,index:number)=>{
        ListItem(){
          Text(){
            Span(item.name + '\n')
              .fontSize(18)
            Span(item.datetime)
              .fontSize(14)
              .fontColor(Color.Gray)
          }
        }
        .width('100%')
        .height(64)
        .align(Alignment.Start)
        .borderRadius(10)
        .backgroundColor(Color.White)
        .padding(12)
        .swipeAction({
          end:{
            builder:()=>{this.itemEnd(index)}
          }
        })
        .onClick(()=>{
            this.pageInfos.pushPathByName("ListItemPage",this.messageList[index])
        })
      },(item:string)=>item)
    }
    .padding(10)
    .alignListItem(ListItemAlign.Center)
    .backgroundColor('#ffffffff')
    .height('100%')
    .scrollBar(BarState.Auto)
  }
}