# Builder stage: source for the node binary only (yt-dlp-ejs's JS runtime).
# Debian's own nodejs package is too old (needs >=22.6); discarded after the
# COPY below, so its layers don't end up in the final image.
FROM node:22-trixie-slim AS node

# Builder stage: static ffmpeg/ffprobe. Debian's ffmpeg package links
# libSDL2/libGL (for ffplay, which we never use), dragging in a Mesa/LLVM/Z3
# chain worth ~200MB installed for a headless container. These static
# binaries skip all of that.
FROM mwader/static-ffmpeg:9.0 AS ffmpeg

# Final image base: gives us pip and a venv to install yt-dlp into.
FROM python:3.14-slim

# node's only non-glibc deps (libstdc++/libgcc_s) are already present above,
# so a bare binary copy is enough - no need to apt-install anything for it.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=ffmpeg /ffmpeg /ffprobe /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        dumb-init \
        imagemagick \
        atomicparsley \
        aria2 \
        mediainfo \
    && rm -rf /var/lib/apt/lists/* \
    && python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir \
        "yt-dlp[default]" \
        yt-dlp-ejs \
    && printf '%s\n' \
        '--js-runtimes node' \
        '--no-cache-dir' \
        > /etc/yt-dlp.conf

ENV PATH="/opt/venv/bin:$PATH"
ENV HOME=/tmp
WORKDIR /data

ENTRYPOINT ["dumb-init", "--"]
