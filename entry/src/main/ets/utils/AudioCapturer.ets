import { audio } from '@kit.AudioKit'
import AudioRender from './AudioRender'
import AVPlayerClass from './AVPlayerClass'
import { Context } from '@kit.AbilityKit'
import { fileIo } from '@kit.CoreFileKit'
import { emitter } from '@kit.BasicServicesKit'

const calc = (pcm: ArrayBuffer) => {
  let sum = 0;
  const pcmView = new DataView(pcm)
  const numSamples = pcm.byteLength / 2
  for (let i = 0; i < pcm.byteLength; i += 2) {
    const samples = pcmView.getInt16(i, true)
    sum += samples * samples
  }
  // 平均振幅
  const meanSquare = sum / numSamples
  // 计算RMS（均方根）振幅
  const rmsAmplitude = Math.sqrt(meanSquare);
  // 计算分贝
  const decibels = 20 * Math.log10(rmsAmplitude / 32767);
  return decibels;
}

export default class AudioCapturer {
  static audioCapturer: audio.AudioCapturer = {} as audio.AudioCapturer
  static bgmCapturer: audio.AudioCapturer = {} as audio.AudioCapturer
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }
  static audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_VOICE_COMMUNICATION, // 麦克风
    capturerFlags: 0 // 音频采集器标志
  }
  static bgmCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_PLAYBACK_CAPTURE, // 背景音乐
    capturerFlags: 0 // 音频采集器标志
  }
  static isCapturer: boolean = false
  static filePath: string = ''
  static init() {
    audio.createAudioCapturer({
      streamInfo: AudioCapturer.audioStreamInfo,
      capturerInfo: AudioCapturer.audioCapturerInfo,
    }, (err, capturer) => { // 创建AudioCapturer实例
      if (err) {
        console.error(`Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      AudioCapturer.audioCapturer = capturer;
    });
    audio.createAudioCapturer({
      streamInfo: AudioCapturer.audioStreamInfo,
      capturerInfo: AudioCapturer.bgmCapturerInfo,
    }, (err, capturer) => { // 创建AudioCapturer实例
      if (err) {
        console.error(`Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      AudioCapturer.bgmCapturer = capturer;
    });
  }

  static async start(src: string, context: Context) {
    AudioCapturer.isCapturer = true
    await AVPlayerClass.changePlay(src)
    await AudioCapturer.bgmCapturer.start()
    await AudioCapturer.audioCapturer.start()
    // 流播放
    // while (AudioCapturer.isCapturer) {
    //   let bufferSize = await AudioCapturer.audioCapturer.getBufferSize();
    //   let buffer = await AudioCapturer.audioCapturer.read(bufferSize, true);
    //   AudioRender.playBuffer(bufferSize, buffer)
    // }
    AudioCapturer.saveFile(src, context)
  }
  static async restart(src: string, context: Context){
    await AudioCapturer.audioCapturer.stop()
    await AudioCapturer.bgmCapturer.stop()
    await AVPlayerClass.player.stop()
    AVPlayerClass.time = 0
    AudioCapturer.start(src,context)
  }
  static async saveFile(src: string, context: Context) {
    // 存文件形式播放
    AudioCapturer.filePath = context.cacheDir + '/test.m4a'; // 采集到的音频文件存储路径
    let file: fileIo.File = fileIo.openSync(AudioCapturer.filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE); // 如果文件不存在则创建文件
    let fd = file.fd;
    let count = 0
    while (AudioCapturer.isCapturer) {
      // 写入文件
      let bufferSize = await AudioCapturer.audioCapturer.getBufferSize();
      let buffer = await AudioCapturer.audioCapturer.read(bufferSize, true);
      let bufferBgm = await AudioCapturer.bgmCapturer.read(bufferSize, true);
      let db = calc(buffer)
      // 处理两段buffer
      const buffer1 = new Int16Array(buffer)
      const buffer2 = new Int16Array(bufferBgm)
      const newBufferArray = new Int16Array(bufferSize)
      for(let i = 0;i<newBufferArray.byteLength;i+=2){
        let sample1 = buffer1[i];
        let sample2 = buffer2[i];
        let mixedSample =  (sample1 * 0.3 + sample2 * 3)*10  // 加权混合
        mixedSample = Math.max(-32768, Math.min(32767, mixedSample)); // 对于16位数据，确保在-32768到32767之间
        newBufferArray[i] = mixedSample
      }
      // 将混合后的16位数据转换回ArrayBuffer
      let mixedBufferArray = newBufferArray.buffer.slice(0);
      count++
      fileIo.writeSync(fd, mixedBufferArray, {offset: count * bufferSize,length:bufferSize});
      if (!isFinite(db) || db < -60) {
        db = -60
      }
      emitter.emit({
        eventId: 1
      }, {
        data: {
          avr: db + 65
        }
      })
    }
  }

  static async stop() {
    if (AudioCapturer.audioCapturer !== undefined) {
      // 只有采集器状态为STATE_RUNNING或STATE_PAUSED的时候才可以停止
      if ((AudioCapturer.audioCapturer as audio.AudioCapturer).state.valueOf() !== audio.AudioState.STATE_RUNNING && (AudioCapturer.audioCapturer as audio.AudioCapturer).state.valueOf() !== audio.AudioState.STATE_PAUSED) {
        console.info('Capturer is not running or paused');
        return;
      }
      AudioCapturer.isCapturer = false
      await (AudioCapturer.audioCapturer as audio.AudioCapturer).stop(); // 停止采集
      AVPlayerClass.player.stop()
      await AudioRender.stop()
    }
  }
}

class Options {
  offset: number = 0
  length: number = 0
}