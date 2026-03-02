import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';

export class AudioCapture {
  private static readonly AUDIO_STREAM_INFO: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  };

  private static readonly CAPTURER_INFO: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  };

  private static capturer: audio.AudioCapturer | null = null;
  private static file: fileIo.File | null = null;
  private static isRecordingInternal: boolean = false;

  /**
   * 开始录音
   */
  public static async start(filePath: string): Promise<void> {
    if (AudioCapture.isRecordingInternal) {
      return;
    }

    try {
      console.info('AudioCapture', '开始启动...');

      // 1. 打开文件
      AudioCapture.file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);

      // 2. 创建采集器
      AudioCapture.capturer = await audio.createAudioCapturer({
        streamInfo: AudioCapture.AUDIO_STREAM_INFO,
        capturerInfo: AudioCapture.CAPTURER_INFO
      });

      // 3. 注册数据回调（有数据就写，没数据就等着）
      AudioCapture.capturer.on('readData', (buffer: ArrayBuffer) => {
        if (AudioCapture.isRecordingInternal && AudioCapture.file !== null) {
          try {
            if (buffer.byteLength > 0) {
              fileIo.writeSync(AudioCapture.file.fd, buffer);
            }
          } catch (e) {
            console.warn('AudioCapture', '写入一次失败，忽略继续');
          }
        }
      });

      // 4. 启动
      AudioCapture.isRecordingInternal = true;
      await AudioCapture.capturer.start();
      console.info('AudioCapture', '录音启动成功！');

    } catch (error) {
      console.error('AudioCapture', '启动异常：', JSON.stringify(error));
      AudioCapture.cleanup();
      throw new Error('录音启动失败');
    }
  }

  /**
   * 停止录音
   */
  public static async stop(): Promise<void> {
    console.info('AudioCapture', '收到停止指令');
    AudioCapture.isRecordingInternal = false;

    // 稍微等待一下，确保最后一点数据写入
    setTimeout(async () => {
      if (AudioCapture.capturer !== null) {
        try {
          AudioCapture.capturer.off('readData');
          if (Number(AudioCapture.capturer.state) === Number(audio.AudioState.STATE_RUNNING)) {
            await AudioCapture.capturer.stop();
          }
        } catch (e) {
          console.warn('AudioCapture', '停止状态异常');
        }
      }
      AudioCapture.cleanup();
    }, 200);
  }

  /**
   * 清理资源
   */
  private static cleanup(): void {
    if (AudioCapture.file !== null) {
      try {
        fileIo.closeSync(AudioCapture.file.fd);
      } catch (e) {
        // ignore
      }
      AudioCapture.file = null;
    }

    if (AudioCapture.capturer !== null) {
      try {
        AudioCapture.capturer.release();
      } catch (e) {
        // ignore
      }
      AudioCapture.capturer = null;
    }
    console.info('AudioCapture', '资源清理完毕');
  }

  public static async release(): Promise<void> {
    AudioCapture.isRecordingInternal = false;
    AudioCapture.cleanup();
  }
}