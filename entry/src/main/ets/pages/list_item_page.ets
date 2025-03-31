import * as Interfaces from '.././interface';
import * as responseInterface from '.././responseInterface';
import { config } from '../config'
import { aiModel } from '../ai_model'
import { lvMarkdownIn, lvText } from "@luvi/lv-markdown-in"
import { inputMethod } from '@kit.IMEKit';
import { dbUtil } from '../common/utils/db_util';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import image from '@ohos.multimedia.image';
import { buffer } from '@kit.ArkTS';
import { myStreamRequest } from '../common/utils/http_util'
import { audio } from '../audio'
@Builder
export function ListItemBuilder() {
  ListItemPage()
}

interface GeneratedObjectLiteralInterface_1 {
  ICON_SIZE: number;
  IMAGE_PREVIEW_SIZE: number;
  INPUT_BUTTON_WIDTH: number;
  BORDER_RADIUS: number;
  TYPING_INTERVAL: number;
}

@Entry
@Component
struct ListItemPage {
  pathStack: NavPathStack | null = null
  @State itemName: string = ""
  @State currId: number = 0
  @State buttonDisabled: boolean = true
  @State chatRecord: Array<Interfaces.Messages> = []
  @State TokenUsage: Array<string> = []
  @State ImageUrl: Array<string> = []
  @State chatImage: Array<image.PixelMap> = []
  @State userInput: string = ""
  @State arrtext: string[] = [];
  @State timer: number = 0;
  @State index:number = 0
  @State isVoiceInput:boolean = false
  occurredError:boolean = false
  scroller: Scroller = new Scroller()
  // 流式调用
  private streamRequest: myStreamRequest = new myStreamRequest();
  @State isLoading: boolean = false;
  // 新增样式常量集中管理
  private readonly STYLES: GeneratedObjectLiteralInterface_1 = {
    ICON_SIZE: 32,
    IMAGE_PREVIEW_SIZE: 64,
    INPUT_BUTTON_WIDTH: 64,
    BORDER_RADIUS: 8,
    TYPING_INTERVAL: 10
  }

