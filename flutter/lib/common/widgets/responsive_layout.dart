bool shouldUseCompactPeerLayout({
  required bool isMobilePlatform,
  required bool isWebMobile,
  required bool isPortrait,
}) {
  return isMobilePlatform || isWebMobile || isPortrait;
}
