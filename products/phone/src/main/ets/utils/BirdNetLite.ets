// entry/src/main/ets/utils/BirdNetLite.ets

// 使用鸿蒙原生的MindSpore Lite
import { mindSporeLite } from '@kit.MindSporeLiteKit';
import fs from '@ohos.file.fs';
import logger from './Logger';
import common from '@ohos.app.ability.common';

// 接口定义
interface TopResult {
  label: string;
  score: number;
}

interface ScoreItem {
  idx: number;
  score: number;
}

// 注意：需要将TFLite模型转换为MindSpore Lite格式(.ms)
// 转换工具：https://www.mindspore.cn/lite/docs/zh-CN/master/use/converter_tool.html
const MODEL_FILE: string = 'BirdNET_GLOBAL_6K_V2.4.ms'; // 转换后的模型
const LABEL_FILE: string = 'labels.txt';
const RAW_FILE_PATH: string = 'model/';

export class BirdNetLite {
  private msLiteModel: mindSporeLite.Model | null = null;
  private birdLabels: string[] = [];
  private readonly INPUT_SAMPLE_RATE: number = 48000;
  private readonly INPUT_DURATION: number = 3;
  private readonly INPUT_SIZE: number = this.INPUT_SAMPLE_RATE * this.INPUT_DURATION;

  private getContext(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  /**
   * 初始化：复制rawfile文件→加载模型→加载标签
   */
  async init(): Promise<boolean> {
    try {
      const context: common.UIAbilityContext = this.getContext();

      // 1. 复制模型和标签到应用私有目录
      await this.copyRawFileToAppDir(context, MODEL_FILE);
      await this.copyRawFileToAppDir(context, LABEL_FILE);

      // 2. 创建MindSpore Lite上下文
      const msContext: mindSporeLite.Context = {
        target: ['cpu'],
        cpu: {
          threadNum: 4,
          threadAffinityMode: 1,
          precisionMode: 'enforce_fp32'
        }
      };

      // 3. 从文件加载MindSpore Lite模型
      const modelPath: string = `${context.filesDir}/${MODEL_FILE}`;
      this.msLiteModel = await mindSporeLite.loadModelFromFile(modelPath, msContext);
      logger.info(`MindSpore Lite模型加载成功：${modelPath}`);

      // 4. 加载标签（修复apply问题）
      const labelPath: string = `${context.filesDir}/${LABEL_FILE}`;
      const labelFile: fs.File = fs.openSync(labelPath, fs.OpenMode.READ_ONLY);
      const labelBuffer: ArrayBuffer = new ArrayBuffer(1024 * 1024);
      const readLen: number = fs.readSync(labelFile.fd, labelBuffer);

      // 修复：使用循环代替apply
      const uint8Array = new Uint8Array(labelBuffer.slice(0, readLen));
      let labelContent: string = '';
      for (let i = 0; i < uint8Array.length; i++) {
        labelContent += String.fromCharCode(uint8Array[i]);
      }

      fs.closeSync(labelFile);

      this.birdLabels = labelContent.split('\n').filter((label: string) => label.trim() !== '');
      logger.info(`加载标签数：${this.birdLabels.length}`);

      return true;
    } catch (error) {
      logger.error(`初始化失败：${(error as Error).message}`);
      return false;
    }
  }

  /**
   * 核心识别方法
   */
  async recognizeBird(audioData: Float32Array): Promise<string> {
    if (!this.msLiteModel) {
      throw new Error('模型未初始化，请先调用init()');
    }

    try {
      // 音频预处理
      const processedAudio: Float32Array = this.preprocessAudio(audioData);

      // 获取模型输入并设置数据
      const modelInputs: mindSporeLite.MSTensor[] = this.msLiteModel.getInputs();

      // 将音频数据转为ArrayBuffer并设置到输入张量
      const inputBuffer = processedAudio.buffer;
      modelInputs[0].setData(inputBuffer);

      logger.info('开始执行MindSpore Lite推理...');

      // 执行推理
      const modelOutputs: mindSporeLite.MSTensor[] = await this.msLiteModel.predict(modelInputs);

      // 获取输出数据
      const outputData = new Float32Array(modelOutputs[0].getData());

      // 解析Top5结果
      const top5: TopResult[] = this.getTopResults(outputData, 5);

      // 格式化结果
      let result: string = '🦜 鸟类识别结果（Top5）：\n';
      top5.forEach((item: TopResult, idx: number) => {
        result += `${idx + 1}. ${item.label}（置信度：${(item.score * 100).toFixed(2)}%）\n`;
      });
      return result;
    } catch (error) {
      logger.error(`识别失败：${(error as Error).message}`);
      throw new Error(`识别失败：${(error as Error).message}`);
    }
  }

  /**
   * 音频预处理
   */
  private preprocessAudio(audioData: Float32Array): Float32Array {
    const processed: Float32Array = new Float32Array(this.INPUT_SIZE);

    // 裁剪/补零到3秒
    if (audioData.length >= this.INPUT_SIZE) {
      processed.set(audioData.subarray(0, this.INPUT_SIZE));
    } else {
      processed.set(audioData);
      processed.fill(0, audioData.length);
    }

    // 归一化
    const maxVal: number = Math.max(...processed.map(Math.abs));
    if (maxVal > 0) {
      processed.forEach((val: number, idx: number) => {
        processed[idx] = val / maxVal;
      });
    }
    return processed;
  }

  /**
   * 解析TopN结果
   */
  private getTopResults(output: Float32Array, topN: number): TopResult[] {
    const outputArray: number[] = Array.from(output);
    const scoreList: ScoreItem[] = outputArray
      .map((score: number, idx: number): ScoreItem => {
        return { idx, score };
      })
      .sort((a: ScoreItem, b: ScoreItem): number => b.score - a.score)
      .slice(0, topN);

    return scoreList.map((item: ScoreItem): TopResult => {
      return {
        label: this.birdLabels[item.idx] || `未知物种(${item.idx})`,
        score: item.score
      };
    });
  }

  /**
   * 复制rawfile到应用目录
   */
  private async copyRawFileToAppDir(context: common.UIAbilityContext, fileName: string): Promise<void> {
    const targetPath: string = `${context.filesDir}/${fileName}`;

    // 检查文件是否已存在
    try {
      fs.accessSync(targetPath);
      return;
    } catch (e) {
      // 文件不存在，继续复制
    }

    // 读取rawfile并写入
    const rawFileContent: Uint8Array = await context.resourceManager.getRawFileContent(`${RAW_FILE_PATH}${fileName}`);
    const file: fs.File = fs.openSync(targetPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
    fs.writeSync(file.fd, rawFileContent.buffer);
    fs.closeSync(file);

    logger.info(`复制文件完成：${fileName}`);
  }
}