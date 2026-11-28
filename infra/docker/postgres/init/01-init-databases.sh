#!/usr/bin/env bash

set -euo pipefail

psql -v ON_ERROR_STOP=1 \
    --username "$POSTGRES_USER" \
    --dbname postgres <<'SQL'

\getenv app_db DB_NAME
\getenv app_user DB_USERNAME
\getenv app_password DB_PASSWORD

\getenv knowledge_db KNOWLEDGE_DB_NAME
\getenv knowledge_user KNOWLEDGE_DB_USERNAME
\getenv knowledge_password KNOWLEDGE_DB_PASSWORD

-- Application database and user
CREATE ROLE :"app_user"
    WITH LOGIN PASSWORD :'app_password';

CREATE DATABASE :"app_db"
    OWNER :"app_user";

REVOKE CONNECT ON DATABASE :"app_db" FROM PUBLIC;

-- Knowledge database and user
CREATE ROLE :"knowledge_user"
    WITH LOGIN PASSWORD :'knowledge_password';

CREATE DATABASE :"knowledge_db"
    OWNER :"knowledge_user";

REVOKE CONNECT ON DATABASE :"knowledge_db" FROM PUBLIC;

-- Enable vector search
\connect :knowledge_db

CREATE EXTENSION IF NOT EXISTS vector;

SQL