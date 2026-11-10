比价雷达 1.25.0 — AnyApp 0.10.11 bundled starter

Source: author-supplied 比价雷达.tgz.gz, received 2026-11-11.
Archive SHA-256: 9f7db5f5eac6c97f617ec277efcff9632735c3d6621122b309cdfe96dc084888
All eight package files are preserved byte-for-byte. No accounts, conversations,
records or authorization state are included. The package has empty personal
record/candidate state and default platform instructions only.

Rebuild bundled envelope: node products/radar-release/build.mjs
Verify import isolation: node --test runtime/tests/wish-starter-packages.test.mjs
The host rewrites the source package/panel identity into each new work's namespace.
Existing installed works and partially completed pinned installations are not replaced.

The older products/starter-apps/radar.js is historical source, not this release.
The starter build command now packages this directory for radar.
