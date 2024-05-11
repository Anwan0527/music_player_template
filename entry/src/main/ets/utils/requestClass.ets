import request from '@ohos.request';
import fileFs from '@ohos.file.fs';
import fs from '@ohos.file.fs';
class resultClass {
  fileName: string = ''
  formImages:Record<string, string | number> = {}
}

export class Http2BufferClass {
  static httpFile: string = ''
  static result: resultClass = {} as resultClass

  static get(httpFile: string, context: Context, callback: (result: resultClass) => void) {
    // 如果下载的地址一样，直接返回
    if (httpFile === Http2BufferClass.httpFile) {
      callback(Http2BufferClass.result)
    } else {
      Http2BufferClass.httpFile = httpFile
      let tempDir = context.getApplicationContext()
        .tempDir;
      let fileName = 'file' + Date.now()
      let tmpFile = tempDir + '/' + fileName;
      request.downloadFile(context, { url: Http2BufferClass.httpFile, filePath: tmpFile })
        .then(task => {
          task.on('complete', () => {
            let file: fileFs.File
            try {
              file = fs.openSync(tmpFile);
              let fileInfo : Record<string, string | number> = {}
              fileInfo[tmpFile] = file.fd
              Http2BufferClass.result ={
                // 名字必须是下载的路径
                fileName: tmpFile,
                formImages: fileInfo
              }
            } catch (e) {
              console.error('logData:', `openSync失败`);
            }
            callback(Http2BufferClass.result)
          })
          task.on('fail', () => {
            console.log('logData:', '第一次下载失败')
            request.downloadFile(context, { url: Http2BufferClass.httpFile, filePath: tmpFile })
              .then(task => {
                task.on('complete', () => {
                  let file: fileFs.File
                  try {
                    file = fs.openSync(tmpFile);
                    let fileInfo : Record<string, string | number> = {}
                    fileInfo[tmpFile] = file.fd
                    Http2BufferClass.result ={
                      // 名字必须是下载的路径
                      fileName: tmpFile,
                      formImages: fileInfo
                    }
                  } catch (e) {
                    console.error('logData:', `openSync失败`);
                  }

                  callback(Http2BufferClass.result)
                })
                task.on('fail', () => {
                  console.log('logData:', '第二次下载失败')
                });
              })
          })
        })
    }

  }
}