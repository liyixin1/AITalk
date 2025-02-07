import * as Interfaces from '.././interface';
import { config } from '../config'
import { aiModel } from '../ai_model'
import { lvMarkdownIn, lvText, lvCode } from "@luvi/lv-markdown-in"
import { inputMethod } from '@kit.IMEKit';
import { dbUtil } from '../../../common/utils/db_util';
import { fileIo, picker } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import image from '@ohos.multimedia.image';
import { buffer } from '@kit.ArkTS';
import { Markdown } from '@lidary/markdown';


lvText.setTextSize(config.display.fontsize)
@Builder
export function ListItemBuilder() {
  ListItemPage()
}
@Preview
@Component
struct ListItemPage {
  pathStack: NavPathStack | null = null
  @State itemName:string = ""
  @State currId:number = 0
  @State buttonDisabled:boolean = true
  @State chatRecord:Array<Interfaces.Messages> = []
  @State TokenUsage:Array<string> = []
  @State ImageUrl:Array<string> = []
  @State chatImage:Array<image.PixelMap> = []
  @State userInput:string = ""
  aboutToAppear() {
    if(config.currSupplier === 'OpenAI'){
      this.chatRecord.push({
        role:'developer',
        content:config.ai.chatPrompt,
      })
    }else if(config.currSupplier === 'Groq'){
      this.chatRecord.push({
        role:'system',
        content:config.ai.chatPrompt,
      })
    }
    this.TokenUsage.push('0');
  }

