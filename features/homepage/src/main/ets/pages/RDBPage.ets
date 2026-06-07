import relationalStore from '@ohos.data.relationalStore'

@Entry
@Component
struct RDBPage {
  rdbStore?: relationalStore.RdbStore
  tableName?: string

  /**
   * 数据库建库建表
   */
  async createRDBStore() {
    // 1.创建或打开数据库 没有就去创建
    const context = this.getUIContext().getHostContext()
    const rdbStore = relationalStore.getRdbStoreSync(context, {name: 'interview_tong.db', securityLevel: relationalStore.SecurityLevel.S1})
    if (rdbStore) {
      rdbStore.executeSql(`
      CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          create_time INTEGER NOT NULL
        )
      `)
      this.rdbStore = rdbStore
    }
  }

  aboutToAppear(): void {
    this.createRDBStore()
  }

  build() {
    Column()
      .width('100%')
      .height('100%')
      .padding(20)
  }
}