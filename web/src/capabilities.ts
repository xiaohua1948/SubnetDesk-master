export type ProtocolVideoCodec = "vp9" | "h264" | "av1";

export interface SelectedVideoCodec {
  codec: string;
  protocol: ProtocolVideoCodec;
}

export type CodecSupportProbe = (codec: string) => Promise<boolean>;

const VIDEO_CODEC_CANDIDATES: readonly SelectedVideoCodec[] = [
  { codec: "vp09.00.10.08", protocol: "vp9" },
  { codec: "avc1.42001f", protocol: "h264" },
  { codec: "av01.0.04M.08", protocol: "av1" },
];

export async function chooseVideoCodec(
  probe: CodecSupportProbe,
): Promise<SelectedVideoCodec | undefined> {
  for (const candidate of VIDEO_CODEC_CANDIDATES) {
    if (await probe(candidate.codec)) return candidate;
  }
  return undefined;
}

export interface PointerSample {
  clientX: number;
  clientY: number;
  button: number;
  buttons: number;
  altKey: boolean;
  ctrlKey: boolean;
  shiftKey: boolean;
  metaKey: boolean;
}

export function initialPointerSample(): PointerSample | undefined {
  return undefined;
}

export function coalescePointerSample(
  _previous: PointerSample | undefined,
  next: PointerSample,
): PointerSample {
  return { ...next };
}
