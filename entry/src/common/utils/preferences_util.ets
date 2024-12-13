import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

export class PreferencesUtil {
  private dataPreferences: preferences.Preferences | null = null;

  init(context:Context,storeName:string) {
    let options: preferences.Options = { name: storeName };
    this.dataPreferences = preferences.getPreferencesSync(context, options);

}
  insertData(key:string,value:preferences.ValueType) {
    if(this.dataPreferences) {
      if(this.dataPreferences.hasSync(key)) {
        console.info("已经存在key：" + key);
      }else {
        this.dataPreferences.putSync(key,value);
        console.info("添加成功");
        this.flushData()
      }
    }

  }
  upData(key:string, value:preferences.ValueType) {
    if(this.dataPreferences) {
      this.dataPreferences.putSync(key,value);
      console.info("修改成功");
      this.flushData()
    }
  }
  readDate(key:string, defaultValue:preferences.ValueType):preferences.ValueType {
    let val:preferences.ValueType;
    if(this.dataPreferences){
      try{
        val = this.dataPreferences.getSync(key, defaultValue);
        console.info("查询' "+ key + " 'value is :" + val);
      } catch (error) {
        console.error("获取键值时发生错误: " + error);
        val = defaultValue;
      }
    }else {
      val = defaultValue;
    }
    return val;
  }
  private flushData() {
    // 持久化到硬盘
    (this.dataPreferences as preferences.Preferences).flush((err: BusinessError) => {
      if (err) {
        console.error("Failed to flush. code =" + err.code + ", message =" + err.message);
        return;
      }
      console.info("Succeeded in flushing.");
    });
  }
}

const preferenceUtil = new PreferencesUtil();
export { preferenceUtil };