  async fetchItemNameIfNeeded() {
    if (this.chatRecord.length === 3) {
        try {
          const itemName = await aiModel.getItemName(this.chatRecord);
          if (itemName.token != 0) {
            this.itemName = itemName.message as string
          }else{
            this.itemName = "新对话"
          }
        } catch (error) {
          console.error("获取对话名称时发生错误:", error);
          this.itemName = "新对话"; // 设置默认名称以避免崩溃
        }
    }
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }){
        Column(){
          List({ space: 10 }){
            ForEach(this.chatRecord,(chat:Interfaces.Messages,index)=>{
              ListItem(){
                if(chat.role === 'assistant'){
                  Row({space:8}){
                    Image($r('app.media.robot'))
                      .width(32).height(32)
                    Column(){
                      if ((chat.content as string) !== undefined){
                        lvMarkdownIn({
                          text:chat.content as string,
                          loadMode:'text'
                        })
                          .width('80%')
                          .backgroundColor($r('sys.color.background_primary'))
                          .alignSelf(ItemAlign.Start)
                        Row(){
                          if (config.display.showNumberOfReplies &&  (chat.content as string) !== undefined) {
                            Text("Total:" + (chat.content as string).length.toString())
                              .fontColor($r('sys.color.font_secondary'))
                          }
                          if (config.display.showNumberOfTokenExpend && this.TokenUsage[index] !== undefined) {
                            Text("  TokenUsage:" + this.TokenUsage[index])
                              .fontColor($r('sys.color.font_secondary'))
                          }
                        }.width('100%')
                      }
                    }.width('100%')
                  }.width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top)
                }else if(chat.role === 'user'){
                  Row({space:8}){
                    Image($r('app.media.user'))
                      .width(32).height(32)
                    if((chat.content as Array<Interfaces.ContentItem>)[0].text !== undefined){
                      lvMarkdownIn({
                        text:(chat.content as Array<Interfaces.ContentItem>)[0].text as string,
                        loadMode:'text'
                      })
                        .width('80%')
                        .backgroundColor($r('sys.color.background_primary'))
                    }
                  }.width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top)
                }else{}
              }
            })
          }.height('100%')
          .width('100%')
        }
        .width("100%")
        .height('95%')
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.End}){
          // Button({ type:ButtonType.Circle }){
          //   Image($r('app.media.mic_circle'))
          // }.width(32)
          // .height(32)
          // .flexGrow(0)
          // .buttonStyle(ButtonStyleMode.TEXTUAL)
          // .margin(5)
          TextArea({text:$$this.userInput})
            .type(TextAreaType.NORMAL)
            .width('50%')
            .flexGrow(1)
            .margin(5)
            // .onChange((value)=>{
            //   this.userInput = value;
            // })
          Button({ type:ButtonType.Circle }){
            Image($r('app.media.picture'))
              .onClick(()=>{
                let photoPicker  = new photoAccessHelper.PhotoViewPicker();
                let options:photoAccessHelper.PhotoSelectOptions = {
                  MIMEType:photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
                  maxSelectNumber:3
                }
                photoPicker.select(options).then( async (value:photoAccessHelper.PhotoSelectResult)=>{
                  for (let index = 0; index < value.photoUris.length; index++) {
                    let file = fileIo.openSync(value.photoUris[index]);
                    let photoSize = fileIo.statSync(file.fd).size;
                    let buffer1 = new ArrayBuffer(photoSize);
                    fileIo.readSync(file.fd, buffer1);
                    let base64Str: string = buffer.from(buffer1).toString('base64')
                    this.ImageUrl.push(base64Str)
                    let source:image.ImageSource = image.createImageSource(file.fd)
                    let decodingoptions:image.DecodingOptions = {
                      editable:true,
                      desiredPixelFormat:3
                    }
                    source.createPixelMap(decodingoptions).then((value:image.PixelMap)=>{
                      this.chatImage.push(value)
                    })
                  }
                })
              })
          }.width(32).height(32).flexGrow(0).margin(5).buttonStyle(ButtonStyleMode.TEXTUAL)
          Button($r('app.string.ListItem_send'),{type:ButtonType.Normal, stateEffect: true })
            .enabled(this.buttonDisabled)
            .width(64).height(32).buttonStyle(ButtonStyleMode.EMPHASIZED).borderRadius(10).flexGrow(0).margin(5)
            .onClick(async ()=>{
              if(this.userInput != ""){
                this.buttonDisabled = false;
                let date = new Date().toLocaleDateString()
                try {
                  inputMethod.getController().stopInputSession();

                  this.chatRecord.push(aiModel.toRecordItem('user',this.userInput,this.ImageUrl))
                  this.TokenUsage.push('0');
                  this.ImageUrl = [];
                  console.log(JSON.stringify(this.chatRecord[this.chatRecord.length-1]))
                  this.userInput = "";
                  this.chatImage = [];
                  this.ImageUrl = [];
                  const reply = await aiModel.getReply(this.chatRecord);
                  if (reply.token === 0) {
                    this.chatRecord.pop();
                    this.TokenUsage.pop();
                    AlertDialog.show({
                      message: reply.message as string
                    })
                  }else{
                    if(config.currSupplier !== 'DeepSeek'){
                      dbUtil.insertData("record"+this.currId,{SENDER:this.chatRecord[this.chatRecord.length-1].role,MESSAGE:JSON.stringify(this.chatRecord[this.chatRecord.length-1].content),TOKENUSAGE:'0',TIMESTAMP:date})
                      this.chatRecord.push(aiModel.toRecordItem('assistant',(reply.message as Interfaces.DeepSeekMessage).content,this.ImageUrl));
                      this.TokenUsage.push(reply.token.toString())
                      console.log('token: ' + this.TokenUsage[this.TokenUsage.length - 1])
                      console.log(JSON.stringify(this.chatRecord[this.chatRecord.length-1]))
                      dbUtil.insertData("record"+this.currId,{SENDER:this.chatRecord[this.chatRecord.length-1].role,MESSAGE:this.chatRecord[this.chatRecord.length-1].content as string,TOKENUSAGE:reply.token.toString(),TIMESTAMP:date})
                      if(config.ai.autoTitle){
                        this.fetchItemNameIfNeeded();
                      }
                    }else{
                      dbUtil.insertData("record"+this.currId,{SENDER:this.chatRecord[this.chatRecord.length-1].role,MESSAGE:JSON.stringify(this.chatRecord[this.chatRecord.length-1].content),TOKENUSAGE:'0',TIMESTAMP:date})
                    }

                  }
                } catch (error) {
                  console.error('发送过程错误:', error);
                } finally {
                  this.buttonDisabled = true; // 重新启用按钮
                }
              }
              
            })
        }.width('100%').constraintSize({maxHeight:"40%"})
        Row({space: 4}){
          ForEach(this.chatImage,(item:image.PixelMap,index)=>{
            Image(item)
              .width(64)
              .height(64)
              .onClick(()=>{
                this.chatImage.splice(index,1);
                this.ImageUrl.splice(index,1);
              })

          },(item:string)=>item)
        }.width('100%')
        .margin(4)
        .constraintSize({maxHeight:"15%"})
      }.width('100%').height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title(this.itemName)
    .mode(NavDestinationMode.STANDARD)
    .onReady(async (context: NavDestinationContext)=>{
      this.pathStack = context.pathStack;
      this.itemName = (this.pathStack.getParamByName('ListItemPage')[0] as Interfaces.MessageHistory).name;
      this.currId = (this.pathStack.getParamByName('ListItemPage')[0] as Interfaces.MessageHistory).id;
      const tableName = `record${this.currId}`;
      const columns = ['SENDER', 'MESSAGE','TOKENUSAGE'];
      const chatData = await dbUtil.queryRecordDataById(columns, tableName);
      if (chatData && chatData.length > 0) {
        for(const value of chatData){
          this.chatRecord.push({role:value.role,content:value.content});
          this.TokenUsage.push(value.token)
          console.log(value.token)
        }
      }
      })
    .onBackPressed(() => {
      let param:Interfaces.ListParam;
      if(this.chatRecord.length < 2){
        param = {name:""};
      }else{
        param = {name:this.itemName};
      }
      this.pathStack?.pop(param);
      return true;
    })
  }
}