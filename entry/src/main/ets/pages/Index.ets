import * as Interfaces from '.././interface';
import { dbUtil } from '../common/Index'
import { config } from '../config';
import { CustomContentDialog,promptAction } from '@kit.ArkUI';
import { MessageHistory } from '../data_class'
import { common } from '@kit.AbilityKit';
import { MessageDataSource } from '../data_class'
@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @State currentIndex: number = 0;
  // @State messageList: Array<MessageHistory> = [];
  @State messageDataSource: MessageDataSource = new MessageDataSource();
  @State userID:number | null = null;
  @State hideTitle:boolean = false;
  // 记录第一次点击返回键的时间戳
  private firstBackTime: number = 0;
  // 两次点击的时间间隔阈值（单位：毫秒）
  private readonly EXIT_DURATION: number = 2000;
  // 获取Ability上下文（用于退出应用）
  private abilityContext = getContext(this) as common.UIAbilityContext;
  changeItem: number = 0;
  private listScroller: ListScroller = new ListScroller();
  currItemName:string = ''
  currItemId:number = 0
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '编辑名称',
      contentBuilder: () => {
        this.ChangName()
      },
      buttons: [
        {
          value: $r('app.string.Button_Cancel'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          action:()=>{
            this.dialogController.close()
          }
        },
        {
          value: $r('app.string.Button_apply'),
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.ERROR,
          action: () => {
            this.messageDataSource.upData(this.changeItem,this.currItemName);
            dbUtil.upDataById("myList",this.currItemId,{NAME:this.currItemName});
            console.info('Callback when the button is clicked')
            this.dialogController.close()
          }
        }
      ],
    })
  })
  TooBar:Array<ToolbarItem> = [
    {
      value: $r('app.string.Index_Tabs_Conversations'),
      icon: $r('app.media.message'),
      activeIcon: $r('app.media.message_active'),
      action: ()=> {
        this.currentIndex = 0;
        this.hideTitle = false;
      },
      // status:this.currentIndex === 0?ToolbarItemStatus.ACTIVE:ToolbarItemStatus.NORMAL
    },
    {
      value: $r('app.string.New_Chat'),
      icon:$r('app.media.plus_square'),
      action: async ()=> {
        let date = new Date().toLocaleDateString()
        let id = await dbUtil.insertDataR('myList',{NAME:"新对话",CREEATE_TIME:date});
        dbUtil.createRecordTable(`record${id.toString()}`);
        if(id > 0){
          const temp = new MessageHistory(id,config.display.language === "简体中文"?"新对话":"New Chat",date)
          this.messageDataSource.pushData(temp)
          this.currentIndex = 3;
          this.pageInfos.pushPathByName("ListItemPage",temp,(popInfo) => {
            if((popInfo.result as Interfaces.ListParam).name !== ""){
              this.messageDataSource.upData(0,(popInfo.result as Interfaces.ListParam).name);
              dbUtil.upDataById("myList",id,{NAME:(popInfo.result as Interfaces.ListParam).name});
            }else{
              this.messageDataSource.deleteData(0);
              dbUtil.deleteById("myList",id);
              dbUtil.deleteRecordTable(`record${id.toString()}`);
            }
            this.currentIndex = 0;
            console.log(JSON.stringify(popInfo.result));
          })
        }
      },
    },
    {
      value: $r('app.string.Index_Tabs_My'),
      icon: $r('app.media.person'),
      activeIcon: $r('app.media.person_active'),
      action: ()=> {
        this.currentIndex = 1;
        this.hideTitle = true;
      },
      // status:this.currentIndex === 2?ToolbarItemStatus.ACTIVE:ToolbarItemStatus.NORMAL
    }
  ];

  TooTmp:Array<NavigationMenuItem> = [
    {'value': "",
      'icon': "common/img/magnifyingglass.svg",
      'action': async ()=> {

      }}
  ];


  setListItem:Array<Interfaces.setListItem> = [
    {
      text:$r('app.string.My_Model'),
      prompt:$r('app.string.My_Model_prompt'),
      icon:$r('app.media.slider_model'),
      name:"ModelPage"
    },
    {
      text:$r('app.string.My_NewModel'),
      prompt:$r('app.string.My_NewModel_prompt'),
      icon:$r('app.media.new_model'),
      name:"NewModelPage"
    },
    {
      text:$r('app.string.My_Display'),
      prompt:$r('app.string.My_Display_prompt'),
      icon:$r('app.media.display'),
      name:"DisPlayPage"
    },
    {
      text:$r('app.string.My_Talk'),
      prompt:$r('app.string.My_Talk_prompt'),
      icon:$r('app.media.doc_plaintext_and_pencil_talk'),
      name:"TalkPage"
    },
    {
      text:$r('app.string.My_Device'),
      prompt:$r('app.string.My_Device_prompt'),
      icon:$r('app.media.doc_plaintext_and_pencil_talk'),
      name:"DevicePage"
    },
    {
      text:$r('app.string.My_About'),
      // prompt:$r('app.string.My_About_prompt'),
      icon:$r('app.media.about'),
      name:"AboutPage"
    },
  ]

  onEditClick(index:number):void{
    const temp = this.messageDataSource.getData(index);
    this.currItemName = temp.name
    this.currItemId = temp.id
    this.changeItem = index
    this.dialogController.open()
    this.listScroller.closeAllSwipeActions()
  }
  onDeleteClick(index:number):void{
    const temp = this.messageDataSource.getData(index);
    const id = temp.id;
    this.listScroller.closeAllSwipeActions()
    dbUtil.deleteSyncById("myList",id);
    console.log(`Deleted item at index: ${index}`);
    this.messageDataSource.deleteData(index);
  }
  onPush(index:number):void{
    const temp = this.messageDataSource.getData(index);
    console.log(`index:${JSON.stringify(temp)}`);
    this.pageInfos.pushPathByName("ListItemPage", temp)
  }

  @Builder messages() {
    // 消息页面
    List({ space: 10,scroller:this.listScroller}){
        LazyForEach(this.messageDataSource,(item:MessageHistory,index:number) => {
            LListItem({
              item:item,
              onPush: () => this.onPush(index),
              onEditClick: () => this.onEditClick(index),
              onDeleteClick:() => this.onDeleteClick(index)
            })
        }, (item: MessageHistory) => item.id.toString())
    }.cachedCount(10)
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .alignListItem(ListItemAlign.Center)
    .height('100%')
    .scrollBar(BarState.Auto)
  }
  @Builder me(){
    Column(){
      Row(){
        Text($r('app.string.Index_Tabs_My'))
          .fontSize(28).fontWeight(FontWeight.Bold)
      }.width('100%').height('8%')
      .padding(12).justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      List(){
        ForEach(this.setListItem,(item:Interfaces.setListItem,index:number)=>{
          ListItem(){
            Row(){
              Image(item.icon)
                .width(28)
                .height(28)
              .fillColor($r('sys.color.icon_primary'))
              Text(){
                Span(item.text)
                  .fontSize(20)
                  .fontColor($r('sys.color.font_primary'))
                Span('\n')
                Span(item.prompt)
                  .fontSize(16)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .padding(5)
              Blank()
              // Image($r('app.media.chevron_right'))
              //   .width(24)
              //   .height(24)
              //   .margin(6)
              //   .alignSelf(ItemAlign.Auto)
            }
            .width('100%')
            .height('100%')
            .align(Alignment.Start)
            .onClick(()=>{
              this.pageInfos.pushPathByName(item.name,"")
            })
          }
          .width('100%')
          .height(60)
          .margin(5)
        })
      }
      .width('100%')
      .height('100%')
      .sticky(StickyStyle.Header)
    }
    .width('100%').height('100%')
  }
  // 自定义弹出框的内容区
  @Builder
  ChangName(): void {
    Column() {
      TextInput({text: this.currItemName})
        .caretColor('#90EE90')
        .onChange((value:string)=>{
          this.currItemName = value
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }


  aboutToAppear(): void {
    for (let i = 0; i < config.messageList.length; i++) {
      this.messageDataSource.pushData(config.messageList[i])
    }
  }
  // 拦截返回键事件
  onBackPress(): boolean {
    const currentTime = new Date().getTime();
    if (currentTime - this.firstBackTime < this.EXIT_DURATION) {
      // 第二次点击返回键：退出应用
      this.abilityContext.terminateSelf().then(() => {
        console.log('应用已退出');
      });
      return true; // 拦截返回键默认行为
    } else {
      // 第一次点击返回键：记录时间并提示
      this.firstBackTime = currentTime;
      promptAction.showToast({
        message: '再按一次返回键退出AITalk',
        duration: this.EXIT_DURATION
      })
      return true; // 拦截返回键默认行为
    }
  }

  build() {
    Navigation(this.pageInfos){
      if (this.currentIndex == 0){
        this.messages();
      }else if(this.currentIndex == 1){
        this.me();
      }else{

      }
    }
    .backgroundColor($r('sys.color.background_primary'))
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .title($r('app.string.Index_Title'))
    // .menus(this.TooTmp)
    .toolbarConfiguration(this.TooBar)
    .hideTitleBar(this.hideTitle)
  }
}

@Component
struct LListItem {
  @ObjectLink item: MessageHistory; // 绑定到观测对象
  onPush: () => void = () => {};
  onEditClick: () => void = () => {};
  onDeleteClick: () => void = () => {};
  build() {
    ListItem(){
      Text(){
        Span(this.item.name + '\n')
          .fontSize(18)
          .fontColor($r('sys.color.font_primary'))
        Span(this.item.datetime)
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      }
    }
    .width('100%')
    .height(64)
    .align(Alignment.Start)
    .borderRadius(10)
    .swipeAction({
      end:{
        builder:() => {
          this.itemEnd()
        },
        onAction: () => {}
      }
    })
    .onClick(()=>{
      this.onPush()

    });
  }
  @Builder itemEnd() {
    // 构建尾端滑出组件
    Row(){
      Button({ type: ButtonType.Normal }){
        Image($r('app.media.pencil'))
          .width(28)
          .height(28)
      }
      .width(50)
      .height(64)
      .backgroundColor($r('sys.color.brand'))
      .onClick(() => {
        this.onEditClick()
      })
      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.ic_public_trash_fill'))
          .width(28)
          .height(28)
      }
      .width(100)
      .height(64)
      .backgroundColor($r('sys.color.warning'))
      .onClick(() => {
        this.onDeleteClick()
      })
    }
  }
}