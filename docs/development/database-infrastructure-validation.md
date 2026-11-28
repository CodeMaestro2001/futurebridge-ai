# Database Infrastructure Validation Report

**Project:** FutureBridge AI  
**Phase:** Sprint 00 — Engineering Foundation  
**Validation date:** 2026-11-28 (Asia/Colombo)  
**Overall status:** **PASS WITH WARNINGS**  
**Sprint decision:** **Ready for Sprint 00 — Step 06: Full Docker Compose Setup**  
**Production decision:** **Not production-ready without the improvements listed in this report**

No passwords, password hashes, API keys, or other secret values are included in this report. All validation was non-destructive. Database functional tests used session-scoped temporary objects and rolled them back.

## 1. Executive summary

The existing PostgreSQL and pgvector foundation is operational and satisfies the database acceptance criteria for the current local-development phase. Docker Compose validates successfully, PostgreSQL is healthy, both required databases and all three roles exist, ownership and database isolation are correct, and the two application roles have no elevated cluster privileges.

Authentication was tested from a separate ephemeral client container so that the connection used the active `scram-sha-256` host rule rather than PostgreSQL's container-local `trust` rule. Both authorized connections succeeded and both unauthorized cross-database connections were rejected.

PostgreSQL **17.12** and pgvector **0.8.7** were observed at runtime. The vector type, Euclidean and cosine distance operators, and both HNSW and IVFFlat indexes were exercised successfully as `futurebridge_ai`. The required distance query returned `1`, and the three-record similarity ranking matched the expected result.

There are no blocking defects for proceeding to Sprint 00 Step 06. The principal warnings are production-oriented: TLS is disabled, the image tag is mutable, production credential management is not implemented, operational capabilities are not yet present, and the new infrastructure files are not yet tracked in Git. These do not invalidate the current localhost-only development setup.

### Validation totals

| Metric | Count |
|---|---:|
| Total checks executed/reviewed | 50 |
| PASS | 45 |
| FAIL | 0 |
| WARNING | 5 |
| SKIPPED | 0 |
| NOT TESTED | 0 |
| Critical issues | 0 |

## 2. Environment information

| Component | Observed value | Status |
|---|---|---|
| Host | Windows with Docker Desktop Linux engine | PASS |
| Docker client/server | 29.8.1 / 29.8.1 | PASS |
| Docker Compose | v5.5.1 | PASS |
| Docker engine platform | Linux/amd64 | PASS |
| Compose project | `futurebridge` | PASS |
| Container | `futurebridge-postgres` | PASS |
| Container image | `pgvector/pgvector:pg17` | PASS |
| Resolved image digest | `sha256:b513c48566e4777cd3370451400000c78eda6a08131d68f4c31d4a76f27bd8fd` | PASS |
| PostgreSQL runtime version | 17.12 (Debian 17.12-1.pgdg12+1) | PASS |
| pgvector runtime version | 0.8.7 | PASS |
| Host mapping | `127.0.0.1:5434 -> 5432/tcp` | PASS |
| Container health | `healthy` | PASS |

The local host port is `5434` because this Windows host rejects binds to `127.0.0.1:5432`. PostgreSQL continues to use its standard internal port `5432`. This local override is supplied through the ignored `.env`; the repository default remains `5432`.

## 3. Infrastructure validation results

### Repository configuration

| Check | Observed result | Status |
|---|---|---|
| Compose syntax | `docker compose config --quiet` completed successfully | PASS |
| Compose-required variables | All nine referenced variables are present and non-empty in local `.env` | PASS |
| Example variable coverage | All nine Compose-required variables are represented in `.env.example` | PASS |
| Initialization script syntax | `bash -n` completed successfully in the container | PASS |
| Initialization execution | Logs show two roles, two databases, and the extension were created; init completed | PASS |
| Line endings | Compose, example env, Git config files, and init script contain LF with zero CRLF sequences | PASS |
| Localhost binding | Published database port is bound only to `127.0.0.1` | PASS |
| Persistence declaration | Named volume `futurebridge_postgres_data` targets `/var/lib/postgresql/data` | PASS |
| Init mount | Init directory is mounted read-only at `/docker-entrypoint-initdb.d` | PASS |
| Health check | `pg_isready`, 10-second interval, 5-second timeout, 5 retries, 30-second start period | PASS |
| Secret exclusion | `.env` is ignored, is not tracked, and has no observed Git history | PASS |
| Credential source scan | No literal credential assignments found outside ignored/generated/dependency paths | PASS |

