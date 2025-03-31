import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

class Data {
  deviceId: string = '';
}
// 设备信息模型
class DeviceInfo {
  deviceId: string = ""      // 设备唯一标识
  deviceName: string = ""     // 设备名称（如"智能手表"）
  deviceType: string = '0'      // 设备类型（手机/平板等）
  networkId?:string = ""       //设备网络识别
}

export class DeviceManager {
  dmInstance:distributedDeviceManager.DeviceManager;
  private isDiscovering: boolean = false;
  constructor() {
    this.dmInstance = distributedDeviceManager.createDeviceManager('com.lyxiiin.aitalk');
    try {
      this.dmInstance.on('discoverSuccess', data => console.log('discoverSuccess on:' + JSON.stringify(data)));
      this.dmInstance.on('discoverFailure', data => console.log('discoverFailure on:' + JSON.stringify(data)));
    } catch(err) {
      let e: BusinessError = err as BusinessError;
      console.error('createDeviceManager errCode:' + e.code + ',errMessage:' + e.message);
    }
  }
  private registerEvent():void{
    // 注册发现回调
    this.dmInstance.on('discoverSuccess', (deviceInfo) => {
      console.info(`发现设备：${JSON.stringify(deviceInfo)}`);

    });
    this.dmInstance.on('discoverFailure', (deviceInfo) => {
      console.info(`发现失败：${JSON.stringify(deviceInfo)}`);

    });
  }

  startDiscovery(): void {
    if (this.isDiscovering) {
      try {
        this.dmInstance.stopDiscovering(); // 停止当前发现流程
      } catch (err) {
        console.error("停止发现失败:", err);
      }
    }
    this.isDiscovering = true;
    // 设置超时自动停止（鸿蒙默认发现时长为2分钟）
    setTimeout(() => {
      // this.dmInstance.stopDiscovering();
      this.isDiscovering = false;
    }, 120000);
    let discoverParam: Record<string, number> = {
      'discoverTargetType': 1
    };
    let filterOptions: Record<string, number> = {
      'availableStatus': 0,
      'authorizationType':2
    };
    try {
      console.log('开始发现设备')
      this.dmInstance.startDiscovering(discoverParam, filterOptions);
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error('startDiscovering errCode:', e.code, ',errMessage:', e.message);
    }
  }
  bindDevice(deviceId: string, callback: (err: BusinessError, data:Data) => void): void {
    let bindParam: Record<string, string | number> = {
      'bindType': 1, // 认证类型： 1 - 无账号PIN码认证
      'targetPkgName': 'com.lyxiiin.aitalk',
      'appName': 'AITalk',
      'appOperation': 'xxxx',
      'customDescription': '跨设备数据同步'
    };
    try {
      this.dmInstance.bindTarget(deviceId, bindParam, (err: BusinessError, data: Data) => {
        if (err) {
          console.error('bindTarget errCode:', err.code, ',errMessage:', err.message);
          return;
        }
        console.info('bindTarget result:', data);
        callback(err, data);
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error('bindTarget errCode:', e.code, ',errMessage:', e.message);
    }
  }
  getDeviceData(deviceId:string):DeviceInfo | string{
    try {
      let DeviceData:DeviceInfo = {
        deviceId:deviceId,
        deviceName:this.dmInstance.getDeviceName(deviceId),
        deviceType:this.dmInstance.getDeviceType(deviceId).toString()
      };
      return DeviceData
    }catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error('getDeviceData errCode:' + e.code + ',errMessage:' + e.message);
      return 'Error'
    }
  }

  getDeviceList(): Array<distributedDeviceManager.DeviceBasicInfo> {
    try {
      return this.dmInstance.getAvailableDeviceListSync();
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error('getAvailableDeviceListSync errCode:', e.code, ',errMessage:', e.message);
      return [];
    }
  }
  unBingDevice(deviceId: string):string{
    try {
      AlertDialog.show({
        message: '确定解绑设备？',
        confirm: {value:'确定', action: () => this.dmInstance?.unbindTarget(deviceId) }
      })
      return 'OK'
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      console.error('unbindTarget errCode:' + e.code + ',errMessage:' + e.message);
      return 'Error'
    }
  }
}

const deviceManager = new DeviceManager();
export { deviceManager };