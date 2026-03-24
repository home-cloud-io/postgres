ARG PG_MAJOR=17
ARG POSTGIS_MAJOR=3
ARG PGVECTOR_VERSION=0.8.1
ARG VCHORD_VERSION=0.5.3

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
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# install vectorchord
ARG TARGETARCH
ARG VCHORD_VERSION
RUN apt-get update && \
    apt-get install -y wget && \
    wget -nv -O /tmp/vchord.deb https://github.com/tensorchord/VectorChord/releases/download/${VCHORD_VERSION}/postgresql-${PG_MAJOR%.*}-vchord_${VCHORD_VERSION}-1_${TARGETARCH}.deb && \
    apt-get install -y /tmp/vchord.deb && \
    rm -f /tmp/vchord.deb && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# start-up
CMD ["postgres", "-c" ,"shared_preload_libraries=vchord.so"]
