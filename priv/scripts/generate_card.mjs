#!/usr/bin/env node

import sharp from "sharp";
import fs from "node:fs";

// ─────────────────────────────────────────────
// Arguments
// ─────────────────────────────────────────────

const [, , input, output = "rfid-card.png"] = process.argv;

if (!input) {
  console.error("Usage: node generate_card.mjs <input-image> [output.png]");
  process.exit(1);
}

if (!fs.existsSync(input)) {
  console.error(`Image not found: ${input}`);
  process.exit(1);
}

// ─────────────────────────────────────────────
// Card configuration
// ─────────────────────────────────────────────

// CR80 RFID card
// 53.98 × 85.60 mm
// ~300 DPI

const WIDTH = 638;
const HEIGHT = 1011;

// Height of the retro IVHS banner
const BANNER_HEIGHT = 145;
const bannerY = HEIGHT - BANNER_HEIGHT;

// Realistic RFID/card corner radius
const CORNER_RADIUS = 38;

const TAG_LINE = process.env.TAGLINE || "HOME ENTERTAINMENT";
const TAG_NAME = process.env.TAGNAME || "IVHS";

// ─────────────────────────────────────────────
// Retro color palette
// ─────────────────────────────────────────────

const COLORS = {
  background: "#17131C",
  purple: "#8B5A9F",
  salmon: "#F28C8C",
  cream: "#FFF1E6",
  pink: "#D9A3B8",
};

// ─────────────────────────────────────────────
// Load and crop artwork
// ─────────────────────────────────────────────
//
// "cover" makes the image fill the entire card.
// The image keeps its original aspect ratio and is
// cropped only as much as necessary.
//

const artwork = await sharp(input)
  .resize(WIDTH, HEIGHT, {
    fit: "cover",
    position: "centre",
  })
  .png()
  .toBuffer();

// ─────────────────────────────────────────────
// Retro IVHS overlay
// ─────────────────────────────────────────────

const overlay = Buffer.from(`
<svg
  width="${WIDTH}"
  height="${HEIGHT}"
  viewBox="0 0 ${WIDTH} ${HEIGHT}"
  xmlns="http://www.w3.org/2000/svg"
>

  <!-- Card clipping -->
  <defs>
    <clipPath id="card">
      <rect
        x="0"
        y="0"
        width="${WIDTH}"
        height="${HEIGHT}"
        rx="${CORNER_RADIUS}"
        ry="${CORNER_RADIUS}"
      />
    </clipPath>
  </defs>

  <g clip-path="url(#card)">

    <!-- ─────────────────────────────────── -->
    <!-- RETRO BANNER                    -->
    <!-- ─────────────────────────────────── -->

    <rect
      x="0"
      y="${bannerY}"
      width="${WIDTH}"
      height="${BANNER_HEIGHT}"
      fill="${COLORS.background}"
      fill-opacity="0.96"
    />

    <!-- Main purple stripe -->
    <rect
      x="0"
      y="${bannerY}"
      width="${WIDTH}"
      height="9"
      fill="${COLORS.purple}"
    />

    <!-- Cream separator -->
    <rect
      x="0"
      y="${bannerY + 9}"
      width="${WIDTH}"
      height="4"
      fill="${COLORS.cream}"
    />

    <!-- Salmon decorative blocks -->
    <rect
      x="0"
      y="${bannerY + 13}"
      width="72"
      height="6"
      fill="${COLORS.salmon}"
    />

    <rect
      x="${WIDTH - 72}"
      y="${bannerY + 13}"
      width="72"
      height="6"
      fill="${COLORS.salmon}"
    />

    <!-- ─────────────────────────────────── -->
    <!-- SIDE RETRO MARKINGS                  -->
    <!-- ─────────────────────────────────── -->

    <text
      x="38"
      y="${bannerY + 74}"
      fill="${COLORS.salmon}"
      font-family="Arial Black, Arial, sans-serif"
      font-size="14"
      font-weight="900"
    >▶</text>

    <text
      x="${WIDTH - 38}"
      y="${bannerY + 74}"
      text-anchor="end"
      fill="${COLORS.salmon}"
      font-family="Arial Black, Arial, sans-serif"
      font-size="14"
      font-weight="900"
    >◀</text>

    <!-- ─────────────────────────────────── -->
    <!-- IVHS LOGO                            -->
    <!-- ─────────────────────────────────── -->

    <!-- Retro offset/shadow -->
    <text
      x="${WIDTH / 2 + 5}"
      y="${bannerY + 82}"
      text-anchor="middle"
      fill="${COLORS.salmon}"
      font-family="Arial Black, Arial, sans-serif"
      font-size="59"
      font-weight="900"
      letter-spacing="5"
    >${TAG_NAME}</text>

    <!-- Main logo -->
    <text
      x="${WIDTH / 2}"
      y="${bannerY + 77}"
      text-anchor="middle"
      fill="${COLORS.cream}"
      font-family="Arial Black, Arial, sans-serif"
      font-size="59"
      font-weight="900"
      letter-spacing="5"
    >IVHS</text>

    <!-- ─────────────────────────────────── -->
    <!-- TAGLINE                              -->
    <!-- ─────────────────────────────────── -->

    <text
      x="${WIDTH / 2}"
      y="${bannerY + 108}"
      text-anchor="middle"
      fill="${COLORS.cream}"
      font-family="Arial Black, Arial, sans-serif"
      font-size="12"
      font-weight="900"
      letter-spacing="2"
    >${TAG_LINE}</text>

    <text
      x="${WIDTH / 2}"
      y="${bannerY + 127}"
      text-anchor="middle"
      fill="${COLORS.salmon}"
      font-family="Arial Black, Arial, sans-serif"
      font-size="12"
      font-weight="900"
      letter-spacing="4"
    >SYSTEM</text>

    <!-- ─────────────────────────────────── -->
    <!-- BOTTOM BORDER                        -->
    <!-- ─────────────────────────────────── -->

    <rect
      x="0"
      y="${HEIGHT - 7}"
      width="${WIDTH}"
      height="7"
      fill="${COLORS.purple}"
    />

  </g>

</svg>
`);

// ─────────────────────────────────────────────
// Composite overlay
// ─────────────────────────────────────────────

const result = await sharp(artwork)
  .composite([
    {
      input: overlay,
      top: 0,
      left: 0,
    },
  ])
  .png()
  .toBuffer();

// ─────────────────────────────────────────────
// Rounded card mask
// ─────────────────────────────────────────────

const mask = Buffer.from(`
<svg
  width="${WIDTH}"
  height="${HEIGHT}"
  viewBox="0 0 ${WIDTH} ${HEIGHT}"
  xmlns="http://www.w3.org/2000/svg"
>
  <rect
    x="0"
    y="0"
    width="${WIDTH}"
    height="${HEIGHT}"
    rx="${CORNER_RADIUS}"
    ry="${CORNER_RADIUS}"
    fill="white"
  />
</svg>
`);

// ─────────────────────────────────────────────
// Apply rounded corners + 300 DPI
// ─────────────────────────────────────────────

await sharp(result)
  .composite([
    {
      input: mask,
      blend: "dest-in",
    },
  ])
  .withMetadata({
    density: 300,
  })
  .png()
  .toFile(output);

console.log(`
✓ Generated ${output}

  Size:      ${WIDTH} × ${HEIGHT}px
  DPI:       300
  Physical:  53.98 × 85.60 mm
  Format:    CR80 portrait
  Corners:   ${CORNER_RADIUS}px
`);

