package com.atqs.prayer_time 

import android.os.Bundle
import androidx.core.view.WindowCompat // Bu kütüphaneyi kullanacağız
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)

        super.onCreate(savedInstanceState)
    }
}