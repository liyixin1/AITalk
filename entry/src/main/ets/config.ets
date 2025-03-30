import { preferenceUtil } from './common/Index'
import * as Interfaces from './interface';
import { buffer } from '@kit.ArkTS';
import { dbUtil } from './common/Index'
import { util } from '@kit.ArkTS';
import { fileIo as fs,} from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { MessageHistory } from './data_class'
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit';

class ConfigManager{
  // 配置模型参数
  PROVIDER_ICON:string = "app.media.star_fill"
  ai:Interfaces.Parameter;  //模型参数
  currSupplier:string;
  display:Interfaces.Display; //显示设置
  messageList:MessageHistory[]; //消息列表
  provider:Array<Interfaces.Provider>;
  providerName:Array<SelectOption>;
  providerModel:Array<Array<SelectOption>>;
  isChange:boolean;
  // 读取文件完成标志
  isConfigReady: boolean = false;
  constructor(){
    this.ai = {
      url:'',
      apiKey:'',
      model:'',
      chatRounds:20,
      temperature:1,
      chatPrompt:'你是一个知识渊博且细致的助手，能够以专业、简洁和友好的语气回答问题。无论用户提出的问题有多复杂，你都要提供清晰、有条理的回答。请使用中文回答问题。',
      autoTitle:true
    }
    this.display = {
      language:'简体中文',
      fontsize:16,
      theme:0,
      showNumberOfReplies:true,
      showNumberOfTokenExpend:true,
    }
    this.currSupplier = '';
    this.messageList = [];
    this.provider = [];
    this.providerName = [];
    this.providerModel = [];
    this.isChange = false;
  }
  initConfig(){
    if(preferenceUtil.readDate('isFirstRun',false)){
      this.provider = this.getJsonData('/ai_model.json');
      for (let index = 0; index < this.provider.length; index++) {
        const element = this.provider[index];
        this.providerName.push({ value:element.name,icon:$r(this.PROVIDER_ICON) })
        let val:Array<SelectOption> = [];
        for (let index = 0; index < element.model.length; index++) {
          const temp = element.model[index];
          val.push({value:temp});
        }
        this.providerModel.push(val);
      }
      preferenceUtil.insertData('provider',this.provider)
      preferenceUtil.upData('isFirstRun',false);
      preferenceUtil.insertData('currSupplier',this.currSupplier);
      for (let index = 0; index < this.providerName.length; index++) {
        const temp:Interfaces.Parameter = {
          url:this.provider[index].url,
          apiKey:'',
          model:this.provider[index].model[0],
          chatRounds:20,
          temperature:0.8,
          chatPrompt:'',
          autoTitle:true
        }
        preferenceUtil.insertData(this.providerName[index].value.toString(),temp);
      }
      preferenceUtil.insertData('display',this.display);
    }else{
      this.provider = preferenceUtil.readDate('provider',this.provider) as Array<Interfaces.Provider>;
      for (let index = 0; index < this.provider.length; index++) {
        const element = this.provider[index];
        this.providerName.push({ value:element.name,icon:$r(this.PROVIDER_ICON) })
        let val:Array<SelectOption> = [];
        for (let index = 0; index < element.model.length; index++) {
          const temp = element.model[index];
          val.push({value:temp});
        }
        this.providerModel.push(val);
      }
      this.currSupplier = preferenceUtil.readDate('currSupplier',this.currSupplier) as string
      this.ai = preferenceUtil.readDate(this.currSupplier,this.ai) as Interfaces.Parameter;
      this.display = preferenceUtil.readDate('display',this.display) as Interfaces.Display;
      this.messageList = dbUtil.querySyncListDataById(['ID',"NAME","CREEATE_TIME"],"myList");
    }
    this.isConfigReady = true; // 标志完成
    console.log('config OK')
  }
  // 在调用处使用async/await同步
  deleteListItem(index:number){
    this.messageList.splice(index,1);
    preferenceUtil.upData('messageList',this.messageList);
  }
  getJsonData(filename:string):Array<Interfaces.Provider>{
    // let data = getContext(this).resourceManager.getRawFileContentSync(filename);
    const context = getContext(this);
    let path = context.resourceDir + filename;
    let file = fs.openSync(path);
    // 获取文件大小
    let fileSize = fs.statSync(file.fd).size;
    // 分配缓冲区
    let bufferdata = new ArrayBuffer(fileSize);
    fs.readSync(file.fd, bufferdata);
    fs.close(file.fd);
    let str = buffer.from(bufferdata).toString();
    const pro = JSON.parse(str) as Array<Interfaces.Provider>;
    // console.log(this.provider[0].name);
    return pro;
  }

