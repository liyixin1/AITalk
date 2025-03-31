@Observed
export class MessageHistory {
  id:number
  name:string
  datetime:string
  constructor(id:number, name:string, datetime:string) {
    this.id = id;
    this.name = name;
    this.datetime = datetime;
  }
}
@ObservedV2
export class ListMessages {
  role:string
  @Trace content:ContentItem[] | string
  constructor(role:string,content:ContentItem[] | string) {
    this.role = role;
    this.content = content
  }
}
export class ContentItem {
  type:string
  text?:string
  image_url?:ContentItemImage
  constructor(type:string, text?:string, image_url?:ContentItemImage) {
    this.type = type;
    this.text = text;
    this.image_url = image_url;
  }
}
export class ContentItemImage {
  url:string
  constructor(url:string) {
    this.url = url
  }
}