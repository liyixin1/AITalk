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

// 实现IDataSource接口的数据源类
export class MessageDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private dataArray: MessageHistory[] = [];

  totalCount(): number {
    return this.dataArray.length;
  }

  getData(index: number): MessageHistory {
    return this.dataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (!this.listeners.includes(listener)) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  // 数据更新方法（核心）
  pushData(item: MessageHistory): void {
    this.dataArray.push(item);
    this.listeners.forEach(listener => listener.onDataAdd(this.dataArray.length - 1));
  }

  deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.listeners.forEach(listener => listener.onDataDelete(index));
  }
  upData(item:number,name:string): void {
    this.dataArray[item].name = name
    this.listeners.forEach(listener => listener.onDataChange(item))
  }
}