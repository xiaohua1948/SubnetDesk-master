import { expect, test } from "bun:test";
import { localizeDocument, resolveLocale, translate } from "../src/i18n";

test("web client selects Chinese and English without depending on server locale", () => {
  expect(resolveLocale("zh-CN")).toBe("zh");
  expect(resolveLocale("en-US")).toBe("en");
  expect(resolveLocale("de-DE")).toBe("en");
  expect(translate("en", "connect")).toBe("Connect to this computer");
  expect(translate("zh", "connect")).toBe("连接此电脑");
});

test("web client localizes text, placeholders, accessibility labels, and document language", () => {
  const textElement = {
    dataset: { i18n: "connect" },
    textContent: "",
  };
  const inputElement = {
    dataset: { i18nPlaceholder: "textPlaceholder" },
    placeholder: "",
  };
  const ariaElement = {
    dataset: { i18nAriaLabel: "screen" },
    setAttribute(name: string, value: string) {
      if (name === "aria-label") this.ariaLabel = value;
    },
    ariaLabel: "",
  };
  const root = {
    querySelectorAll(selector: string) {
      if (selector === "[data-i18n]") return [textElement];
      if (selector === "[data-i18n-placeholder]") return [inputElement];
      if (selector === "[data-i18n-aria-label]") return [ariaElement];
      return [];
    },
  };
  const previousDocument = globalThis.document;
  Object.defineProperty(globalThis, "document", {
    configurable: true,
    value: { documentElement: { lang: "" } },
  });
  try {
    expect(localizeDocument(root as unknown as ParentNode, "en-US")).toBe("en");
    expect(textElement.textContent).toBe("Connect to this computer");
    expect(inputElement.placeholder).toBe("Type text or use an input method");
    expect(ariaElement.ariaLabel).toBe("Remote desktop");
    expect(document.documentElement.lang).toBe("en");
  } finally {
    Object.defineProperty(globalThis, "document", {
      configurable: true,
      value: previousDocument,
    });
  }
});
