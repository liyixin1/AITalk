import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import * as Interfaces from '../../main/ets/interface'
import { MessageHistory } from '../../main/ets/data_class'
class DBUtil{
  private rdbStore:relationalStore.RdbStore | null = null;
  isDBReady:boolean = false
  initDB(context:Context,tableName:string){
    // 初始化数据库配置
    const STORE_CONFIG :relationalStore.StoreConfig= {
      name: 'RdbTest.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S3, // 数据库安全级别
      encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
      customDir: 'customDir/subCustomDir', // 可选参数，数据库自定义路径。数据库将在如下的目录结构中被创建：context.databaseDir + '/rdb/' + customDir，其中context.databaseDir是应用沙箱对应的路径，'/rdb/'表示创建的是关系型数据库，customDir表示自定义的路径。当此参数不填时，默认在本应用沙箱目录下创建RdbStore实例。
      isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
    };
    // 建表
    const SQL_CREATE_USER_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    PHONE_NUMBER VARCHAR(20) NOT NULL,
    PASSWORD VARCHAR(15),
    EMAIL VARCHAR(255),
    NAME TEXT
    )`;
    relationalStore.getRdbStore(context, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`获取RdbStore失败. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info('获取RdbStore成功.');
      this.rdbStore = store;

      store.executeSql(SQL_CREATE_USER_TABLE,(error)=>{
        if(!error){
          console.log(`${tableName}创建成功。`);
        }else {
          console.log(`${tableName}创建失败。code:${error.code}--error:${error}`);
        }
      }); //建表
      this.createItemTable("myList");
    })
    this.isDBReady = true;
  }
  createItemTable(tableName:string){
    const SQL_CREATE_LISTITEM_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    CREEATE_TIME TEXT,
    NAME TEXT
    )`;
    if(this.rdbStore !== null){
      this.rdbStore.executeSql(SQL_CREATE_LISTITEM_TABLE,(error)=>{
        if(!error){
          console.log(`${tableName}创建成功。`);
        }else {
          console.log(`${tableName}创建失败。error:${error}`);
        }
      }); //建表
    }
  }

  // ------------------------------------------------------//
  createRecordTable(tableName:string){
    const SQL_CREATE_CHATRECORD_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    SENDER TEXT NOT NULL,
    MESSAGE TEXT NOT NULL,
    TOKENUSAGE TEXT NOT NULL,
    TIMESTAMP DATETIME NOT NULL
    )`;
    if(this.rdbStore !== null){
      this.rdbStore.executeSql(SQL_CREATE_CHATRECORD_TABLE,(error)=>{
        if(!error){
          console.log(`${tableName}创建成功。`);
        }else {
          console.log(`${tableName}创建失败。error:${error}`);
        }
      }); //建表
    }
  }
  deleteRecordTable(tableName:string){
    const SQL_DELETE_CHATRECORD_TABLE = `DROP TABLE ${tableName};`
    if(this.rdbStore !== null){
      this.rdbStore.executeSql(SQL_DELETE_CHATRECORD_TABLE,(error)=>{
        if(!error){
          console.log(`${tableName}删除成功。`);
        }else {
          console.log(`${tableName}删除失败。error:${error}`);
        }
      })//删除表
    }
  }
  // 插入
   insertData(tableName:string,value:relationalStore.ValuesBucket){
    if (this.rdbStore !== null) {
      this.rdbStore.insert(tableName,value,(error:BusinessError,rowId:number)=>{
        if(error){
          console.log(`往${tableName}中添加数据失败--code:${error.code}--${error.name}--${error.message}`);
          return;
        }
        console.log(`往${tableName}中添加数据成功，rowId:${rowId}`);
      })
    }
  }
  // 带返回插入
  insertDataR(tableName: string, value: relationalStore.ValuesBucket): Promise<number> {
    return new Promise((resolve, reject) => {
      if (this.rdbStore !== null) {
        this.rdbStore.insert(tableName, value, (error: BusinessError, rowId: number) => {
          if (error) {
            console.log(`往${tableName}中添加数据失败--code:${error.code}--${error.name}--${error.message}`);
            reject(error); // 拒绝Promise并传递错误信息
          } else {
            console.log(`往${tableName}中添加数据成功，rowId:${rowId}`);
            resolve(rowId); // 解决Promise并传递rowId
          }
        });
      } else {
        reject(new Error('Database store is not initialized')); // 如果数据库存储未初始化，拒绝Promise
      }
    });
  }
  // 删除
  deleteById(tableName:string,id:number){
    // 删除数据
    let predicates1 = new relationalStore.RdbPredicates(tableName);
    // 筛选条件
    predicates1.equalTo('ID', id);
    if (this.rdbStore !== null) {
    this.rdbStore.delete(predicates1, (err: BusinessError, rows: number) => {
        if (err) {
          console.error(`删除${tableName}中id${id}失败 Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info(`对${tableName}中数据删除成功: ${rows}`);
      })
    }
  }
  // 同步删除
  deleteSyncById(tableName:string,id:number){
    // 删除数据
    let predicates1 = new relationalStore.RdbPredicates(tableName);
    // 筛选条件
    predicates1.equalTo('ID', id);
    if (this.rdbStore !== null) {
      try {
        let h = this.rdbStore.deleteSync(predicates1);
        console.log(`删除的行数${h}`)
      } catch (err) {
        console.error('发生错误：'+ err)
      }
    }
  }
  // 更新
  upDataById(tableName:string, id:number, value:relationalStore.ValuesBucket){
    // 修改数据
    let predicates1 = new relationalStore.RdbPredicates(tableName); // 创建表'EMPLOYEE'的predicates
    predicates1.equalTo('ID', id); // 匹配表'EMPLOYEE'中'NAME'为'Lisa'的字段
    if (this.rdbStore !== null) {
      this.rdbStore.update(value, predicates1, (err: BusinessError, rows: number) => {
        if (err) {
          console.error(`对${tableName}中数据id${id}修改失败 Code:${err.code}, message:${err.message}`);
          return;
        }
        console.info(`对${tableName}中数据修改成功 row count: ${rows}`);
      })
    }
  }
  // 查找列表
  async queryListDataById(column:Array<string>,tableName:string,id?:number){
    let predicates2 = new relationalStore.RdbPredicates(tableName);
    if(id){
      predicates2.equalTo('ID', id);
    }
    let rData:Array<MessageHistory> = [];
    const resultSet = await (this.rdbStore as relationalStore.RdbStore).query(predicates2,column);
    // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
    while (resultSet.goToNextRow()) {
      let id = resultSet.getDouble(resultSet.getColumnIndex("ID"));
      let name = resultSet.getString(resultSet.getColumnIndex("NAME"));
      let date = resultSet.getString(resultSet.getColumnIndex("CREEATE_TIME"));
      let temp:MessageHistory = new MessageHistory(id,name,date);
      rData.push(temp);
    }
    console.log('List读取结束')
    resultSet.close();
    return rData
  }
  // 同步查找
  querySyncListDataById(column:Array<string>,tableName:string,id?:number){
    let predicates2 = new relationalStore.RdbPredicates(tableName);
    if(id){
      predicates2.equalTo('ID', id);
    }
    let rData:Array<MessageHistory> = [];
    const resultSet = (this.rdbStore as relationalStore.RdbStore).querySync(predicates2,column);
    // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
    while (resultSet.goToNextRow()) {
      let id = resultSet.getDouble(resultSet.getColumnIndex("ID"));
      let name = resultSet.getString(resultSet.getColumnIndex("NAME"));
      let date = resultSet.getString(resultSet.getColumnIndex("CREEATE_TIME"));
      let temp:MessageHistory = new MessageHistory(id,name,date);
      rData.push(temp);
    }
    rData.reverse()
    console.log('List读取结束')
    resultSet.close();
    return rData
  }

  //查找聊天记录
  async queryRecordDataById(column:Array<string>,tableName:string,id?:number){
    let predicates2 = new relationalStore.RdbPredicates(tableName);
    if(id){
      predicates2.equalTo('ID', id);
    }
    let s:number = 0;
    let rData:Array<Interfaces.Messages2> = [];
    const resultSet = await (this.rdbStore as relationalStore.RdbStore).query(predicates2,column);
    // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
    while (resultSet.goToNextRow()) {
      s += 1;
      let sender = resultSet.getString(resultSet.getColumnIndex("SENDER"));
      let message = resultSet.getString(resultSet.getColumnIndex("MESSAGE"));
      let token = resultSet.getString(resultSet.getColumnIndex("TOKENUSAGE"));
      if(sender === "user"){
        const temp:Interfaces.Messages2 = {role:sender,content:JSON.parse(message) as Array<Interfaces.ContentItem>,token:token};
        rData.push(temp);
      }else if(sender === 'assistant'){
        const temp:Interfaces.Messages2 = {role:sender,content:message,token:token};
        rData.push(temp);
      }else{
        const temp:Interfaces.Messages2 = {role:sender,content:message,token:token}
        rData.push(temp);
      }
    }
    console.log(`Record读取结束:${s}条内容`)
    resultSet.close();
    return rData
  }


}

const dbUtil = new DBUtil();
export { dbUtil };