import { relationalStore } from '@kit.ArkData';

class DBUtil{
  private rdbStore:relationalStore.RdbStore | null = null;
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
    const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS ${tableName} (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    PHONE_NUMBER VARCHAR(20) NOT NULL,
    PASSWORD VARCHAR(15),
    EMAIL VARCHAR(255),
    NAME TEXT,
    )`;
    relationalStore.getRdbStore(context, STORE_CONFIG, (err, store) => {
      if (err) {
        console.error(`获取RdbStore失败. Code:${err.code}, message:${err.message}`);
        return;
      }
      console.info('获取RdbStore成功.');
      this.rdbStore = store;

      store.executeSql(SQL_CREATE_TABLE,(error)=>{
        if(!error){
          console.log(`${tableName}创建成功。`);
        }else {
          console.log(`${tableName}创建失败。error:${error}`);
        }
      }); //建表
    })
  }
  insertData(tableName:string){

  }
  queryData(column:Array<string>,tableName:string){

  }

}

const dbUtil = new DBUtil();
export { dbUtil };