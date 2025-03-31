import { deviceManager } from '../../common/Index'
import { distributedDeviceManager } from '@kit.DistributedServiceKit'
import { worker } from '@kit.ArkTS';
// 设备信息模型
class DeviceInfo {
  deviceId: string = ""      // 设备唯一标识
  deviceName: string = ""     // 设备名称（如"智能手表"）
  deviceType: string = '0'      // 设备类型（手机/平板等）
  networkId?:string = ""       //设备网络识别
}
@Builder
export function DeviceBuilder() {
  DevicePage()
}
@Preview
@Entry
@Component
struct DevicePage {
  pathStack: NavPathStack | null = null
  @State deviceList: Array<DeviceInfo> = [];
  @State unconnected_devices:distributedDeviceManager.DeviceBasicInfo[] = []
  aboutToAppear(): void {

  }

  build() {
    NavDestination() {
      Column() {
        // 标题栏
        Row() {
          Text("已绑设备 (" + this.deviceList.length + ")")
            .fontSize(20)
        }
        .width('100%')
        .padding(12)
        // 设备列表主体
        List({ space: 8 }) {
          ForEach(this.deviceList, (item: DeviceInfo) => {
            ListItem() {
              Row() {
                // 设备图标（根据类型显示不同图标）
                Image($r(this.getDeviceIcon(Number(item.deviceType))))
                  .width(24)
                  .height(24)
                  .margin({ right: 12 })

                // 设备信息列
                Column() {
                  Text(item.deviceName)
                    .fontSize(16)
                  // Text(`${item.isOnline ? '在线' : '离线'} | ${item.lastActiveTime}`)
                  //   .fontSize(12)
                  //   .fontColor(Color.Gray)
                }
                .layoutWeight(1)
                // 解绑操作按钮
                Button("解绑")
                  .onClick(() => this.unbindDevice(item.deviceId))
              }
              .padding(12)
              .borderRadius(8)
              .shadow({ radius: 4, color: Color.Gray, offsetX: 1, offsetY: 1 })
            }
          }, (item:DeviceInfo) => item.deviceId)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.None)
        Divider().width('100%').height(2)
        Row() {
          Text("发现的设备 (" + this.unconnected_devices.length + ")")
            .fontSize(20)
        }
        .width('100%')
        .padding(12)
        List({ space: 8 }) {
          ForEach(this.unconnected_devices, (item: DeviceInfo) => {
            ListItem() {
              Row() {
                // 设备图标（根据类型显示不同图标）
                Image($r(this.getDeviceIcon(Number(item.deviceType))))
                  .width(40)
                  .height(40)
                  .margin({ right: 12 })
                // 设备信息列
                Column() {
                  Text(item.deviceName)
                    .fontSize(16)
                //   Text(`${item.isOnline ? '在线' : '离线'} | ${item.lastActiveTime}`)
                //     .fontSize(12)
                //     .fontColor(Color.Gray)
                }
                .layoutWeight(1)
                Divider().width('100%').height(2)
                // 绑定操作按钮
                Button("绑定")
                  .backgroundColor(Color.Transparent)
                  .onClick(() => deviceManager.bindDevice(item.deviceId,(err,data)=>{
                    let temp = deviceManager.getDeviceData(data.deviceId)
                    if (typeof temp !== 'string') {
                      this.deviceList.push(temp as DeviceInfo)
                    }
                  }))
              }
              .padding(12)
              .borderRadius(8)
              .shadow({ radius: 4, color: Color.Gray, offsetX: 1, offsetY: 1 })
            }
          }, (item:DeviceInfo) => item.deviceId)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.None)
        Blank()
        Button("搜索设备",{ type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .backgroundColor($r('sys.color.comp_background_emphasize'))
          .onClick(()=>{
            console.log('点击')
            deviceManager.startDiscovery()
          })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title("设备")
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.loadBoundDevices();
    })
  }
  // 加载已绑定设备（示例方法）
  private loadBoundDevices() {
    try {
      const devices = deviceManager.getDeviceList()
      console.log("当前绑定：" + devices.length.toString() + '个')
      for (let i = 0; i < devices.length; i++) {
        const element = devices[i];
        this.deviceList.push(new DeviceInfo())
        this.deviceList[this.deviceList.length-1].deviceId = element.deviceId
        this.deviceList[this.deviceList.length-1].deviceName = element.deviceName
        this.deviceList[this.deviceList.length-1].deviceType = element.deviceType
        this.deviceList[this.deviceList.length-1].networkId = element.networkId
      }
    } catch (err) {
      console.error("设备加载失败:", err);
    }
  }

  // 解绑设备操作
  private unbindDevice(deviceId: string) {
    try {

      deviceManager.unBingDevice(deviceId);
      this.deviceList = this.deviceList.filter(d => d.deviceId !== deviceId);
    } catch (err) {
      console.error("解绑失败:", err);
    }
  }

  // 根据设备类型获取图标资源
  private getDeviceIcon(type: number): string {
    switch(type) {
      case 1: return 'app.media.phone';
      case 2: return 'app.media.Tablet';
      default: return 'app.media.device';
    }
  }
}