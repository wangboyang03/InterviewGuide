import { User } from "../../models";
import { GlobalVariable } from "../constants";

export class HMAuth {
  private static sInstance: HMAuth

  private constructor() {
  } // 私有构造函数

  public static getInstance(): HMAuth {
    if (!HMAuth.sInstance) {
      HMAuth.sInstance = new HMAuth();
    }
    return HMAuth.sInstance;
  }
  // 初始化
  initUser() {
    PersistentStorage.persistProp(GlobalVariable.USER_KEY, {} as User)
  }
  // 获取
  getUser() {
    return AppStorage.get<User>(GlobalVariable.USER_KEY) ?? {} as User
  }
  // 设置
  setUser(user: User) {
    AppStorage.set<User>(GlobalVariable.USER_KEY, user)
  }
}