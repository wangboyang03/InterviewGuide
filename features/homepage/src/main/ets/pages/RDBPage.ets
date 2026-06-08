import { relationalStore, ValuesBucket } from '@kit.ArkData'

interface Article extends ValuesBucket {
  id: number
  title: string
  content: string
  create_time: number
}

@Entry
@Component
struct RDBPage {
  tableName = 'article'
  store?: relationalStore.RdbStore
  @State list: Article[] = []
  @State total: number = 0

  /**
   * 创建数据库表
   */
  async createStore() {
    try {
      // 1. 获取或创建数据库
      const ctx = this.getUIContext().getHostContext()!
      const store = await relationalStore.getRdbStore(ctx,
        { name: 'interview_tong.db', securityLevel: relationalStore.SecurityLevel.S1 })
      // 2. 执行SQL语句建表
      await store.executeSql(`
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          create_time INTEGER NOT NULL
        )
      `).catch(() => {
        this.getUIContext().getPromptAction().showToast({ message: '建表失败' })
      })
      // 3. 全局存储数据库
      this.store = store
      this.getUIContext().getPromptAction().showToast({ message: '数据库和表初始化成功' })
    } catch (e) {
      this.getUIContext().getPromptAction().showToast({ message: '建库失败' })
    }
  }

  /**
   * 增
   */
  insertData() {
    if (this.store) {
      this.store.insert(this.tableName, {
        id: null, // 自己自增
        title: `测试标题${Math.random()}}`,
        content: `测试文章内容${Math.random()}}`,
        create_time: Date.now()
      }).catch(() => {
        this.getUIContext().getPromptAction().showToast({ message: '插入失败' })
      })
      this.getUIContext().getPromptAction().showToast({ message: '插入成功' })
    } else {
      this.getUIContext().getPromptAction().showToast({ message: '数据库不存在' })
    }
  }

  /**
   * 查询总条数
   */
  async queryTotalCount() {
    if (this.store) {
      // 1. 创建查询的谓词对象
      const predicates = new relationalStore.RdbPredicates(this.tableName)
      // 2. 执行查询语句
      const res = await this.store.query(predicates).catch(() => {
      })
      // 3. 结果赋值
      this.total = res ? res.rowCount : 0
    } else {
      this.getUIContext().getPromptAction().showToast({ message: '查询失败' })
    }
  }

  /**
   * 查询所有数据
   */
  async queryData() {
    if (this.store) {
      try {
        // 1. 创建查询的谓词对象
        const predicates = new relationalStore.RdbPredicates(this.tableName)
        // 2. 执行查询语句
        const resultSet = await this.store.query(predicates).catch(() => {
        })
        // 3. 处理数据
        const list: Article[] = []
        if (resultSet) {
          while (resultSet.goToNextRow()) { // 如果可以去下一行，说明还有数据
            // const index = res.getColumnIndex('id')
            // const value = res.getLong(index)
            // const index2 = res.getColumnIndex('title')
            // const value2 = res.getString(index2)
            // hmLogger.info(`数据：${value}----${value2}`)
            list.push({
              id: resultSet.getLong(resultSet.getColumnIndex('id')),
              title: resultSet.getString(resultSet.getColumnIndex('title')),
              content: resultSet.getString(resultSet.getColumnIndex('content')),
              create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
            })
          }
          this.list = list
          resultSet.close()
        }

      } catch (e) {
        this.getUIContext().getPromptAction().showToast({ message: '查询失败' })
      }
    }
  }

  /**
   * 修改数据的方法
   * 继承类型解决类型不匹配问题
   */
  async updateDataFromList() {
    try {
      if (this.store) {
        // 1.先从列表中找到第一条数据
        const item = this.list[0]
        // 2.修改数据的字段
        item.title = `修改后的标题${Math.random()}修改后的标题`
        // 3.创建谓词对象
        const predicates = new relationalStore.RdbPredicates(this.tableName)
        predicates.equalTo('id', item.id) // 通过主键找到数据
        const res = await this.store.update(item, predicates)
        if (res == undefined || res == -1) {
          this.getUIContext().getPromptAction().showToast({ message: '修改失败' })
        }
        this.getUIContext().getPromptAction().showToast({ message: '修改成功' })
      }
    } catch (error) {
     // 日志。
    }
  }

  aboutToAppear(): void {
    this.createStore()
  }

  build() {
    Column() {
      Text(`总条数： ${this.total}`)
      Text('--------------------------')
      Text(JSON.stringify(this.list))
      Button('添加一条数据')
        .onClick(() => {
          this.insertData()
        })
      Button('查询总条数')
        .onClick(() => {
          this.queryTotalCount()
        })
      Button('查询所有数据')
        .onClick(() => {
          this.queryData()
        })
      Button('修改数据第一条')
        .onClick(() => {
          this.updateDataFromList()
        })
    }
    .padding({ top: 100 })
    .height('100%')
    .width('100%')
  }
}