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