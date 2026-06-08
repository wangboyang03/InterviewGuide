import { relationalStore, ValuesBucket } from "@kit.ArkData";
import { Context } from "@ohos.abilityAccessCtrl";
import { Constants } from "../Constants";

export interface InterviewAudioItem extends ValuesBucket {
  id: number | null
  user_id: string
  name: string
  path: string
  duration: number
  size: number
  create_time: number
}

export class AudioDataBaseStorage {
  private static sInstance: AudioDataBaseStorage;
  store?: relationalStore.RdbStore
  tableName = 'interview_audio'

  private constructor() {}

  public static getInstance(): AudioDataBaseStorage {
    if (!AudioDataBaseStorage.sInstance) {
      AudioDataBaseStorage.sInstance = new AudioDataBaseStorage();
    }
    return AudioDataBaseStorage.sInstance;
  }

  // 初始化数据库
  async initStore() {
    try {
      const context = AppStorage.get<Context>(Constants.GLOBAL_CONTEXT)
      if (context) {
        const store = await relationalStore.getRdbStore(context, {
          name: 'interview_audio.db',
          securityLevel: relationalStore.SecurityLevel.S1
        })
        await store.executeSql(`
        CREATE TABLE IF NOT EXISTS ${this.tableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          path TEXT NOT NULL,
          duration INTEGER NOT NULL,
          size INTEGER NOT NULL,
          create_time INTEGER NOT NULL
        )
      `)
        this.store = store
      }
    } catch (e) {
    }
  }

  // 添加
  async insert(item: InterviewAudioItem) {
    try {
      const rowId = await this.store?.insert(this.tableName, item)
      if (rowId == undefined || rowId == -1) {
        return Promise.reject('插入失败')
      } else {
        return Promise.resolve()
      }
    } catch (e) {
    }
  }

  // 修改
  async update(item: InterviewAudioItem) {
    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName)
      predicates.equalTo('id', item.id)
      const rowCount = await this.store?.update(item, predicates)
      if (rowCount == undefined || rowCount <= 0) {
        return Promise.reject('修改失败')
      } else {
        return Promise.resolve()
      }
    } catch (e) {
    }
  }

  // 查询用户
  async query(userId: string) {
    try {
      const predicates = new relationalStore.RdbPredicates(this.tableName)
      predicates.equalTo('user_id', userId)
      const resultSet = await this.store?.query(predicates)
      if (!resultSet) {
        return Promise.reject('查询失败')
      }
      const list: InterviewAudioItem[] = []
      while (resultSet.goToNextRow()) {
        list.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          user_id: resultSet.getString(resultSet.getColumnIndex('user_id')),
          name: resultSet.getString(resultSet.getColumnIndex('name')),
          path: resultSet.getString(resultSet.getColumnIndex('path')),
          duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
          size: resultSet.getLong(resultSet.getColumnIndex('size')),
          create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
        })
      }
      resultSet.close()
      return Promise.resolve(list)
    } catch (e) {
      return Promise.reject('出现错误')
    }
  }
}