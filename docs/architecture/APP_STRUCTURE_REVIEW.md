# AFL Fantasy iOS App - Architecture Review & Improvement Plan

**Date:** 2025-01-10  
**Status:** Active Implementation

## Current Architecture Overview

### High-Level Layout
- **iOS App:** `ios/AFLFantasyIntelligence`
- **Backend (Node/TS):** `server-node`
- **Backend (Python):** `server-python`
- **Web Client:** `web-client`
- **Shared Assets:** `data`, `docs`, `infra`, `scripts`, `backup_models`, `archive`

### What's Working Well ✅
- Clear separation of concerns between iOS, Node backend, Python scrapers, and web client
- Python server has well-structured tests and utilities under `server-python`
- Node backend is modular with TypeScript support
- Infrastructure foundation exists (k8s/Helm/Terraform)
- iOS project includes quality gates (`Scripts/quality.sh`, `Scripts/coverage_gate.sh`)
- Readable source structure across all components

## Critical Issues & Risks 🚨

### 1. Duplicate Scraping Backends
**Problem:** Multiple scraping implementations exist:
- `server-python` has `dfs_australia_scraper*.py` and API servers
- `server-node/backend/python` has its own scraping setup

**Risk:** Logic drift, environment inconsistencies, data schema divergence

**Solution:** Choose one authoritative scraping pipeline and consume its outputs everywhere

### 2. Data Scattering
**Problem:** `dfs_player_summary` exists in three locations:
- Repository root
- `data/dfs_player_summary`
- `server-node/backend/python/dfs_player_summary`

**Solution:** Consolidate to `data/dfs_player_summary` and reference from all services

### 3. Environment Inconsistency
**Problem:** Mixed Python environment managers:
- `venv` at root
- Miniconda (system)
- `uv.lock` and `requirements.txt` in server-python

**Solution:** Pick one Python environment manager per service (recommend `uv` or `venv`)

### 4. Node Duplication
**Problem:** Root `package.json` (full-stack "rest-express") coexists with `server-node`

**Solutions:**
- **Option A:** Make `server-node` the single Node backend
- **Option B:** Keep root as the only Node backend, deprecate `server-node`

### 5. Incomplete Player Index
**Problem:** `AFL_Fantasy_Player_URLs.xlsx` only contains 87 players (need ~650)

**Solution:** Create generator for complete player dataset

### 6. CI/CD Gaps
**Problem:** Inconsistent CI across services

**Solution:** Ensure all components have lint/typecheck/test/size gates

## Implementation Plan

### Phase 1: Data & Environment Consolidation (Week 1)
- [x] Document architecture review
- [ ] Consolidate all `dfs_player_summary` to `data/dfs_player_summary`
- [ ] Generate complete player index (~650 players)
- [ ] Standardize Python environment (choose `uv` or `venv`)
- [ ] Unify Node backend location

### Phase 2: Apply Standards (Week 1-2)
- [ ] iOS: Verify `.swiftformat`, `.swiftlint.yml`, `.editorconfig`
- [ ] Web: Add `.eslintrc.json`, `.prettierrc`, `stylelint`, strict `tsconfig.json`
- [ ] Python: Add `ruff`/`black`/`isort` config, security checks
- [ ] Add `Scripts/size-gate.sh` for web bundle size enforcement

### Phase 3: API Unification (Week 2)
- [ ] Choose canonical scraper (Python or Node)
- [ ] Expose single API surface for consumers
- [ ] Update all consumers to use unified API
- [ ] Document API endpoints and data schemas

### Phase 4: CI/CD Setup (Week 2-3)
- [ ] GitHub Actions for iOS (already has scripts)
- [ ] GitHub Actions for Web (lint, test, build, size-gate)
- [ ] GitHub Actions for Python (lint, test, security)
- [ ] GitHub Actions for Node (lint, test, build)

## Target Architecture

```
afl_fantasy_ios/
├── data/                      # Centralized data storage
│   ├── dfs_player_summary/    # All scraped player data
│   ├── core/                  # Core datasets (player index, etc.)
│   └── database/              # DB dumps/migrations
├── server/                    # Unified backend (Node or Python)
│   ├── api/                   # REST/WebSocket endpoints
│   ├── scrapers/              # Data collection
│   └── services/              # Business logic
├── ios/                       # iOS app
│   └── AFLFantasyIntelligence/
├── web-client/                # Web frontend
│   └── client/
├── infra/                     # Deployment configs
│   ├── k8s/
│   ├── helm/
│   └── terraform/
└── config/                    # Centralized configs
    ├── .env.example
    └── services/
```

## Quick Sanity Checklist ✓
- [ ] One canonical backend for scraping and player data APIs
- [ ] All outputs in `data/dfs_player_summary` (no duplicates)
- [ ] Single Node backend location
- [ ] Consistent Python toolchain per service
- [ ] Lockfiles committed for all services
- [ ] CI for iOS/Web/Node/Python aligned with performance gates

## Success Metrics
- **Code Quality:** All linters passing, 80%+ test coverage
- **Performance:** Cold start ≤1.8s (iOS), bundle ≤90KB gz (web)
- **Data Completeness:** 650+ players indexed and scraped
- **Developer Experience:** Single command to run each service
- **Deployment:** Automated CI/CD for all components

## Next Steps
1. Consolidate `dfs_player_summary` directories
2. Generate full player index
3. Standardize Python environment
4. Apply coding standards configs
5. Set up CI pipelines

---

*This document is actively maintained. Update as implementation progresses.*
