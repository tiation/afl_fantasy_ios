# DevOps Security Guide: Environment Variables and Secrets Management

## Overview
This document outlines the security requirements and best practices for managing sensitive credentials and environment variables in the AFL Fantasy Platform deployment pipelines.

## Environment Variables Requiring Secret Management

### Critical API Keys (Must be stored as secrets)
- `GEMINI_API_KEY` - Google Gemini API key for AI-powered analysis
- `OPENAI_API_KEY` - OpenAI API key for AI-powered analysis  
- `DFS_AUSTRALIA_API_KEY` - DFS Australia API key for enhanced statistics
- `CHAMPION_DATA_API_KEY` - Champion Data API key for advanced statistics
- `AFL_FANTASY_USERNAME` - AFL Fantasy authentication username
- `AFL_FANTASY_PASSWORD` - AFL Fantasy authentication password

### Security Tokens (Must be stored as secrets)
- `SESSION_SECRET` - Application session secret key
- `JWT_SECRET` - JWT signing secret key

### Database Credentials (Must be stored as secrets)
- `DATABASE_URL` - Complete database connection string
- `POSTGRES_PASSWORD` - PostgreSQL password
- `PGPASSWORD` - PostgreSQL password (alternative format)

## Deployment Pipeline Configuration

### GitHub Actions Secrets
Add the following secrets in your GitHub repository settings under `Settings > Secrets and variables > Actions`:

```bash
# Required Secrets
GEMINI_API_KEY=your_actual_gemini_api_key
OPENAI_API_KEY=your_actual_openai_key
DFS_AUSTRALIA_API_KEY=your_actual_dfs_key
CHAMPION_DATA_API_KEY=your_actual_champion_data_key
AFL_FANTASY_USERNAME=your_afl_username
AFL_FANTASY_PASSWORD=your_afl_password
DATABASE_URL=your_production_database_url
POSTGRES_PASSWORD=your_postgres_password
SESSION_SECRET=your_secure_session_secret
JWT_SECRET=your_secure_jwt_secret
```

### GitLab CI/CD Variables (for GitLab deployments)
Add these as protected variables in `Settings > CI/CD > Variables`:

```bash
# Protected and Masked Variables
GEMINI_API_KEY (protected: yes, masked: yes)
OPENAI_API_KEY (protected: yes, masked: yes)
DFS_AUSTRALIA_API_KEY (protected: yes, masked: yes)
CHAMPION_DATA_API_KEY (protected: yes, masked: yes)
AFL_FANTASY_PASSWORD (protected: yes, masked: yes)
DATABASE_URL (protected: yes, masked: no)
SESSION_SECRET (protected: yes, masked: yes)
JWT_SECRET (protected: yes, masked: yes)
```

### Kubernetes Secrets Management

#### For production deployments, update the secrets using kubectl:

```bash
# Create or update the secret
kubectl create secret generic afl-fantasy-secrets \
  --from-literal=GEMINI_API_KEY="your_actual_gemini_key" \
  --from-literal=OPENAI_API_KEY="your_actual_openai_key" \
  --from-literal=DFS_AUSTRALIA_API_KEY="your_actual_dfs_key" \
  --from-literal=CHAMPION_DATA_API_KEY="your_actual_champion_key" \
  --from-literal=AFL_FANTASY_USERNAME="your_afl_username" \
  --from-literal=AFL_FANTASY_PASSWORD="your_afl_password" \
  --from-literal=DATABASE_URL="your_production_db_url" \
  --from-literal=POSTGRES_PASSWORD="your_postgres_password" \
  --from-literal=SESSION_SECRET="your_session_secret" \
  --from-literal=JWT_SECRET="your_jwt_secret" \
  --namespace=afl-fantasy \
  --dry-run=client -o yaml | kubectl apply -f -
```

#### Using Helm (recommended):

```bash
helm install afl-fantasy ./helm \
  --set secrets.geminiApiKey="your_actual_gemini_key" \
  --set secrets.openaiApiKey="your_actual_openai_key" \
  --set secrets.dfsApiKey="your_actual_dfs_key" \
  --set secrets.championDataApiKey="your_actual_champion_key" \
  --set secrets.aflUsername="your_afl_username" \
  --set secrets.aflPassword="your_afl_password" \
  --set secrets.databaseUrl="your_production_db_url" \
  --set secrets.sessionSecret="your_session_secret" \
  --set secrets.jwtSecret="your_jwt_secret"
```

## Docker/Container Security

### Multi-stage Build Best Practices
- Secrets should never be baked into Docker images
- Use build-time arguments only for non-sensitive configuration
- Runtime secrets should be injected via environment variables or mounted volumes

### Example secure Docker run:
```bash
docker run -d \
  --name afl-fantasy \
  -e GEMINI_API_KEY="$GEMINI_API_KEY" \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  -e DATABASE_URL="$DATABASE_URL" \
  ghcr.io/your-repo/afl-fantasy:latest
```

## Security Verification Checklist

### Before Production Deployment:
- [ ] All API keys are stored in secure secret management systems
- [ ] No hardcoded credentials exist in source code
- [ ] `.env` files are excluded from version control (check `.gitignore`)
- [ ] Production secrets are different from development/staging
- [ ] All secrets have appropriate access controls and rotation policies
- [ ] Database connections use encrypted connections (SSL/TLS)
- [ ] Container images do not contain embedded secrets

### Regular Security Maintenance:
- [ ] Rotate API keys quarterly
- [ ] Audit secret access logs monthly
- [ ] Review and update access permissions quarterly
- [ ] Monitor for exposed credentials in logs
- [ ] Update dependencies with security patches

## Emergency Procedures

### If credentials are compromised:
1. Immediately rotate the affected API keys/secrets
2. Update all deployment environments with new credentials
3. Review access logs for unauthorized usage
4. Document the incident and remediation steps

### Contact Information:
- DevOps Team: garrett@sxc.codes
- Security Lead: tiatheone@protonmail.com
- Monitoring Alerts: garrett.dillman@gmail.com

## Related Documentation:
- [Environment Configuration](../README.md#environment-setup)
- [Deployment Guide](./DEPLOYMENT.md)
- [Monitoring Setup](./MONITORING.md)
