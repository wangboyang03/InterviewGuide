import { hilog } from "@kit.PerformanceAnalysisKit"
import { GlobalVariable } from "../constants"

// 定义接收的数据类型, 可以是: 字符串 | 数字 | 布尔
type LogArg = string | number | boolean | object | null | undefined

class HMLogger {

  private domain: number
  private prefix: string
  private format: string = '%{public}s'

  private formatBuilder(args: LogArg[]){
    // ['你好', 10] ==> ['%{public}s', '%{public}d'] ==> '%{public}s, %{public}d'
    return args.map((arg)=>{
      if(typeof arg === 'string'  || typeof arg === 'boolean' || arg === null || arg === undefined){
        return '%{public}s'
      } else if(typeof arg === 'number'){
        return '%{public}d'
      } else if(typeof arg === 'object'){
        return '%{public}o'
      } else {
        return '%{public}s'
      }
    }).join(', ')
  }


  constructor(domain: number = 0x0001, prefix: string = '') {
    this.domain = domain
    this.prefix = prefix
  }

  debug(...args: LogArg[]){
    this.format = this.formatBuilder(args)
    hilog.debug(this.domain, this.prefix, this.format, ...args)
  }

  info(...args: LogArg[]){
    this.format = this.formatBuilder(args)
    hilog.info(this.domain, this.prefix, this.format, ...args)
  }

  warn(...args: LogArg[]){
    this.format = this.formatBuilder(args)
    hilog.warn(this.domain, this.prefix, this.format, ...args)
  }

  error(...args: LogArg[]){
    this.format = this.formatBuilder(args)
    hilog.error(this.domain, this.prefix, this.format, ...args)
  }
}

export const hmLogger = new HMLogger(0x1234, GlobalVariable.LOG_PREFIX)