The initialization script correctly uses `psql` variables populated with `\getenv`, quotes identifiers and password literals through psql variable syntax, revokes `PUBLIC` database connectivity, assigns ownership to the intended application roles, and enables pgvector only in the knowledge database. It is suitable for first initialization by the official entrypoint. It is intentionally not safe to rerun manually after initialization because `CREATE ROLE` and `CREATE DATABASE` are unconditional; the entrypoint's empty-data-directory semantics prevent normal repeat execution.

### Docker runtime

| Check | Observed result | Status |
|---|---|---|
| Engine availability | Client and Linux server responded | PASS |
| Compose availability | Compose v5.5.1 responded | PASS |
| Container state | Running | PASS |
| Health state | Healthy | PASS |
| Restart policy | `unless-stopped` | PASS |
| Port publication | `127.0.0.1:5434 -> 5432/tcp` | PASS |
| Data mount | Named volume is attached read/write | PASS |
| Init mount permissions | Bind mount is read-only | PASS |
| Startup log review | Init completed; server reported ready; no initialization or permission error observed | PASS |
| Image provenance | Runtime image and local digest were observed | PASS |

The named volume uses Docker's `local` driver and is mounted at PostgreSQL's data directory. No container restart or volume recreation was required for this validation.

## 4. Database validation results

### Databases and ownership

| Database | Expected owner | Observed owner | Status |
|---|---|---|---|
| `futurebridge_app` | `futurebridge_api` | `futurebridge_api` | PASS |
| `futurebridge_knowledge` | `futurebridge_ai` | `futurebridge_ai` | PASS |

### Roles and privileges

| Role | Login | Superuser | Create DB | Create role | Replication | Bypass RLS | Status |
|---|---:|---:|---:|---:|---:|---:|---|
| `futurebridge_admin` | Yes | Yes | Yes | Yes | Yes | Yes | PASS — bootstrap administrator |
| `futurebridge_api` | Yes | No | No | No | No | No | PASS |
| `futurebridge_ai` | Yes | No | No | No | No | No | PASS |

The two application roles have no additional role memberships. `PUBLIC` does not have `CREATE` on the `public` schema in either application database. The bootstrap administrator is the official image's `POSTGRES_USER` and is expected to be privileged; application services must not use it.

## 5. Authentication and isolation test results

Tests were executed from an ephemeral client container on `futurebridge_default`. This source matched the host `scram-sha-256` rule and therefore validated the configured passwords without exposing them.

| Test | Actual result | Status |
|---|---|---|
| `futurebridge_api` authenticates to `futurebridge_app` | Connected; server reported the expected role and database | PASS |
| `futurebridge_ai` authenticates to `futurebridge_knowledge` | Connected; server reported the expected role and database | PASS |
| API role connects to knowledge DB | Rejected with `permission denied for database` | PASS |
| AI role connects to application DB | Rejected with `permission denied for database` | PASS |
| `PUBLIC` connect privilege | False on both databases | PASS |
| Password reuse | Three roles have three distinct stored SCRAM hashes; configured values also compared distinct | PASS |

Relevant authentication settings observed:

- `password_encryption = scram-sha-256`
- Non-loopback host connections use `scram-sha-256`.
- Container-loopback connections use `trust`, as generated by the image. Validation did not rely on those rules for password tests.

## 6. pgvector verification results

All functional operations in this section were executed as `futurebridge_ai` against `futurebridge_knowledge`.

| Check | Actual result | Status |
|---|---|---|
| Extension installed | `vector` present | PASS |
| Installed extension version | 0.8.7 | PASS |
| Vector data type | `vector` present | PASS |
| HNSW access method | Present | PASS |
| IVFFlat access method | Present | PASS |
| Required distance query | `SELECT '[1,2,3]'::vector <-> '[1,2,4]'::vector` returned `1` | PASS |
| AI role vector DDL/DML | Temporary table, rows, indexes, and queries succeeded | PASS |

## 7. Similarity search test results

### Euclidean distance

