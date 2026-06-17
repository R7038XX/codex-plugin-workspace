# cleanup-policy

# cleanup-policy

- default mode: `docker system df`, container/image/builder/network prune, then `docker system df`.
- scoped mode: same commands with filters.
- dry-run mode:
  - `docker-cleanup-safe.sh --dry-run`: mode=`default-dry-run`
  - `docker-cleanup-safe.sh --dry-run --scoped`: mode=`scoped-dry-run`
  - behavior: only planned command list output.
- prohibited: `docker system prune -a`, `docker system prune -a --volumes`, `docker volume prune`, `docker builder prune -a`.
