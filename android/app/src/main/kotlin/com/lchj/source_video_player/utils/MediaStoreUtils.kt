package com.lchj.source_video_player.utils

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.database.Cursor
import android.provider.MediaStore
import com.lchj.source_video_player.model.VideoDirectoryModel
import java.io.File


object MediaStoreUtils {
    /**
     * 获取视频文件目录集合
     */
    @SuppressLint("Recycle")
    fun getVideoDirectoryList(contentResolver: ContentResolver) : List<VideoDirectoryModel> {
        var list: MutableList<VideoDirectoryModel> = mutableListOf()
        val dirMap: LinkedHashMap<String, VideoDirectoryModel> = linkedMapOf();
        val projection = arrayOf(MediaStore.Video.Media.DATA) // 选择需要的列，这里只需要DATA
        val selection = null // 如果没有特定的筛选条件，可以设置为null
        val selectionArgs = null // 对应的筛选条件参数
        val sortOrder = MediaStore.Video.Media.DEFAULT_SORT_ORDER // 排序方式
        val cursor : Cursor? = contentResolver.query(
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
            projection, selection,selectionArgs, sortOrder);

        if (cursor != null) {
            while (cursor.moveToNext()) {
                val path: String = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA))
                val parentFile: File? = File(path).parentFile
                if (parentFile != null && parentFile.exists()) {
                    val absolutePath: String = parentFile.absolutePath;
                    if (dirMap[absolutePath] == null) {
                        dirMap[absolutePath] =
                            VideoDirectoryModel(absolutePath, absolutePath.split("/").last(), 1)
                    } else {
                        dirMap[absolutePath]!!.fileNumber += 1
                    }
                }
            }

            list = ArrayList(dirMap.values);
        }
        return list;
    }
}