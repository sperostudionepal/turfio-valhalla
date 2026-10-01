FROM ghcr.io/gis-ops/docker-valhalla/valhalla:3.5.1

USER root
RUN mkdir -p /custom_files && chown -R valhalla:valhalla /custom_files

COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod +x /render-entrypoint.sh

EXPOSE 8002
ENTRYPOINT ["/render-entrypoint.sh"]
