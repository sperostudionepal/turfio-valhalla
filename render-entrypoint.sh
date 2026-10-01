#!/usr/bin/env bash
set -euo pipefail

: "${VALHALLA_DATA_URL:?VALHALLA_DATA_URL must point to the packaged valhalla-nepal-production.tar.gz archive}"

DATA_DIR=/custom_files
ARCHIVE=/tmp/valhalla-nepal-production.tar.gz
MARKER="$DATA_DIR/.dataset-ready"

mkdir -p "$DATA_DIR"

if [ ! -f "$MARKER" ]; then
  echo "Downloading prebuilt Nepal Valhalla dataset..."
  curl --fail --location --retry 3 --output "$ARCHIVE" "$VALHALLA_DATA_URL"
  tar -xzf "$ARCHIVE" -C "$DATA_DIR"
  rm -f "$ARCHIVE"
  echo "Dataset extracted. Contents:"
find "$DATA_DIR" -maxdepth 3 -type f -print

for required_file in \
  "$DATA_DIR/valhalla.json" \
  "$DATA_DIR/valhalla_tiles.tar" \
  "$DATA_DIR/admin_data/admins.sqlite" \
  "$DATA_DIR/timezone_data/timezones.sqlite"
do
  if [ ! -f "$required_file" ]; then
    echo "ERROR: Required Valhalla file missing: $required_file"
    exit 1
  fi
done

echo "All required Valhalla files verified."
touch "$MARKER"
fi

# Render requires the service to bind to its assigned PORT. The GIS-OPS image
# normally listens on 8002, so default PORT to 8002 for this service.
export server_threads="${SERVER_THREADS:-1}"
export use_tiles_ignore_pbf=True
export force_rebuild=False
export build_elevation=False
export build_admins=False
export build_time_zones=False

exec /valhalla/scripts/run.sh
