ARG PG_MAJOR=17
ARG PGVECTORS_VERSION=0.3.0
ARG VCHORD_VERSION=0.3.0
ARG PGVECTOR_VERSION=0.8.0

# images to copy from
FROM tensorchord/pgvecto-rs-binary:pg${PG_MAJOR}-v${PGVECTORS_VERSION}-amd64 AS pgvectors
FROM tensorchord/vchord-binary:pg${PG_MAJOR}-v${VCHORD_VERSION}-amd64 AS vchord

# base image
FROM pgvector/pgvector:${PGVECTOR_VERSION}-pg${PG_MAJOR}

# install postgis
ARG POSTGIS_MAJOR=3
ARG POSTGIS_VERSION=3.5.3+dfsg-1~exp1.pgdg120+1
RUN apt-get update && \
    apt list postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR && \
    apt-get install -y --no-install-recommends \
           # ca-certificates: for accessing remote raster files;
           #   fix: https://github.com/postgis/docker-postgis/issues/307
           ca-certificates \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts
RUN rm -rf /var/lib/apt/lists/*

# install pgvecto.rs
COPY --from=pgvectors /pgvecto-rs-binary-release.deb /tmp/vectors.deb
RUN apt-get install -y /tmp/vectors.deb && rm -f /tmp/vectors.deb

# install vectorchor
ARG VCHORD_VERSION=0.3.0
COPY --from=vchord /workspace/postgresql-${PG_MAJOR}-vchord_${VCHORD_VERSION}-1_amd64.deb /tmp/vchord.deb
RUN apt-get install -y /tmp/vchord.deb && rm -f /tmp/vchord.deb

# start-up
CMD ["postgres", "-c" ,"shared_preload_libraries=vectors.so,vchord.so"]
