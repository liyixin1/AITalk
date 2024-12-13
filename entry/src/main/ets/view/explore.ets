import {myRequest} from '../../../common/Index'
import { aiModel } from '../ai_model'
import { http } from '@kit.NetworkKit';
import * as Interfaces from '../interface';
@Component
export struct Explore {
  @Consume('pageInfos') pageInfos: NavPathStack;
  build() {
    Row(){
      Button('nihao')
        .onClick(async (event:ClickEvent)=>{
          console.log("进入")
          let r = await myRequest<Interfaces.Groq,Interfaces.RequestBody>(aiModel.url,http.RequestMethod.POST,aiModel.headers,aiModel.body)
          console.log(r.choices[0].message.content as string)
          // console.info(JSON.stringify(JSON.parse(r)?.choices[0]?.message))
          console.log("出")
        })
    }
  }
}