  upDateModelSet(supplierName:string,url:string,apiKey:string,model:string,chatRounds:number,temperature:number){
    this.currSupplier = supplierName;
    this.ai.url = url;
    this.ai.apiKey = apiKey;
    this.ai.model = model;
    this.ai.chatRounds = chatRounds;
    this.ai.temperature = temperature;
    preferenceUtil.upData(supplierName,this.ai);
  }
  newModel(supplierName:string, model:string, apikey:string, url:string, temp:number,chatRound:number){
    const data:Interfaces.Parameter = {
      url:url,
      apiKey:apikey,
      model:model,
      chatRounds:chatRound,
      temperature:temp,
      chatPrompt:this.ai.chatPrompt,
      autoTitle:this.ai.autoTitle
    }
    preferenceUtil.insertData(supplierName,data)
    const newModel:Interfaces.Provider = {
      name: supplierName,
      model: [model],
      url: url
    }
    this.provider.push(newModel);
    this.providerName.push({ value:supplierName,icon:$r(this.PROVIDER_ICON) })
    this.providerModel.push([{value:model}])
    preferenceUtil.upData('provider',this.provider);
    // this.provider.push(newModel)
    // // 写入json文件
    // const context = getContext(this);
    // let path = context.resourceDir + '/ai_model.json';
    // let file = fs.openSync(path,fs.OpenMode.READ_WRITE);
    // fs.writeSync(file.fd,this.provider.toString())
    // fs.closeSync(file.fd);
  }
  deleteUserDefinedModel(){

  }
  upDateChatPrompt(chatPrompt:string,autoTitle:boolean){
    this.ai.chatPrompt = chatPrompt;
    this.ai.autoTitle  = autoTitle;
    preferenceUtil.upData(this.currSupplier,this.ai);
  }
  upDateDisplay(language:string,fontsize:number,theme:number,replies:boolean,tokenExpend:boolean){
    this.display = {
      language:language,
      fontsize:fontsize,
      theme:theme,
      showNumberOfReplies:replies,
      showNumberOfTokenExpend:tokenExpend
    }
    preferenceUtil.upData("display",this.display);
  }

  getLangNum(currLang:string):number{
    if(currLang === '简体中文'){
      return 0;
    }else if(currLang === 'English'){
      return 1;
    }else{
      return 2;
    }
  }

  toImageBase64(data:Uint8Array){
    let base64Helper  = new util.Base64Helper();
    let result:string = base64Helper .encodeToStringSync(data, util.Type.MIME);
    return result
  }
  async checkPermission(): Promise<boolean> {
    try {
      // 获取应用TokenID
      const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const tokenId = bundleInfo.appInfo.accessTokenId;

      // 同步检查权限状态
      const grantStatus = await abilityAccessCtrl.createAtManager().checkAccessToken(tokenId, 'ohos.permission.DISTRIBUTED_DATASYNC');
      return grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    } catch (err) {
      console.error(`权限检查失败: ${JSON.stringify(err)}`);
      return false;
    }
  }
  async requestDistributedSyncPermission(): Promise<boolean>{
    // 动态申请权限
    console.log('进入申请')
    const context = getContext(this) as common.UIAbilityContext;
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      atManager.requestPermissionsFromUser(context, ['ohos.permission.DISTRIBUTED_DATASYNC']).then(async (data) => {
        console.log('data: ' + JSON.stringify(data));
        if (data.authResults[0] === 0) {
          return true
        }else {
          // 用户拒绝，跳转系统设置
          await atManager.requestPermissionOnSetting(context, ['ohos.permission.DISTRIBUTED_DATASYNC']);
          return await this.checkPermission(); // 再次校验设置后的状态
        }
      }).catch((err: object) => {
        console.log('err: ' + JSON.stringify(err));
      })
    } catch (err) {
      console.log('catch err->' + JSON.stringify(err));
    }
    return false
  }

}

const config = new ConfigManager();
export { config };