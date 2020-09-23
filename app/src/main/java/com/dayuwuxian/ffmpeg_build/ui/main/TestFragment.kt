package com.dayuwuxian.ffmpeg_build.ui.main

import android.app.ProgressDialog
import android.os.Bundle
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProviders
import com.dayuwuxian.ffmpeg.FFmpegCmd
import com.dayuwuxian.ffmpeg.FFmpegInvoker
import com.dayuwuxian.ffmpeg_build.R
import kotlinx.android.synthetic.main.main_fragment.*

class TestFragment : Fragment() {

    private var mProgressDialog: ProgressDialog? = null

    private val videoPath = "sdcard/ffmpeg/video.mp4"

    private val mCallback: FFmpegInvoker.Callback = object : FFmpegInvoker.Callback {
        override fun onSuccess() {
            Looper.prepare()
            hideProgress()
            Toast.makeText(activity, "处理成功", Toast.LENGTH_SHORT).show()
            Looper.loop()
        }

        override fun onFailure() {
            Looper.prepare()
            hideProgress()
            Toast.makeText(activity, "处理失败", Toast.LENGTH_SHORT).show()
            Looper.loop()
        }

        override fun onProgress(percent: Float) {
            updateProgress(percent)
        }
    }

    companion object {
        fun newInstance() = TestFragment()
    }

    private lateinit var viewModel: MainViewModel

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return inflater.inflate(R.layout.main_fragment, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProviders.of(this).get(MainViewModel::class.java)
        btn_cut.setOnClickListener {
            showProgress()
            val savePath = "sdcard/ffmpeg/out.mp4"
            val cmd = FFmpegCmd()
            cmd.append("-ss").append(1)
            cmd.append("-t").append(500)
            cmd.append("-accurate_seek")
            cmd.append("-i").append(videoPath)
            cmd.append("-codec").append("copy")
            cmd.append(savePath)
//        String cmd = "ffmpeg -y -ss 1 -t 500 -accurate_seek -i " + videoPath2 + " -codec copy " + savePath;
            FFmpegInvoker.exec(cmd.build(), mCallback)
        }

        btn_extract.setOnClickListener {
            //libshine
//            val cmd =
//                "ffmpeg-y -i sdcard/ffmpeg/video.mp4 -vn -acodec libmp3lame -ab 128K -ar 44100 -y mp3 sdcard/ffmpeg/video3.mp3";
//            val cmd = "ffmpeg-y -i sdcard/ffmpeg/video.mp4 -vn -acodec libmp3lame -q:a 4 -y -f mp3 sdcard/ffmpeg/video3.mp3"
            val cmd = "ffmpeg -i sdcard/ffmpeg/video.mp4 -map 0:a -acodec libmp3lame sdcard/ffmpeg/out.mp3"
            FFmpegInvoker.exec(cmd, mCallback)
        }
    }


    private fun showProgress() {
        if (mProgressDialog == null) {
            mProgressDialog = ProgressDialog(activity)
            mProgressDialog?.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL)
            mProgressDialog?.setCanceledOnTouchOutside(false)
            mProgressDialog?.max = 100
            mProgressDialog?.setTitle("正在处理")
        }
        mProgressDialog?.progress = 0
        mProgressDialog?.show()
    }

    private fun hideProgress() {
        if (mProgressDialog != null) {
            activity?.runOnUiThread { mProgressDialog!!.hide() }
        }
    }

    private fun updateProgress(percent: Float) {
        mProgressDialog ?: return
        mProgressDialog?.progress = (percent * mProgressDialog!!.max).toInt()
    }

}