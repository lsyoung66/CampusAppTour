package com.example.campus_app_tour
//import package:kakao_flutter_sdk/all.dart
import com.kakao.sdk.common.KakaoSdk
import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        KakaoSdk.init(this, "80ea3338e9a04d2545af91f8a36730f4")
    }
}
