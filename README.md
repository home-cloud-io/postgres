# postgres

A custom PostgreSQL Docker image with the following extensions pre-installed:

- [PostGIS](https://postgis.net/)
- [pgvector](https://github.com/pgvector/pgvector)
- [pgvecto.rs](https://github.com/tensorchord/pgvecto.rs)
- [VectorChord](https://github.com/tensorchord/VectorChord/)

This is designed to be used as the central database for [Home Cloud](https://home-cloud.io) applications, many of which requires these extensions to function (e.g. Immich, Dawarich).
