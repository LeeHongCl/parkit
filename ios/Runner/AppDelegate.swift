import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // TODO: Google Maps API 키를 발급받으면 아래에 채워 넣으세요.
    // 저장소에 커밋되는 파일이므로 실제 키는 여기에 직접 넣지 말고,
    // 별도의 gitignore된 xcconfig에서 읽어오는 방식으로 교체하는 것을 권장합니다.
    GMSServices.provideAPIKey("")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
