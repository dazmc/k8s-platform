# Platform Engineering Conventions for OpenCode

## Project Context

**Repository:** Multi-cloud Kubernetes platform
**Managed Clusters:** Azure AKS, AWS EKS, Google GKE
**IaC:** Terraform (terragrunt for multi-env orchestration)
**Deployment:** Helm + Kustomize, GitOps via Flux/ArgoCD
**Observability:** Prometheus, Grafana, CloudWatch, Azure Monitor
**On-Call:** PagerDuty for incidents >= SEV2

## OpenCode Commands You Can Use

### Skill Commands
- `/kubernetes-troubleshooting` — Pod debugging, node diagnostics, network troubleshooting
- `/terraform-validator` — Plan validation, cost estimation, security checks
- `/helm-chart-reviewer` — Chart linting, dependency checks, values validation
- `/incident-generator` — Create incident ticket, timeline, RCA template
- `/runbook-writer` — Generate `.md` or `.pdf` runbooks for common scenarios

### Agent Commands
- `/code-reviewer` — Review your Terraform/Helm PR for best practices
- `/security-auditor` — RBAC, pod security, network policies, compliance
- `/devops-oncall` — Triage cluster issues, pull logs, suggest fixes

### Prompt Shortcuts
- `/review-pr {pr_number}` — Review a GitHub PR before merge
- `/design-cluster {env}` — Design a new cluster for dev/staging/prod
- `/analyze-incident {log_file}` — Root cause analysis from incident logs

## Workflow: Kubernetes Cluster Design

1. **Initialize session:**
   ```bash
   opencode
   ```

2. **Describe the requirement:**
   ```
   I need a production AKS cluster in eastus for 1000 pods, 
   high availability, multi-AZ, with cost optimization.
   Use /design-cluster prod to generate starter Terraform.
   ```

3. **Agent generates:**
   - Terraform modules (networking, node pools, security)
   - `terraform.tfvars` with estimated costs
   - `.opencode/suggested-edits/` with inline comments

4. **Review locally:**
   ```bash
   cd terraform/azure/prod
   terraform plan -out=plan.tfout
   # Review the plan; OpenCode shows diffs inline
   ```

5. **Ask for changes:**
   ```
   Add spot node pool for non-critical workloads to reduce cost 30%.
   Keep resource requests but use cheaper instance types.
   ```

6. **Commit locally:**
   ```
   git add terraform/
   git commit -m "feat: add prod AKS cluster in eastus"
   git push origin feature/prod-aks-cluster
   ```

## Workflow: Incident Response

1. **Alert fires; you get paged:**
   ```bash
   opencode
   ```

2. **Start incident investigation:**
   ```
   /incident-generator SEV2 "API pods CrashLoopBackOff"
   ```

3. **OpenCode creates:**
   - Incident ticket in `.incidents/INCIDENT_2024_01_15_001.md`
   - Timeline template (auto-fills current time)
   - RCA skeleton

4. **Query cluster:**
   ```
   Show me all CrashLoopBackOff pods in production with their logs.
   Use kubectl via local shell access.
   ```

5. **Generate fix:**
   ```
   The issue is memory limit. Generate the YAML fix, 
   test it locally with kind, then show me the patch.
   ```

6. **Apply and verify:**
   ```bash
   kubectl patch -f fix.patch
   kubectl rollout status deployment/api -n production
   ```

7. **Generate post-mortem:**
   ```
   /runbook-writer "Why did we hit OOMKilled?" --format pdf
   ```

## Workflow: Terraform PR Review

1. **In VS Code or terminal:**
   ```bash
   git checkout feature/networking-policies
   opencode
   ```

2. **Run security audit:**
   ```
   /security-auditor
   ```

3. **OpenCode checks:**
   - IAM policies (least-privilege)
   - Security groups (no 0.0.0.0/0)
   - Resource tagging (cost tracking)
   - Remote state backend (encryption, versioning)
   - Network isolation

4. **Ask for changes:**
   ```
   The NAT gateway has no logging enabled. 
   Add flow logs to CloudWatch and re-run terraform plan.
   ```

