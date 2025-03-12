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

@Preview
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
  // 新增样式常量集中管理
  private readonly STYLES: GeneratedObjectLiteralInterface_1 = {
    ICON_SIZE: 32,
    IMAGE_PREVIEW_SIZE: 64,
    INPUT_BUTTON_WIDTH: 64,
    BORDER_RADIUS: 8,
    TYPING_INTERVAL: 10
  }

  async aboutToAppear() {
    if (config.currSupplier === 'OpenAI') {
      this.chatRecord.push({
        role: 'developer',
        content: config.ai.chatPrompt,
      })
    } else if (config.currSupplier === 'Groq') {
      this.chatRecord.push({
        role: 'system',
        content: config.ai.chatPrompt,
      })
    }
    this.TokenUsage.push('0');
    lvText.setTextSize(config.display.fontsize)
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        Column() {
          List({ space: 10 }) {
            ForEach(this.chatRecord, (chat: Interfaces.Messages, index) => {
              this.messageItem(chat, index)
            })
          }.height('100%')
          .width('100%')
        }
        .width("100%")
        .height('95%')
        Column(){
          TextArea({ text: $$this.userInput })
            .type(TextAreaType.NORMAL)
            .width('95%')
            .flexGrow(1)
            .margin(5)
            .borderRadius(8)
          Row(){
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.picture'))
                .fillColor($r('sys.color.icon_primary'))
                .onClick(() => this.handleImageSelect())
            }
            .width(32)
            .height(28)
            .flexGrow(0)
            .margin(5)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            Blank()
            Button($r('app.string.ListItem_send'), { type: ButtonType.Normal, stateEffect: true })
              .enabled(this.buttonDisabled)
              .width(64)
              .height(28)
              .buttonStyle(ButtonStyleMode.EMPHASIZED)
              .borderRadius(4)
              .flexGrow(0)
              .margin(5)
              .alignSelf(ItemAlign.End)
              .onClick(async () => {
                if (!this.userInput.trim()) return;

                this.buttonDisabled = false;

                let date = new Date().toLocaleDateString()
                try {
                  inputMethod.getController().stopInputSession();
                  this.chatRecord.push(aiModel.toRecordItem('user', this.userInput, this.ImageUrl))
                  this.TokenUsage.push('0');
                  this.ImageUrl = [];
                  this.userInput = "";

                  const reply = await aiModel.getReply(this.chatRecord);
                  if (reply.token === 0) {
                    this.chatRecord.pop();
                    this.TokenUsage.pop();
                    AlertDialog.show({
                      message: reply.message as string
                    })
                    return
                  }
                  dbUtil.insertData("record" + this.currId, {
                    SENDER: this.chatRecord[this.chatRecord.length-1].role,
                    MESSAGE: JSON.stringify(this.chatRecord[this.chatRecord.length-1].content),
                    TOKENUSAGE: '0',
                    TIMESTAMP: date
                  })
                  this.chatRecord.push(aiModel.toRecordItem('assistant', '', this.ImageUrl));
                  if (config.currSupplier === 'DeepSeek'){
                    this.arrtext = (reply.message as Interfaces.DeepSeekMessage).content.split("")
                  }else{
                    this.arrtext = (reply.message as string).split("")
                  }
                  this.timer = setInterval(() => {
                    let item = this.arrtext[this.index]
                    let currtext:string = (this.chatRecord[this.chatRecord.length-1].content as string) + item
                    this.chatRecord.pop()
                    this.chatRecord.push(aiModel.toRecordItem('assistant', currtext, this.ImageUrl))
                    this.index++
                    if (this.index >= this.arrtext.length) {
                      clearInterval(this.timer)
                    }
                  }, 10)
                  this.TokenUsage.push(reply.token.toString())
                  dbUtil.insertData("record" + this.currId, {
                    SENDER: this.chatRecord[this.chatRecord.length-1].role,
                    MESSAGE: this.chatRecord[this.chatRecord.length-1].content as string,
                    TOKENUSAGE: reply.token.toString(),
                    TIMESTAMP: date
                  })
                  if (config.ai.autoTitle) {
                    this.fetchItemNameIfNeeded();
                  }
                } catch (error) {
                  console.error('发送过程错误:', error);
                } finally {
                  this.buttonDisabled = true; // 重新启用按钮
                }
              })
          }.width('100%').justifyContent(FlexAlign.Start)
        }.width('100%').constraintSize({ maxHeight: "40%" })
        Row({ space: 4 }) {
          ForEach(this.chatImage, (item: image.PixelMap, index) => {
            Image(item)
              .height(64)
              .borderRadius(8)
              .onClick(() => {
                this.chatImage.splice(index, 1);
                this.ImageUrl.splice(index, 1);
              })

          }, (item: string) => item)
        }.width('100%')
        .margin(4)
        .constraintSize({ maxHeight: "15%" })
      }.width('100%').height('100%')
      .backgroundColor($r('sys.color.background_primary'))
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

  async fetchItemNameIfNeeded() {
    if (this.chatRecord.length === 3) {
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
        .borderRadius(8)
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
        }.borderRadius(8)
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
    Column() {
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
    Text((chat.content as Interfaces.ContentItem[])[0].text as string)
      .textAlign(TextAlign.End)
      .alignSelf(ItemAlign.End)
      .fontSize(config.display.fontsize)
      .fontColor($r('sys.color.font_primary'))
      .padding(12)
      .borderRadius(this.STYLES.BORDER_RADIUS)
  }


}