  aboutToAppear() {
    this.chatRecord.push({
      role: 'system',
      content: config.ai.chatPrompt,
    });
    if (config.currSupplier === 'OpenAI') {
      this.chatRecord[0].role = 'developer';
    }
    this.setupEventListeners();
    this.setaudioback()
    this.TokenUsage.push('0');
    lvText.setTextSize(config.display.fontsize)
  }
  aboutToDisappear(): void {
    this.streamRequest.destroy()
  }
  build() {
    NavDestination() {
      Scroll(this.scroller){
        Flex({direction:FlexDirection.Column,alignItems:ItemAlign.Center}){
          List({ space: 10 }) {
            ForEach(this.chatRecord, (chat: Interfaces.Messages, index) => {
              this.messageItem(chat, index)
            })
          }.flexGrow(1).width('100%')
          Row({space:4}){
            ForEach(this.chatImage, (item: image.PixelMap, index) => {
              Image(item)
                .height(64)
                .width(64)
                .borderRadius(8)
                .borderWidth(1)
                .borderColor($r('sys.color.font_fourth') )
                .objectFit(ImageFit.Contain)
                .onClick(() => {
                  this.chatImage.splice(index, 1);
                  this.ImageUrl.splice(index, 1);
                })
            }, (item: string) => item)
          }.width('100%')
          .margin(4)
          .justifyContent(FlexAlign.Start)
          .constraintSize({ minHeight:0, maxHeight: 64 })
          Divider()
            .width('100%')
            .alignSelf(ItemAlign.End)
          Row(){
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.picture'))
                .fillColor($r('sys.color.icon_primary'))
                .onClick(() => this.handleImageSelect())
            }
            .width(28)
            .height(28)
            .margin(5)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            Button({ type: ButtonType.Circle }) {
              Image(this.isVoiceInput?$r('app.media.keyboard'):$r('app.media.audio'))
                .fillColor($r('sys.color.icon_primary'))
                .onClick(() => {
                  this.isVoiceInput = !this.isVoiceInput
                })
            }
            .width(28)
            .height(28)
            .margin(5)
            .buttonStyle(ButtonStyleMode.TEXTUAL)

            Blank()
            Button($r('app.string.ListItem_send'), { type: ButtonType.Normal, stateEffect: true })
              .enabled(this.buttonDisabled)
              .width(64)
              .height(28)
              .buttonStyle(ButtonStyleMode.EMPHASIZED)
              .borderRadius(4)
              .margin(5)
              .alignSelf(ItemAlign.End)
              .onClick(async () => {
                inputMethod.getController().stopInputSession();
                await this.sendMessage();
              })
          }.width('100%').justifyContent(FlexAlign.Start)
          if (this.isVoiceInput){
            Button($r('app.string.Button_Audio'),{ type: ButtonType.Normal, stateEffect: true })
              .width('95%')
              .margin(5)
              .borderRadius(8)
              .onTouch(async (event?: TouchEvent) =>{
                if (event?.type === TouchType.Down) {
                  audio.startListeningForRecording()
                }
                if (event?.type === TouchType.Up) {
                  audio.asrEngine?.finish('1')
                  console.log('end')
                  await this.sendMessage();
                }
              })
          }else{
            TextArea({ text: $$this.userInput })
              .type(TextAreaType.NORMAL)
              .width('95%')
              .margin(5)
              .borderRadius(8)
              .constraintSize({ maxHeight: "40%" })
          }

        }.width('100%').height('100%')
        .backgroundColor($r('sys.color.background_primary'))
      }
    }
    .title(this.itemName)
    .mode(NavDestinationMode.STANDARD)
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.itemName = (this.pathStack.getParamByName('ListItemPage')[0] as Interfaces.MessageHistory).name;
      this.currId = (this.pathStack.getParamByName('ListItemPage')[0] as Interfaces.MessageHistory).id;
      const tableName = `record${this.currId}`;
      const columns = ['SENDER', 'MESSAGE', 'TOKENUSAGE'];
      const chatData = await dbUtil.queryRecordDataById(columns, tableName);
      if (chatData && chatData.length > 0) {
        for (const value of chatData) {
          this.chatRecord.push({ role: value.role, content: value.content });
          this.TokenUsage.push(value.token)
          console.log(value.token)
        }
      }
    })
    .onBackPressed(() => {
      let param: Interfaces.ListParam;
      if (this.chatRecord.length < 2) {
        param = { name: "" };
      } else {
        param = { name: this.itemName };
      }
      this.pathStack?.pop(param);
      return true;
    })
  }
  // 设置事件监听器
  private setupEventListeners() {
    console.log('[DEBUG] setupEventListeners 被调用'); // 🔍 检查调用次数
    // 监听数据接收事件
    this.streamRequest.on('dataReceive', (data:string) => {
      if (config.currSupplier === 'DeepSeek'){
        const jsonData:responseInterface.DeepSeekStream = JSON.parse(data)
        if (jsonData.choices && jsonData.choices.length > 0 && jsonData.choices[0].delta && jsonData.choices[0].delta.content) {
          const currText:string = this.chatRecord[this.chatRecord.length-1].content + jsonData.choices[0].delta.content
          this.chatRecord.pop();
          this.chatRecord.push(aiModel.toRecordItem('assistant',currText,[]))
          if (jsonData.choices[0].finish_reason === 'stop' && jsonData.usage) {
            this.TokenUsage.push(jsonData.usage.total_tokens.toString())
          }
        }
      }else if (config.currSupplier === 'Groq'){
        const jsonData:responseInterface.GroqStream = JSON.parse(data)
        if (jsonData.choices && jsonData.choices.length > 0 && jsonData.choices[0].delta && jsonData.choices[0].delta.content) {
          const currText:string = this.chatRecord[this.chatRecord.length-1].content + jsonData.choices[0].delta.content
          this.chatRecord.pop();
          this.chatRecord.push(aiModel.toRecordItem('assistant',currText,[]))
          if (jsonData.choices[0].finish_reason !== null && jsonData.x_groq && jsonData.x_groq.usage) {
            this.TokenUsage.push(jsonData.x_groq.usage.total_tokens.toString())
          }
        }
      }else{
        const jsonData:responseInterface.OpenAIStream = JSON.parse(data);
        if (jsonData.choices && jsonData.choices.length > 0 && jsonData.choices[0].delta && jsonData.choices[0].delta.content) {
          const currText:string = this.chatRecord[this.chatRecord.length-1].content + jsonData.choices[0].delta.content
          this.chatRecord.pop();
          this.chatRecord.push(aiModel.toRecordItem('assistant',currText,[]))
          if (jsonData.choices[0].finish_reason !== null) {
            this.TokenUsage.push('0')
          }
        }
      }

    });
    // 监听数据结束事件
    this.streamRequest.on('dataEnd', () => {
      if (this.occurredError) {
        this.chatRecord.pop();
        this.chatRecord.pop();
        this.occurredError = false
        return
      }
      console.log('dataEnd---')
      this.isLoading = false;
      aiModel.saveToDatabase(
        this.currId,
        'assistant',
        this.chatRecord[this.chatRecord.length-1].content as string,
        this.TokenUsage[this.TokenUsage.length-1]
      );
      if (config.ai.autoTitle && this.chatRecord.length === 3) {
        this.fetchItemNameIfNeeded()
      }
    });
    this.streamRequest.on('headersReceive',()=>{
      console.log('headersReceive---')
      this.chatRecord.push(aiModel.toRecordItem('assistant','',this.ImageUrl))
    });
  }
  // 发送消息
  private async sendMessage(){
    if (!this.userInput.trim()) {
      console.log('无输入')
      return;
    }
    try {
      this.buttonDisabled = false;
      this.chatRecord.push(aiModel.toRecordItem('user', this.userInput,this.ImageUrl));
      this.ImageUrl = [];
      this.userInput = "";
      aiModel.saveToDatabase(
        this.currId,
        'user',
        JSON.stringify(this.chatRecord[this.chatRecord.length-1].content),
        '0'
      )
      this.TokenUsage.push('0');
      const code:number = await aiModel.getStreamReply(this.chatRecord,this.streamRequest);
      if (code >= 400){
        this.occurredError = true
        if (code === 401) {
          AlertDialog.show({
            message: "APIkey错误"
          })
        }else if(code === 402){
          AlertDialog.show({
            message: "账号余额不足"
          })
        }else if(code === 429){
          AlertDialog.show({
            message: "请求速率（TPM 或 RPM）达到上限"
          })
        }else if(code === 500){
          AlertDialog.show({
            message: "服务器内部故障或负载过高"
          })
        }else{
          AlertDialog.show({
            message: "未知错误，请稍后重试。"
          })
        }
      }
    } catch (error) {
      console.error('错误：', JSON.stringify(error))
    }finally {
      this.buttonDisabled = true; // 重新启用按钮
    }

  }
  //设置语音识别回调
  setaudioback(){
    audio.on('Result',(data:string)=>{
      console.log('startWriteToInput')
      this.userInput = data + '1';
    })
  }

  async fetchItemNameIfNeeded() {
    try {
      const itemName = await aiModel.getItemName(this.chatRecord);
      if (itemName.token != 0) {
        this.itemName = itemName.message as string
      } else {
        this.itemName = "新对话"
      }
    } catch (error) {
      console.error("获取对话名称时发生错误:", error);
      this.itemName = "新对话"; // 设置默认名称以避免崩溃
    }
  }

  // 处理图片选择
  async handleImageSelect() {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const options:photoAccessHelper.PhotoSelectOptions = {
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 3
      }
      const result = await photoPicker.select(options);
      await this.processSelectedImages(result);
    } catch (error) {
      console.error('Image selection failed:', error);
      AlertDialog.show({ message: '图片选择失败，请重试' });
    }
  }

  // 处理选中图片
  async processSelectedImages(result: photoAccessHelper.PhotoSelectResult) {
    for (const uri of result.photoUris) {
      const file = fileIo.openSync(uri);
      try {
        const photoSize = fileIo.statSync(file.fd).size
        const buffer1 = new ArrayBuffer(photoSize);
        fileIo.readSync(file.fd,buffer1)
        this.ImageUrl.push(buffer.from(buffer1).toString('base64'));

        const source = image.createImageSource(file.fd);
        const pixelMap = await source.createPixelMap({
          editable: true,
          desiredPixelFormat: 3
        });

        this.chatImage.push(pixelMap);
      } finally {
        fileIo.closeSync(file); // 确保关闭文件描述符
      }
    }
  }
  // 提取消息项为独立组件
  @Builder
  messageItem(chat: Interfaces.Messages, index: number) {
    Row({ space: 8 }) {
      // 头像区域
      this.avatarSection(chat.role)

      // 消息内容区域
      if (chat.role === 'assistant') {
        Column(){
          this.assistantMessage(chat, index)
        }
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .border({
          radius: {
            topLeft: 2, // 模拟气泡尖角
            topRight: 8,
            bottomLeft: 8,
            bottomRight: 8
          }
        })
        .width('80%')
        .alignItems(HorizontalAlign.Start)
      } else if (chat.role === 'user') {
        Column(){
          this.userMessage(chat)
        }
        .backgroundColor("#07C160")  // 微信绿
        .border({
          radius: {
            topLeft: 8,
            topRight: 2,  // 模拟气泡尖角
            bottomLeft: 8,
            bottomRight: 8
          }
        })
        .constraintSize({maxWidth:'80%'})
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding({left:8, right:8})
    .justifyContent(chat.role === 'user' ? FlexAlign.End : FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }

  // 头像组件
  @Builder
  avatarSection(role: string) {
    if (role == 'assistant') { // 过滤系统消息
      Image($r('app.media.robot'))
        .size({
          width: this.STYLES.ICON_SIZE,
          height: this.STYLES.ICON_SIZE
        })
    }
  }
  // 助手消息组件
  @Builder
  assistantMessage(chat: Interfaces.Messages, index: number) {
      // 消息主体
      lvMarkdownIn({
        text: chat.content as string,
        loadMode: 'text'
      })
        .padding(12)
        .borderRadius(this.STYLES.BORDER_RADIUS)
        .alignSelf(ItemAlign.Start)

      // 统计信息
      if (config.display.showNumberOfReplies || config.display.showNumberOfTokenExpend) {
        this.messageStats(chat, index)
      }
  }
  // 消息统计组件
  @Builder
  messageStats(chat: Interfaces.Messages, index: number) {
    Row() {
      if (config.display.showNumberOfReplies) {
        Text(`Total: ${(chat.content as string).length}`)
          .fontColor($r('sys.color.font_secondary'))
          .padding(12)
      }
      if (config.display.showNumberOfTokenExpend && this.TokenUsage[index]) {
        Text(` TokenUsage: ${this.TokenUsage[index]}`)
          .fontColor($r('sys.color.font_secondary'))
          .padding(12)
      }
    }
    .width('100%')
    .margin({ top: 4 })
  }
  // 用户消息组件
  @Builder
  userMessage(chat: Interfaces.Messages) {
    Text((chat.content as Interfaces.ContentItem[])[0].text )
      .textAlign(TextAlign.End)
      .alignSelf(ItemAlign.End)
      .fontSize(config.display.fontsize)
      .fontColor($r('sys.color.font_primary'))
      .padding(12)
      .borderRadius(this.STYLES.BORDER_RADIUS)
  }
}