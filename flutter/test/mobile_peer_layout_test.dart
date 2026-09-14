import 'package:flutter_hbb/common/widgets/responsive_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile peer layout stays compact in both orientations', () {
    expect(
      shouldUseCompactPeerLayout(
        isMobilePlatform: true,
        isWebMobile: false,
        isPortrait: false,
      ),
      isTrue,
    );
    expect(
      shouldUseCompactPeerLayout(
        isMobilePlatform: false,
        isWebMobile: true,
        isPortrait: false,
      ),
      isTrue,
    );
  });

  test('desktop peer layout can use the landscape grid', () {
    expect(
      shouldUseCompactPeerLayout(
        isMobilePlatform: false,
        isWebMobile: false,
        isPortrait: false,
      ),
      isFalse,
    );
    expect(
      shouldUseCompactPeerLayout(
        isMobilePlatform: false,
        isWebMobile: false,
        isPortrait: true,
      ),
      isTrue,
    );
  });
}
