import { Constants } from "../Constants";
import { UserResponse } from "../models";

export class Auth {
  private static sInstance: Auth;
  private constructor() {}

  public static getInstance(): Auth {
    if (!Auth.sInstance) {
      Auth.sInstance = new Auth();
    }
    return Auth.sInstance;
  }

  initUser() {
    PersistentStorage.persistProp<UserResponse>(Constants.USER_STORAGE_KEY, {} as UserResponse)
  }

  setUser(user: UserResponse) {
    AppStorage.setOrCreate(Constants.USER_STORAGE_KEY, user)
  }

  getUser() {
    return AppStorage.get<UserResponse>(Constants.USER_STORAGE_KEY)
  }
}