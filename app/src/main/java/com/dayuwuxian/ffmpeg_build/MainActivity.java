package com.dayuwuxian.ffmpeg_build;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.dayuwuxian.ffmpeg.FFmpegInvoker;

import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;
import static android.content.pm.PackageManager.PERMISSION_GRANTED;

/**
 * create on 2020/9/23 11:29
 *
 * @author luojie
 */
public class MainActivity extends AppCompatActivity {

    private TextView mConfigView;

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView tv = findViewById(R.id.tv_cpu_abi);
        tv.setText(getString(R.string.abi) + getCpuAbi());

        mConfigView = findViewById(R.id.tv_config_info);
        mConfigView.setMovementMethod(ScrollingMovementMethod.getInstance());

        requestPermission();
    }

    private void requestPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (checkSelfPermission(WRITE_EXTERNAL_STORAGE) != PERMISSION_GRANTED) {
                requestPermissions(new String[]{WRITE_EXTERNAL_STORAGE}, 0);
            }
        }
    }


    private String getCpuAbi() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return Build.CPU_ABI;
        } else {
            return Build.SUPPORTED_ABIS[0];
        }
    }

    public void getFFmpegConfigInfo(View view) {
        mConfigView.setText(getConfigInfo());
    }

    public void getFFmpegCodecInfo(View view) {
        mConfigView.setText(FFmpegInvoker.getAVCodecInfo());
    }

    public void getFFmpegFormatInfo(View view) {
        mConfigView.setText(FFmpegInvoker.getAVFormatInfo());
    }

    public void getFFmpegFilterInfo(View view) {
        mConfigView.setText(FFmpegInvoker.getAVFilterInfo());
    }

    private String getConfigInfo() {
        String configInfo = FFmpegInvoker.getConfigInfo();
        String[] configItems = configInfo.split(" ");
        StringBuilder configInfoBuilder = new StringBuilder();
        for (String config : configItems) {
            configInfoBuilder.append(config).append('\n');
        }
        return configInfoBuilder.toString();
    }

    public void toTestFFmpeg(View view) {
        TestActivity.open(this);
    }
}
