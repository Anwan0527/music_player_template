import audio from '@ohos.multimedia.audio';
import { BusinessError } from '@kit.BasicServicesKit'
import fs from '@ohos.file.fs';

export default class AudioRender {
  //   属性
  //   1.播放器
  static renderer: audio.AudioRenderer = {} as audio.AudioRenderer
  static audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
    channels: audio.AudioChannel.CHANNEL_1,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  }
  static audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION, // 音频流使用类型
    rendererFlags: 0 // 音频渲染器标志
  }
  static audioRendererOptions: audio.AudioRendererOptions = {
    streamInfo: AudioRender.audioStreamInfo,
    rendererInfo: AudioRender.audioRendererInfo
  }

  static async init() {
    audio.createAudioRenderer(AudioRender.audioRendererOptions, (err: BusinessError, renderer: audio.AudioRenderer) => { // 创建AudioRenderer实例
      AudioRender.renderer = renderer;
    });
  }

  // 2.单曲播放
  static async play(filePath: string) {
    AudioRender.renderer.setVolume(1)
    await AudioRender.renderer.start()
    const bufferSize = await (AudioRender.renderer as audio.AudioRenderer).getBufferSize();
    let file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
    let stat = await fs.stat(filePath);
    let buf = new ArrayBuffer(bufferSize);
    let len = stat.size % bufferSize === 0 ? Math.floor(stat.size / bufferSize) : Math.floor(stat.size / bufferSize + 1);
    class Options {
      offset: number = 0;
      length: number = 0
    }
    for (let i = 0; i < len; i++) {
      let options: Options = {
        offset: i * bufferSize,
        length: bufferSize
      };
      let readsize = await fs.read(file.fd, buf, options);
      // buf是要写入缓冲区的音频数据，在调用AudioRenderer.write()方法前可以进行音频数据的预处理，实现个性化的音频播放功能，AudioRenderer会读出写入缓冲区的音频数据进行渲染
      let writeSize: number = await (AudioRender.renderer as audio.AudioRenderer).write(buf);
      if ((AudioRender.renderer as audio.AudioRenderer).state.valueOf() === audio.AudioState.STATE_RELEASED) { // 如果渲染器状态为released，关闭资源
        fs.close(file);
      }
      if ((AudioRender.renderer as audio.AudioRenderer).state.valueOf() === audio.AudioState.STATE_RUNNING) {
        if (i === len - 1) { // 如果音频文件已经被读取完，停止渲染
          fs.close(file);
          await (AudioRender.renderer as audio.AudioRenderer).stop();
        }
      }
    }
  }

  static async playBuffer(bufferSize: number, buffer: ArrayBuffer) {
    await fs.read(0, buffer, {
      offset: bufferSize,
      length: bufferSize
    })
    await (AudioRender.renderer as audio.AudioRenderer).write(buffer);
  }

  static stop() {
    AudioRender.renderer.stop()
  }
  static pause() {
    AudioRender.renderer.pause()
  }
}