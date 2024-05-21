package com.lchj.source_video_player.model

class VideoDirectoryModel(
    private var path: String,
    private var name: String,
    var fileNumber: Int
) {

    override fun toString(): String {
        return "VideoDirectoryModel(path='$path', name='$name', fileNumber=$fileNumber)"
    }
}