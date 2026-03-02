// entry/src/main/ets/utils/Logger.ets
import hilog from '@ohos.hilog';

// 1. 定义Logger接口（明确类型规范）
interface Logger {
  debug(message: string): void;
  info(message: string): void;
  error(message: string): void;
}

// 2. 定义日志常量
const DOMAIN_ID: number = 0x0000;
const TAG: string = 'BirdNetLite';

// 3. 定义类实现Logger接口（ArkTS推荐方式）
class LoggerImpl implements Logger {
  debug(message: string): void {
    hilog.debug(DOMAIN_ID, TAG, `[DEBUG] ${message}`);
  }

  info(message: string): void {
    hilog.info(DOMAIN_ID, TAG, `[INFO] ${message}`);
  }

  error(message: string): void {
    hilog.error(DOMAIN_ID, TAG, `[ERROR] ${message}`);
  }
}

// 4. 导出类的单例（其他文件直接导入使用）
const logger: Logger = new LoggerImpl();
export default logger;