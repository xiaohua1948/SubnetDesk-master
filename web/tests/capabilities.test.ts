import { describe, expect, test } from "bun:test";
import {
  chooseVideoCodec,
  coalescePointerSample,
  initialPointerSample,
  type CodecSupportProbe,
} from "../src/capabilities";

describe("browser capability negotiation", () => {
  test("chooses the first codec that the browser can actually decode", async () => {
    const supported = new Set(["avc1.42001f"]);
    const probe: CodecSupportProbe = async (codec) => supported.has(codec);
    expect(await chooseVideoCodec(probe)).toEqual({
      codec: "avc1.42001f",
      protocol: "h264",
    });
  });

  test("reports no codec instead of assuming VP9 from WebCodecs presence", async () => {
    const probe: CodecSupportProbe = async () => false;
    expect(await chooseVideoCodec(probe)).toBeUndefined();
  });
});

describe("pointer input coalescing", () => {
  test("keeps the newest position while preserving button and modifier state", () => {
    let sample = initialPointerSample();
    sample = coalescePointerSample(sample, {
      clientX: 10,
      clientY: 20,
      button: 0,
      buttons: 1,
      altKey: false,
      ctrlKey: true,
      shiftKey: false,
      metaKey: false,
    });
    sample = coalescePointerSample(sample, {
      clientX: 30,
      clientY: 40,
      button: 0,
      buttons: 1,
      altKey: false,
      ctrlKey: true,
      shiftKey: true,
      metaKey: false,
    });
    expect(sample?.clientX).toBe(30);
    expect(sample?.clientY).toBe(40);
    expect(sample?.buttons).toBe(1);
    expect(sample?.ctrlKey).toBe(true);
    expect(sample?.shiftKey).toBe(true);
  });
});
