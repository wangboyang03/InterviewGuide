import { Constants } from "../Constants";
import { ConfigurationConstant } from "@kit.AbilityKit";
import { Logger } from "./Logger";

export class ThemeUtil {
  private static sInstance: ThemeUtil;
  private constructor() {}

  /**
   * 获取单例实例
   * @returns ThemeUtil
   */
  public static getInstance(): ThemeUtil {
    if (ThemeUtil.sInstance == null) {
      ThemeUtil.sInstance = new ThemeUtil();
    }
    return ThemeUtil.sInstance;
  }

  /**
   * 初始化主题设置
   */
  initThemeSettings() {
    // 1.持久化存储
    PersistentStorage.persistProp(Constants.THEME_COLOR_KEY, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
    const themeColor = AppStorage.get<ConfigurationConstant.ColorMode>(Constants.THEME_COLOR_KEY)
    if (!!themeColor) {
      this.settingsTheme(themeColor)
    }
  }

  /**
   * 设置主题
   * @param colorMode 颜色模式
   */
  private settingsTheme(colorMode: ConfigurationConstant.ColorMode) {
    try {
      const context = AppStorage.get<Context>(Constants.GLOBAL_CONTEXT)
      if (!!context) {
        context.getApplicationContext().setColorMode(colorMode)
      }
      AppStorage.set(Constants.THEME_COLOR_KEY, colorMode)
    } catch (error) {
      Logger.error(`设置主题失败,${error}`)
    }
  }

  settingsFollowSystem() {
    this.settingsTheme(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET)
  }

  settingsLightMode() {
    this.settingsTheme(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)
  }

  settingsDarkMode() {
    this.settingsTheme(ConfigurationConstant.ColorMode.COLOR_MODE_DARK)
  }
}