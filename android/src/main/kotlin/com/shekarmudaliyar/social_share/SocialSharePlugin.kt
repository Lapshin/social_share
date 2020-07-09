package com.shekarmudaliyar.social_share

import android.app.Activity
import android.content.*
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat.startActivity
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File


/** SocialSharePlugin */
class SocialSharePlugin(private val registrar: Registrar):  MethodCallHandler {

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "social_share")
      channel.setMethodCallHandler(SocialSharePlugin(registrar))
    }
  }
  @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
      if (call.method == "shareFile") {
          val filePath: String? = call.argument("filePath")
          val intentType: String? = call.argument("intentType")
          val file = filePath?.let { File(it) }
//          val file = File(path)
          val fileURI = file?.let {FileProvider.getUriForFile(registrar.activeContext(), registrar.activeContext().applicationContext.packageName + ".com.shekarmudaliyar.social_share", file)}
          val intent = Intent(Intent.ACTION_SEND)
          intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
          intent.setType(intentType)
          intent.putExtra(Intent.EXTRA_STREAM, fileURI)
          Log.d("", registrar.activity().toString())
          // Instantiate activity and verify it will resolve implicit intent
          val activity: Activity = registrar.activity()
          activity.grantUriPermission("com.instagram.android", fileURI, Intent.FLAG_GRANT_READ_URI_PERMISSION)
          if (activity.packageManager.resolveActivity(intent, 0) != null) {
              registrar.activeContext().startActivity(intent)
              result.success("success")
          } else {
              result.success("error")
          }
      }
      else if(call.method == "checkInstalledApp"){
          val appName: String? = call.argument("app")
          //assigning package manager
          val pm: PackageManager = registrar.context().packageManager
          //get a list of installed apps.
          val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)

          appName?.let {result.success(packages.any  {it.packageName.toString().contentEquals(appName)  })}
//          result.success(false)
          } else {
          result.notImplemented()
      }
  }
}
