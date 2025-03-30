import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import AudioCapturer from './AudioCapturer';
const TAG = 'CoreSpeechKit';

class Audio {
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null;
  private mAudioCapturer = new AudioCapturer();
  sessionId: string = '0';
  recognizerParams: speechRecognizer.StartParams | null = null;
  private listeners: Map<string, Function> = new Map();

  initAudio() {
    // 设置创建引擎参数
    let extraParams: Record<string, Object> = { "locate": "CN", "recognizerMode": "short" }
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParams
    };
    speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine:
      speechRecognizer.SpeechRecognitionEngine) => {
      if (!err) {
        // 接收创建引擎的实例
        this.asrEngine = speechRecognitionEngine;
      } else {
        // 无法创建引擎时返回错误码1002200001，原因：语种不支持、模式不支持、初始化超时、资源不存在等导致创建引擎失败
        // 无法创建引擎时返回错误码1002200006，原因：引擎正在忙碌中，一般多个应用同时调用语音识别引擎时触发
        // 无法创建引擎时返回错误码1002200008，原因：引擎已被销毁
        console.error(`Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
      }
    })
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
    let extraParam: Record<string, Object> = {
      "recognitionMode": 0,
      "vadBegin": 2000,
      "vadEnd": 3000,
      "maxAudioDuration": 20000
    }
    this.recognizerParams = {
      sessionId: '1',
      audioInfo: audioParam,
      extraParams: extraParam
    }
  }
  public on(event: string, callback: Function): void {
    this.listeners.set(event, callback);
  }

  setListener(Result: Function) {
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart(sessionId: string, eventMessage: string) {
        console.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // 识别结果回调，包括中间结果和最终结果
      onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
        console.info(`onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
        const callback:Function = this.listeners.get('Result');
        if (callback && typeof callback === 'function') {
          callback(result.result);
        }
      },
      // 识别完成回调
      onComplete(sessionId: string, eventMessage: string) {
        console.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 错误回调，错误码通过本方法返回
      // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      },
    }
  }
  startListeningForRecording() {
    hilog.info(0x0000, TAG, 'startListening start');
    if (this.recognizerParams !== null) {
      this.asrEngine?.startListening(this.recognizerParams);
    }
  };
}
  //
  // // 查询语种信息，以callback形式返回
  // private queryLanguagesCallback() {
  //   // 设置查询相关参数
  //   let languageQuery: speechRecognizer.LanguageQuery = {
  //     sessionId: '1'
  //   };
  //   // 调用listLanguages方法
  //   this.asrEngine?.listLanguages(languageQuery, (err: BusinessError, languages: Array<string>) => {
  //     if (!err) {
  //       // 接收目前支持的语种信息
  //       hilog.info(0x0000, TAG, `Succeeded in listing languages, result: ${JSON.stringify(languages)}`);
  //     } else {
  //       hilog.error(0x0000, TAG, `Failed to create engine. Code: ${err.code}, message: ${err.message}.`);
  //     }
  //   });
  // };
  //
  // // 开始识别
  // private startListeningForWriteAudio() {
  //   // 设置开始识别的相关参数
  //   let recognizerParams: speechRecognizer.StartParams = {
  //     sessionId: '1',
  //     audioInfo: { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 } //audioInfo参数配置请参考AudioInfo
  //   }
  //   // 调用开始识别方法
  //   this.asrEngine?.startListening(recognizerParams);
  // };
  //
  // private startListeningForRecording() {
  //   let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
  //   let extraParam: Record<string, Object> = {
  //     "recognitionMode": 0,
  //     "vadBegin": 2000,
  //     "vadEnd": 3000,
  //     "maxAudioDuration": 20000
  //   }
  //   let recognizerParams: speechRecognizer.StartParams = {
  //     sessionId: '1',
  //     audioInfo: audioParam,
  //     extraParams: extraParam
  //   }
  //   hilog.info(0x0000, TAG, 'startListening start');
  //   this.asrEngine?.startListening(recognizerParams);
  // };
  //
  //
  // // 写音频流
  // private async writeAudio() {
  //   this.startListeningForWriteAudio();
  //   hilog.error(0x0000, TAG, `Failed to read from file. Code`);
  //   let ctx = getContext(this);
  //   let filenames: string[] = fileIo.listFileSync(ctx.filesDir);
  //   if (filenames.length <= 0) {
  //     hilog.error(0x0000, TAG, `Failed to read from file. Code`);
  //     return;
  //   }
  //   hilog.error(0x0000, TAG, `Failed to read from file. Code`);
  //   let filePath: string = `${ctx.filesDir}/${filenames[0]}`;
  //   let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE);
  //   try {
  //     let buf: ArrayBuffer = new ArrayBuffer(1280);
  //     let offset: number = 0;
  //     while (1280 == fileIo.readSync(file.fd, buf, {
  //       offset: offset
  //     })) {
  //       let uint8Array: Uint8Array = new Uint8Array(buf);
  //       this.asrEngine?.writeAudio('1', uint8Array);
  //       await this.countDownLatch(1);
  //       offset = offset + 1280;
  //     }
  //   } catch (err) {
  //     hilog.error(0x0000, TAG, `Failed to read from file. Code: ${err.code}, message: ${err.message}.`);
  //   } finally {
  //     if (null != file) {
  //       fileIo.closeSync(file);
  //     }
  //   }
  // }
  //
  // // 麦克风语音转文本
  // async startRecording() {
  //   this.startListeningForRecording();
  //   // 录音获取音频
  //   let data: ArrayBuffer;
  //   hilog.info(0x0000, TAG, 'create capture success');
  //   this.mAudioCapturer.init((dataBuffer: ArrayBuffer) => {
  //     hilog.info(0x0000, TAG, 'start write');
  //     hilog.info(0x0000, TAG, 'ArrayBuffer ' + JSON.stringify(dataBuffer));
  //     data = dataBuffer
  //     let uint8Array: Uint8Array = new Uint8Array(data);
  //     hilog.info(0x0000, TAG, 'ArrayBuffer uint8Array ' + JSON.stringify(uint8Array));
  //     // 写入音频流
  //     this.asrEngine?.writeAudio('2', uint8Array);
  //   });
  // };
  // // 计时
  // public async countDownLatch(count: number) {
  //   while (count > 0) {
  //     await this.sleep(40);
  //     count--;
  //   }
  // }
  // // 睡眠
  // private sleep(ms: number):Promise<void> {
  //   return new Promise(resolve => setTimeout(resolve, ms));
  // }
  //
  // // 设置回调
  // private setListener() {
  //   // 创建回调对象
  //   let setListener: speechRecognizer.RecognitionListener = {
  //     // 开始识别成功回调
  //     onStart(sessionId: string, eventMessage: string) {
  //       hilog.info(0x0000, TAG, `onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
  //     },
  //     // 事件回调
  //     onEvent(sessionId: string, eventCode: number, eventMessage: string) {
  //       hilog.info(0x0000, TAG, `onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
  //     },
  //     // 识别结果回调，包括中间结果和最终结果
  //     onResult(sessionId: string, result: speechRecognizer.SpeechRecognitionResult) {
  //       hilog.info(0x0000, TAG, `onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
  //     },
  //     // 识别完成回调
  //     onComplete(sessionId: string, eventMessage: string) {
  //       hilog.info(0x0000, TAG, `onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
  //     },
  //     // 错误回调，错误码通过本方法返回
  //     // 返回错误码1002200002，开始识别失败，重复启动startListening方法时触发
  //     // 更多错误码请参考错误码参考
  //     onError(sessionId: string, errorCode: number, errorMessage: string) {
  //       hilog.error(0x0000, TAG, `onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
  //     },
  //   }
  //   // 设置回调
  //   this.asrEngine?.setListener(setListener);
  // };
const audio = new Audio();
export { audio };