| Rank | Content | Observed distance | Expected | Status |
|---:|---|---:|---:|---|
| 1 | University admission | 0.000000 | 0 | PASS |
| 2 | Scholarship opportunities | 1.000000 | 1 | PASS |
| 3 | Sports competition | 12.124356 | approximately 12.124 | PASS |

### Cosine distance

| Rank | Content | Observed distance | Status |
|---:|---|---:|---|
| 1 | University admission | 0.000000 | PASS |
| 2 | Scholarship opportunities | 0.008540 | PASS |
| 3 | Sports competition | 0.043817 | PASS |

Temporary HNSW and IVFFlat indexes were created successfully. With sequential scans disabled for deterministic plan validation, `EXPLAIN` selected each corresponding index in separate checks. The transaction was rolled back, and `to_regclass('test_embeddings') IS NULL` returned true, confirming cleanup.

## 8. Security findings

| Finding | Evidence and impact | Status |
|---|---|---|
| Local secret file handling | `.env` is ignored, untracked, and absent from observed history | PASS |
| Hardcoded secrets | Sanitized assignment scan found no literal credential assignments in source/config | PASS |
| Host database exposure | Bound only to `127.0.0.1`, not all host interfaces | PASS |
| Application role privilege | No superuser, role creation, DB creation, replication, bypass-RLS, or extra memberships | PASS |
| Database isolation | Cross-database access is denied | PASS |
| Password reuse | No reuse detected among the three database roles | PASS |
| Password authentication | External-container checks used SCRAM-SHA-256 successfully | PASS |
| Database TLS | `ssl=off`; acceptable for this isolated local setup, not acceptable as the final production posture | WARNING |

No secret values were emitted during the audit. PostgreSQL listens on all interfaces inside its isolated container, but Docker publishes the port only on host loopback. Production deployments must combine network policy, TLS, and restricted database ingress rather than relying on local Docker publication behavior.

## 9. Identified issues

1. **WARNING — TLS is disabled.** This is acceptable for current localhost-only development but production traffic must be encrypted or constrained to an equivalently protected private channel.
2. **WARNING — The image reference is mutable.** `pgvector/pgvector:pg17` can move to newer PostgreSQL 17 patch releases. Production and CI should pin an approved version or digest and use a controlled update process.
3. **WARNING — Production credentials still rely on environment files.** The local ignored `.env` is appropriate for development, but production requires a secrets manager, rotation, and audited delivery.
4. **WARNING — Operational database capabilities are not yet implemented.** No dedicated migration, backup/restore, connection-pooling, database-monitoring, or HA configuration was found by repository filename/content review.
5. **WARNING — Repository state is not finalized.** `docker-compose.yml` and `infra/docker/postgres/` are currently untracked, while `.env.example` is modified. Review and commit the intended non-secret files before treating the setup as reproducible for the team.

Additional non-blocking note: the development host uses port `5434` because Windows refuses port `5432`; this should be documented for local users and consumed through `DB_PORT`, not hardcoded in applications.

## 10. Recommended improvements

### Local development / Sprint 00

1. Review and commit the intended `docker-compose.yml`, initialization script, `.gitattributes`, `.gitignore`, and sanitized `.env.example`; never commit `.env`.
2. Document `DB_PORT` overrides and ensure API/AI service connection configuration consumes the variable consistently.
3. Add an automated smoke test that validates container health, database ownership, role isolation, pgvector version, and one vector distance query.
4. Introduce a migration tool before application schemas are developed: Flyway/Liquibase for Spring-owned schemas and an explicitly owned migration path for AI-service schemas.
5. Pin the image to an approved PostgreSQL/pgvector version or digest after defining the dependency-update process.

### Future production requirements

