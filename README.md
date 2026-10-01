# Turfio Valhalla Routing Service

Valhalla routing service for Nepal. The original local Docker Compose workflow is preserved. Render uses a separate Dockerfile and a prebuilt routing dataset so production does not download Nepal OSM data or rebuild routing tiles.

## Local development

The existing `docker-compose.yml` remains unchanged and continues to use `./custom_files`.

## Validated production dataset

The production dataset was validated with Valhalla 3.5.1 and contains:

- `valhalla.json`
- `valhalla_tiles.tar`
- `admin_data/admins.sqlite`
- `timezone_data/timezones.sqlite`

Do not commit this dataset to normal Git. `valhalla_tiles.tar` exceeds GitHub's normal per-file size limit.

Package the already validated local folder with:

```bash
cd "$HOME"
tar -czf valhalla-nepal-production.tar.gz valhalla-nepal-production
```

Upload that archive to a stable HTTPS file location and set its URL as the Render environment variable `VALHALLA_DATA_URL`.

## Render deployment

1. Push this repository to GitHub.
2. Create the Render service using `render.yaml` or create a Docker web service manually.
3. Set `VALHALLA_DATA_URL` to the HTTPS URL of `valhalla-nepal-production.tar.gz`.
4. Deploy.
5. Verify `https://<service>.onrender.com/status`.
6. Test `/route` before pointing Turfio at the service.
7. Set the Turfio backend `VALHALLA_ENGINE_URL` to the Render service origin.

The production image is pinned to `ghcr.io/gis-ops/docker-valhalla/valhalla:3.5.1` rather than `latest`.

## Important

Render Free has an ephemeral filesystem. The entrypoint therefore restores the immutable routing dataset during a fresh instance start. No PBF download or graph build occurs in production.
