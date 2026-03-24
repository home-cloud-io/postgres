ARG PG_MAJOR=17
ARG POSTGIS_MAJOR=3
ARG PGVECTOR_VERSION=0.8.1
ARG VCHORD_VERSION=0.5.3

# image to get vectorchord binary from
FROM tensorchord/vchord-binary:pg${PG_MAJOR}-v${VCHORD_VERSION}-${TARGETARCH} AS vchord

# base image
FROM pgvector/pgvector:${PGVECTOR_VERSION}-pg${PG_MAJOR}

# install postgis
ARG PG_MAJOR
ARG POSTGIS_MAJOR
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # ca-certificates: for accessing remote raster files;
    #   fix: https://github.com/postgis/docker-postgis/issues/307
    ca-certificates \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts
RUN rm -rf /var/lib/apt/lists/*

# install vectorchord
ARG TARGETARCH
ARG VCHORD_VERSION
COPY --from=vchord /workspace/postgresql-${PG_MAJOR}-vchord_${VCHORD_VERSION}-1_${TARGETARCH}.deb /tmp/vchord.deb
RUN apt-get install -y /tmp/vchord.deb && rm -f /tmp/vchord.deb

# start-up
CMD ["postgres", "-c" ,"shared_preload_libraries=vchord.so"]