1. Store credentials in a managed secret store; use unique, rotated service credentials and keep the bootstrap administrator unavailable to applications.
2. Require encrypted database connections, certificate validation, private networking, firewall/security-group restrictions, and production-specific `pg_hba.conf` rules.
3. Add tested automated backups, point-in-time recovery/WAL archiving where required, retention policy, off-host storage, and periodic restore drills with measured RPO/RTO.
4. Add connection pooling (for example, PgBouncer or platform-managed pooling) with per-service pool limits and database connection budgets.
5. Add metrics, slow-query visibility, health alerts, disk/capacity monitoring, backup alerts, and centralized PostgreSQL logs with secret redaction.
6. Select an availability model appropriate to service objectives: managed PostgreSQL or replicated primary/standby, automated failover, and tested recovery procedures.
7. Plan vector growth: measure recall/latency, tune HNSW/IVFFlat parameters from representative data, schedule `ANALYZE`/vacuum, and capacity-test memory and storage.
8. Treat the Docker named volume as development persistence only; production data should use durable managed/block storage with explicit lifecycle and recovery controls.

## 11. Acceptance criteria checklist

| ID | Acceptance check | Status |
|---|---|---|
| AC-01 | Compose syntax validates | PASS |
| AC-02 | Required environment variables are configured | PASS |
| AC-03 | Example environment file covers Compose inputs | PASS |
| AC-04 | Initialization script syntax is valid | PASS |
| AC-05 | Initialization completed successfully | PASS |
| AC-06 | Required files use LF line endings | PASS |
| AC-07 | Database port is localhost-only | PASS |
| AC-08 | Persistent named volume is configured | PASS |
| AC-09 | Health check is configured and healthy | PASS |
| AC-10 | `.env` is ignored and untracked | PASS |
| AC-11 | No hardcoded credential assignment was detected | PASS |
| AC-12 | Docker Engine is available | PASS |
| AC-13 | Docker Compose is available | PASS |
| AC-14 | PostgreSQL container is running | PASS |
| AC-15 | Container restart policy is configured | PASS |
| AC-16 | Runtime PostgreSQL version was verified | PASS |
| AC-17 | Runtime image/digest was inspected | PASS |
| AC-18 | Data and init mounts have expected modes | PASS |
| AC-19 | Startup/init logs contain no unexpected errors | PASS |
| AC-20 | `futurebridge_app` exists | PASS |
| AC-21 | `futurebridge_knowledge` exists | PASS |
| AC-22 | All three required roles exist | PASS |
| AC-23 | Application database ownership is correct | PASS |
| AC-24 | Knowledge database ownership is correct | PASS |
| AC-25 | API role has least-privilege cluster attributes | PASS |
| AC-26 | AI role has least-privilege cluster attributes | PASS |
| AC-27 | Application roles have no extra memberships | PASS |
| AC-28 | Public schema creation is restricted | PASS |
| AC-29 | API role authenticates to application DB via SCRAM | PASS |
| AC-30 | AI role authenticates to knowledge DB via SCRAM | PASS |
| AC-31 | API role is denied knowledge DB access | PASS |
| AC-32 | AI role is denied application DB access | PASS |
| AC-33 | `PUBLIC` database connectivity is revoked | PASS |
| AC-34 | Database role passwords are distinct | PASS |
| AC-35 | Vector extension is installed | PASS |
| AC-36 | pgvector runtime version was verified | PASS |
| AC-37 | Vector data type is available | PASS |
| AC-38 | Required distance query returns 1 | PASS |
| AC-39 | Euclidean ranking matches expected values | PASS |
| AC-40 | Cosine distance operation succeeds | PASS |
| AC-41 | HNSW creation and query plan succeed | PASS |
| AC-42 | IVFFlat creation and query plan succeed | PASS |
| AC-43 | AI role can perform temporary vector DDL/DML | PASS |
| AC-44 | Temporary resources are cleaned up | PASS |
| AC-45 | Password hashing/auth method uses SCRAM-SHA-256 | PASS |
| AC-46 | Production database TLS posture | WARNING |
| AC-47 | Immutable production image pin | WARNING |
| AC-48 | Production secret-management posture | WARNING |
| AC-49 | Backup/migration/pooling/monitoring/HA posture | WARNING |
| AC-50 | Intended infrastructure files are version-controlled | WARNING |

## 12. Final readiness decision

**Decision: Ready for Sprint 00 — Step 06: Full Docker Compose Setup.**

The PostgreSQL/pgvector development foundation is functional, isolated, persistent, and verified with live tests. There are no failed acceptance checks or critical issues. The five warnings should be entered into the engineering backlog and addressed at the appropriate stage; TLS, managed secrets, immutable image selection, recovery, observability, and availability are mandatory before a production-readiness decision.
