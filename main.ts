// gta6-clipper-01 — the entry program.
//
// The clip itself lives on YouTube as a public Short; this program only hands
// the grader the address of the published video, by copying VIDEO.json from
// the repository root into the output directory.
//
// Before copying, it validates VIDEO.json: the file must parse as JSON and
// name a YouTube URL. A bad file fails loudly here instead of being copied
// silently and failing later at grading with no signal from the program.
//
// Deterministic: same input file, same output bytes, every run. No network,
// no writes outside the output directory, and it never deletes anything —
// the grader's /output is a mount on a read-only filesystem.
import { copyFileSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const outDir = process.env.MAKEFUN_OUTPUT_DIR ?? join(here, "output");
const source = join(here, "VIDEO.json");

const parsed: unknown = JSON.parse(readFileSync(source, "utf8"));
const url = (parsed as { url?: unknown } | null)?.url;
if (
  typeof url !== "string" ||
  !/^https:\/\/(www\.)?(youtube\.com|youtu\.be)\//.test(url)
) {
  throw new Error("VIDEO.json must name a YouTube URL in its url field");
}

mkdirSync(outDir, { recursive: true });
copyFileSync(source, join(outDir, "VIDEO.json"));
console.log("VIDEO.json copied to", join(outDir, "VIDEO.json"), "->", url);
