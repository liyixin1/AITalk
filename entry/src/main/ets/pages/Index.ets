import { ConfigManager } from '../config'
import { Messages } from '../view/messages'
import { Me } from '../view/me'
import { Explore } from '../view/explore'

import { IconType, router } from '@kit.ArkUI';
import { preferenceUtil } from '../../../common/Index'
import * as Interfaces from '.././interface';

import { ListItemBuilder } from './list_item_page'

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @State config:ConfigManager = new ConfigManager()
  @State currentIndex: number = 0;

  @State TooBar:Array<ToolbarItem> = [
    {'value': "对话",
      'icon': this.currentIndex == 0 ? $r('app.media.ic_public_comments_light'):$r('app.media.ic_public_comments_dark'),
      'action': ()=> {
        this.currentIndex = 0;
      }},
    {'value': "探索",
      'icon': $r('app.media.ic_public_add_light'),
      'action': ()=> {
        this.currentIndex = 1;
      }},
    {'value': "我的",
      'icon': $r('app.media.ic_public_contacts_light'),
      'action': ()=> {
        this.currentIndex = 2;
      }}
  ]
  @State TooTmp:Array<NavigationMenuItem > = [
    {'value': "",
      'icon': '../../resources/base/media/ic_public_search.svg',
      'action': ()=> {

      }},
    {'value': "",
      'icon': '../../resources/base/media/huaweilogo1.png',
      'action': ()=> {
        router.pushUrl({
          url:'pages/main_page'
        })
      }}
  ]

  build() {
    Navigation(this.pageInfos){
      if (this.currentIndex == 0){
        Messages();
      }else if(this.currentIndex == 1){
        Explore();
      }else {
        Me();
      }
    }
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .title('畅聊')
    .menus(this.TooTmp)
    .toolbarConfiguration(this.TooBar)
  }
}
