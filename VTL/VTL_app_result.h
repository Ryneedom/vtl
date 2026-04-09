#ifndef _VTL_APP_RESULT_H
#define _VTL_APP_RESULT_H

#ifdef __cplusplus
extern "C"
{
#endif



typedef enum _VTL_AppResult 
{
    VTL_res_kOk = 0,
    VTL_res_kErr = -1,
    VTL_res_kInvalidParamErr = -2,
    VTL_res_kMemAllocErr = -3,
    VTL_res_kFileOpenErr = -4,
    VTL_res_kFileReadErr = -5,
    VTL_res_kFileWriteErr = -6,

    VTL_res_video_fs_r_kMissingFileErr = 1,
    VTL_res_video_fs_r_kFileIsBusyErr,

    VTL_res_video_fs_w_kFileIsBusyErr = 10,

    VTL_res_text_io_r_kInvalidArgument = 20,
    VTL_res_text_ms_w_kOutOfMemory = 30,

    /* добавлено из feature/impl-video-edit (видео-редактор Дмитрия) */
    VTL_res_ffmpeg_kFormatError,
    VTL_res_ffmpeg_kStreamError,
    VTL_res_ffmpeg_kCodecError,
    VTL_res_ffmpeg_kIOError,
    VTL_res_ffmpeg_kInitError,
    VTL_res_ffmpeg_kMemoryError,
    VTL_res_ffmpeg_kConversionError,
    VTL_res_kEncoderNeedsMoreFrames,
    VTL_res_kEncoderFlushComplete,

} VTL_AppResult;




#ifdef __cplusplus
}
#endif


#endif