5. **Merge when ready:**
   ```bash
   git merge feature/networking-policies
   opencode commit -m "Merge: add network policies with logging"
   ```

## Terraform Conventions

- **Directory structure:** `terraform/{cloud}/{env}/{component}/`
  ```
  terraform/
  ├── azure/
  │   ├── dev/
  │   │   ├── cluster/
  │   │   ├── networking/
  │   │   └── main.tf
  │   ├── staging/
  │   └── prod/
  ├── aws/
  └── gcp/
  ```

- **Naming:** Resource names = `{component}-{env}-{region}` (e.g., `aks-prod-eastus`)
- **Tagging:** All resources must have `Environment`, `Owner`, `CostCenter`, `ManagedBy=Terraform`
- **State:** Remote-backed (S3/Azure Storage), encrypted, versioned
- **Validation:** `terraform fmt`, `terraform validate`, `tfsec` (security linting)

## Kubernetes Manifest Conventions

- **Format:** Kustomize overlays, not raw kubectl
- **Namespaces:** `{team}-{env}` (e.g., `platform-prod`)
- **Resource limits:** Every container must specify `requests` and `limits`
- **Security:** Pod Security Standards (restricted in prod)
- **Network policies:** Default-deny; explicitly allow traffic
- **RBAC:** Least-privilege service accounts per namespace

## Git Workflow (OpenCode Hooks Auto-Enforce)

1. **Feature branch:** `git checkout -b feature/description`
2. **Make changes**
3. **Pre-commit hooks run automatically:**
   - Terraform lint (`terraform fmt -check`)
   - Helm lint (`helm lint`)
   - Kubernetes manifest validation (`kubeval`)
4. **If hooks fail:** Fix locally, re-commit
5. **Push:** `git push origin feature/description`
6. **PR:** GitHub Actions run full test suite
7. **Merge:** Only after `code-reviewer` and `security-auditor` approve

## Incident Response Tiers

- **SEV1 (Critical):** Production down, immediate action
  - Pager oncall immediately
  - `/incident-generator SEV1` auto-escalates
  - `/devops-oncall` triages in real-time

- **SEV2 (High):** Production degraded
  - Slack #incidents channel notified
  - `/incident-generator SEV2` creates ticket
  - RCA required within 24h

- **SEV3 (Medium):** Non-production or minor impact
  - Logged in `/incidents/` directory
  - Optional RCA if pattern repeats

- **SEV4 (Low):** Observations, no action required
  - May auto-resolve

## Debugging Checklist (when running `/devops-oncall`)

- [ ] Check pod status: `kubectl get pods -n {ns} -o wide`
- [ ] Read pod logs: `kubectl logs {pod} -n {ns} --tail=50`
- [ ] Check events: `kubectl describe pod {pod} -n {ns}`
- [ ] Resource limits: `kubectl top pod {pod} -n {ns}`
- [ ] Node status: `kubectl get nodes -o wide`
- [ ] Metrics: Query Prometheus/CloudWatch
- [ ] GitOps sync: `flux get kustomization --all-namespaces`

## When to Escalate

- Unknown error codes → research + ask OpenCode
- Multi-service dependency → coordinate with on-call team
- Data loss risk → pause, engage manager
- Performance degradation without clear cause → full RCA

## Useful Commands in OpenCode Sessions

```bash
# Show current cluster
kubectl config current-context

# Get all resources in namespace
kubectl get all -n platform-prod

# Follow logs (real-time)
kubectl logs -f deployment/api -n platform-prod

# Port forward for debugging
kubectl port-forward svc/api 8080:80 -n platform-prod

# Check disk usage on node
kubectl debug node/{node-name} -it --image=ubuntu

# Describe events in namespace
kubectl get events -n platform-prod --sort-by='.lastTimestamp'
```

## Do Not Do

- ❌ Never `kubectl apply` directly in production (use GitOps)
- ❌ Never hardcode secrets (use Sealed Secrets / External Secrets Operator)
- ❌ Never scale stateful workloads manually (let HPA/VPA decide)
- ❌ Never skip pre-commit hooks
- ❌ Never approve your own incidents without peer review
