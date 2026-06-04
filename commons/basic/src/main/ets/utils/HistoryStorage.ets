import preferences from '@ohos.data.preferences'
import { Constants } from '../Constants';
import { Logger } from './Logger';

export class HistoryStorage {
  private static sInstance: HistoryStorage;
  private storage: preferences.Preferences | null = null; // 首选项对象

  private constructor() {}

  public static getInstance(): HistoryStorage {
    if (!HistoryStorage.sInstance) {
      HistoryStorage.sInstance = new HistoryStorage();
    }
    return HistoryStorage.sInstance;
  }

  getStorageSync() {
    try {
      if (!this.storage) {
        const context = AppStorage.get<Context>(Constants.GLOBAL_CONTEXT)
        this.storage = preferences.getPreferencesSync(context, { name: 'history'})
      }
    } catch (error) {
      Logger.error('getStorageSync', error)
    } finally {
      return this.storage
    }
  }

  setStorageSync(key: string) {
    try {
      this.getStorageSync()?.putSync(key, key)
      this.getStorageSync()?.flushSync()
    } catch (error) {
      // 日志.
    }
  }

  deleteStorageSyncFromKey(key: string) {
    try {
      this.getStorageSync()?.deleteSync(key)
      this.getStorageSync()?.flushSync()
    } catch (error) {
      // 日志.
    }
  }

  clearStorageSync() {
    try {
      this.getStorageSync()?.clearSync()
      this.getStorageSync()?.flushSync()
    } catch (error) {
      // 日志.
    }

  }

  getAllStorageSync() {
    try {
      const object = this.getStorageSync()?.getAllSync()
      if (!!object) {
        return Object.keys(object)
      }
      return []
    } catch (error) {
      // 日志.
      return []
    }
  }
}