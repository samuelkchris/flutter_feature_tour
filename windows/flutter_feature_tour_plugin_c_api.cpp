#include "include/flutter_feature_tour/flutter_feature_tour_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_feature_tour_plugin.h"

void FlutterFeatureTourPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_feature_tour::FlutterFeatureTourPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
