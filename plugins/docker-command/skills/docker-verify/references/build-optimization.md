# build-optimization

- `.dockerignore` must exclude heavy directories.
- Next.js: require `.next` and `node_modules` in `.dockerignore`.
- Keep build contexts small: remove tests/logs/build artifacts/local secrets.
- Prefer `COPY package*.json ...` before source copy and enable cache-friendly install.
- Use BuildKit cache mount for package caches where possible.
- Use minimal base image and multi-stage build.
