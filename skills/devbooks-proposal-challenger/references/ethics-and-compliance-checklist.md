# Ethics and Compliance Checklist

> Use this checklist when the project involves personal data, AI decisions, or social impact.
>
> This document is **optional guidance**. Use it only when the project involves one or more of:
> - Personal data collection/processing/storage
> - Algorithmic decisions (recommendation, moderation, scoring)
> - User behavior tracking
> - Automated decisions affecting user rights/benefits

---

## 1) Data privacy (GDPR/CCPA compliance)

### 1.1 Data collection checks

- [ ] **Necessity**: collect only data required to deliver the feature
- [ ] **Informed consent**: users understand and consent before collection
- [ ] **Purpose limitation**: use data only for the declared purpose; no secondary use
- [ ] **Minimization**: collect the minimal set of fields necessary

### 1.2 Data storage checks

- [ ] **Retention**: define how long data is kept and how it is deleted after expiration
- [ ] **Encryption**: sensitive data is encrypted at rest
- [ ] **Access control**: who can access the data; audit logs exist
- [ ] **Cross-border transfer**: whether data is transferred to other countries/regions

### 1.3 User rights checks

- [ ] **Access**: users can view their data
- [ ] **Rectification**: users can correct incorrect data
- [ ] **Deletion**: users can request deletion (“right to be forgotten”)
- [ ] **Portability**: users can export their data

### 1.4 Required design.md declaration

```markdown
### Data privacy statement
- Data collected: <list fields>
- Purpose: <describe>
- Retention: <N days/months/years>
- User rights UX: <how users access/rectify/delete>
```

---

## 2) Algorithmic bias (AI/ML systems)

### 2.1 Bias risk checks

| Bias type | Symptom | Detection method |
|----------|---------|------------------|
| Historical bias | training data reflects historical inequality | data audit |
| Representation bias | some groups are underrepresented | group distribution stats |
| Measurement bias | features unfairly impact some groups | fairness metric comparisons |
| Evaluation bias | evaluation metrics are unfair for some groups | stratified evaluation |

### 2.2 Fairness checklist

- [ ] Did we analyze performance differences across user groups?
- [ ] Is there a mechanism to detect and correct bias?
- [ ] Are fairness metrics defined (e.g., accuracy delta across groups < 5%)?
- [ ] Is there a human review path for edge cases?

### 2.3 Explainability checklist

- [ ] Can users understand “why did I get this result”?
- [ ] Is there an appeal/feedback channel?
- [ ] For important decisions, is there an opportunity for human intervention?

---

## 3) Social impact assessment

### 3.1 Negative impact checks

- [ ] Could this feature be abused? How is abuse prevented?
- [ ] Could it create filter bubbles/polarization?
- [ ] Could it widen the digital divide?
- [ ] Could it impact mental health?

### 3.2 Protecting vulnerable groups

- [ ] Are there extra protections for minors?
- [ ] Is the feature accessible for elderly/disabled users?
- [ ] Are low-income groups excluded from the service?

### 3.3 Required design.md declaration

```markdown
### Social impact assessment
- Potential negative impacts: <describe risks>
- Mitigations: <how risk is reduced>
- Vulnerable group protections: <special measures>
```

---

## 4) Security and abuse prevention

### 4.1 Abuse scenario checks

- [ ] Did we consider malicious-user abuse scenarios?
- [ ] Is there rate limiting against abuse/attacks?
- [ ] Is there content moderation where applicable (e.g., UGC)?
- [ ] Is there anomaly detection?

### 4.2 Data leakage prevention

- [ ] Is sensitive data sanitized/redacted?
- [ ] Are APIs authenticated and authorized?
- [ ] Do logs avoid leaking sensitive information?

---

## 5) Proposal-phase ethics checks

When challenging a proposal in `devbooks-proposal-challenger`, add these checks:

### 5.1 Mandatory (when personal data is involved)

- [ ] **Necessity**: is data collection strictly necessary?
- [ ] **User awareness**: do users understand how data is used?
- [ ] **Opt-out / deletion**: can users opt out or delete data?

### 5.2 Optional (when algorithmic decisions are involved)

- [ ] **Explainability**: can users understand the rationale?
- [ ] **Appeals**: can users challenge the decision?
- [ ] **Fairness**: is it fair across groups?

### 5.3 Proposal template addition

```markdown
### Ethics and compliance (optional; required if personal data is involved)

#### Data privacy
- Data collected: <none / list fields>
- Consent mechanism: <none / describe>
- Delete/export capability: <none / describe UX>

#### Algorithmic decisions (if applicable)
- Decision type: <none / recommendation / moderation / scoring / other>
- Explainability: <none / describe>
- Appeals: <none / describe>

#### Social impact
- Potential negative impacts: <none / describe risks>
- Mitigations: <none / describe>
```

---

## 6) Quick legal reference

| Regulation | Region | Core requirements |
|-----------|--------|-------------------|
| GDPR | EU | informed consent, data minimization, right to be forgotten, portability |
| CCPA | California | right to know, deletion, non-discrimination, opt-out |
| PIPL | China | separate consent, local storage, cross-border assessment |
| COPPA | US | child data protection under 13 |

---

## 7) Decision log template

When there is an ethics dispute, record it in the `Decision Log` section of `proposal.md`:

```markdown
### Ethics decision record

| Date | Disputed point | Positions | Final decision | Rationale |
|------|----------------|-----------|----------------|-----------|
| YYYY-MM-DD | whether to collect location | Product: better recs / Security: privacy risk | collect city-level only | balance value and privacy |
```
