#ifndef FLUTTER_PLUGIN_FLUTTER_FEATURE_TOUR_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_FEATURE_TOUR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_feature_tour {

class FlutterFeatureTourPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterFeatureTourPlugin();

  virtual ~FlutterFeatureTourPlugin();

  // Disallow copy and assign.
  FlutterFeatureTourPlugin(const FlutterFeatureTourPlugin&) = delete;
  FlutterFeatureTourPlugin& operator=(const FlutterFeatureTourPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_feature_tour

#endif  // FLUTTER_PLUGIN_FLUTTER_FEATURE_TOUR_PLUGIN_H_
