export type WebLocale = "zh" | "en";

const messages = {
  zh: {
    title: "SubnetDesk Web",
    remoteAccess: "远程访问",
    username: "访问用户名",
    password: "访问密码",
    connect: "连接此电脑",
    initializing: "正在初始化…",
    fingerprint: "设备指纹：",
    firstTrust: "首次访问需要信任本机证书",
    trustHelp: "请核对下方设备指纹，并将本机 CA 安装到受信任证书存储。",
    downloadCa: "下载本机 CA 证书",
    fullscreen: "全屏",
    disconnect: "断开",
    sendText: "发送文字",
    textPlaceholder: "输入文字或使用输入法",
    deviceLoading: "正在读取设备…",
    connected: "已连接",
    display: "显示器",
    quality: "画质",
    smooth: "流畅",
    balanced: "均衡",
    best: "最佳",
    pasteRemote: "粘贴到远端",
    copyRemote: "复制远端内容",
    screen: "远程桌面",
    disconnected: "已断开",
    remoteDisconnected: "远端已断开",
    connectionClosed: "连接已关闭",
    connectionFailed: "连接失败",
    connecting: "正在连接…",
    networkFailed: "网络连接失败",
    verifyingIdentity: "正在校验设备身份…",
    secureChannel: "安全通道已建立，正在认证…",
    enterCredentials: "请输入访问用户名和密码",
    passwordTooLong: "密码过长",
    httpsEnabled: "HTTPS 已启用",
    insecureHttp: "警告：当前使用未加密 HTTP",
    cannotReadDeviceInfo: "无法读取设备信息",
    clipboardReadPermission: "浏览器需要剪贴板读取权限",
    clipboardWritePermission: "浏览器需要剪贴板写入权限",
    remoteClipboardPermission: "已收到远端剪贴板；浏览器需要写入权限",
    noCodec: "浏览器没有可用的视频解码器",
    noDisplay: "远端没有活动显示器；请连接显示器或在 Windows Server 安装并启用虚拟显示器驱动",
    canvasUnavailable: "浏览器无法创建画布",
    decoderFailed: "视频解码失败",
    decoderRecovering: "视频解码异常，正在重建解码器并请求关键帧",
    webCodecsUnsupported: "当前浏览器不支持 WebCodecs，请使用最新版 Chrome 或 Edge",
    codecUnsupported: "浏览器不支持主机提供的视频编码，请更新浏览器或启用硬件解码",
    unknownError: "未知错误",
  },
  en: {
    title: "SubnetDesk Web",
    remoteAccess: "Remote access to",
    username: "Access username",
    password: "Access password",
    connect: "Connect to this computer",
    initializing: "Initializing…",
    fingerprint: "Device fingerprint:",
    firstTrust: "Trust this computer before first use",
    trustHelp:
      "Verify the device fingerprint below, then install the local CA in your trusted certificate store.",
    downloadCa: "Download local CA certificate",
    fullscreen: "Fullscreen",
    disconnect: "Disconnect",
    sendText: "Send text",
    textPlaceholder: "Type text or use an input method",
    deviceLoading: "Reading device…",
    connected: "Connected",
    display: "Display",
    quality: "Quality",
    smooth: "Smooth",
    balanced: "Balanced",
    best: "Best",
    pasteRemote: "Paste to remote",
    copyRemote: "Copy remote content",
    screen: "Remote desktop",
    disconnected: "Disconnected",
    remoteDisconnected: "The remote computer disconnected",
    connectionClosed: "Connection closed",
    connectionFailed: "Connection failed",
    connecting: "Connecting…",
    networkFailed: "Network connection failed",
    verifyingIdentity: "Verifying device identity…",
    secureChannel: "Secure channel established; authenticating…",
    enterCredentials: "Enter the access username and password",
    passwordTooLong: "Password is too long",
    httpsEnabled: "HTTPS enabled",
    insecureHttp: "Warning: HTTP is not encrypted",
    cannotReadDeviceInfo: "Unable to read device information",
    clipboardReadPermission: "Browser clipboard read permission is required",
    clipboardWritePermission: "Browser clipboard write permission is required",
    remoteClipboardPermission:
      "Remote clipboard received; browser clipboard write permission is required",
    noCodec: "No supported browser video decoder is available",
    noDisplay:
      "The remote computer has no active display; connect a monitor or install and enable a virtual display driver on Windows Server",
    canvasUnavailable: "The browser could not create the display canvas",
    decoderFailed: "Video decoding failed",
    decoderRecovering: "Video decoding failed; rebuilding the decoder and requesting a key frame",
    webCodecsUnsupported:
      "This browser does not support WebCodecs; use the latest Chrome or Edge",
    codecUnsupported:
      "The browser cannot decode a host-provided video codec; update the browser or enable hardware decoding",
    unknownError: "Unknown error",
  },
} as const;

export type TranslationKey = keyof typeof messages.en;

export function resolveLocale(language: string): WebLocale {
  return language.toLowerCase().startsWith("zh") ? "zh" : "en";
}

export function translate(locale: WebLocale, key: TranslationKey): string {
  return messages[locale][key];
}

export function localizeDocument(
  root: ParentNode = document,
  language = navigator.language,
): WebLocale {
  const locale = resolveLocale(language);
  document.documentElement.lang = locale === "zh" ? "zh-CN" : "en";
  for (const element of root.querySelectorAll<HTMLElement>("[data-i18n]")) {
    const key = element.dataset.i18n as TranslationKey | undefined;
    if (key && key in messages[locale]) element.textContent = translate(locale, key);
  }
  for (const element of root.querySelectorAll<HTMLInputElement>("[data-i18n-placeholder]")) {
    const key = element.dataset.i18nPlaceholder as TranslationKey | undefined;
    if (key && key in messages[locale]) element.placeholder = translate(locale, key);
  }
  for (const element of root.querySelectorAll<HTMLElement>("[data-i18n-aria-label]")) {
    const key = element.dataset.i18nAriaLabel as TranslationKey | undefined;
    if (key && key in messages[locale]) element.setAttribute("aria-label", translate(locale, key));
  }
  return locale;
}
