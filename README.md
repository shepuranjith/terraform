# 🚀 30-Day Terraform Revision Challenge

**Maintained by:** [Ranjith Shepur](https://github.com) — *DevOps Engineer*

Welcome to our collaborative **30-Day Terraform Revision Challenge**! This repository is designed for DevOps engineers and cloud enthusiasts to revise core Terraform concepts, write daily Infrastructure as Code (IaC) manifests, and build real-world AWS & multi-provider setups step by step.

---

## 📂 Repository Structure

Each day or topic has its own dedicated folder containing `.tf` configuration files and a `README.md` with revision notes and commands.

* **[`terraform block/`](./terraform%20block)** — Provider version constraints, `required_providers`, and Terraform settings (Terraform 0.13+).

---

## 📅 30-Day Revision Roadmap

### Week 1: Terraform Core & Foundations
* **Day 01:** Introduction to IaC — Infrastructure Orchestration (Terraform) vs. Configuration Management (Ansible).
* **Day 02:** Terraform Block & Provider Versioning (`required_providers`, version constraints, `.terraform.lock.hcl`).
* **Day 03:** Deploying Your First AWS Resource — IAM setup, Provider block, and EC2 instance (`aws_instance`).
* **Day 04:** Terraform Core Workflow — `init`, `validate`, `plan`, `apply`, and `destroy`.
* **Day 05:** Multi-Provider Demo — Creating a GitHub repository using the `integrations/github` provider & targeted destroy (`-target`).
* **Day 06:** Understanding Terraform State — `terraform.tfstate`, Desired State vs. Current State, and `terraform refresh`.
* **Day 07:** Week 1 Review & Mini-Project (Deploy & destroy multi-provider resources cleanly).

### Week 2: Configurations, Variables & Expressions
* **Day 08:** Attributes & Output Values — Exporting resource attributes (EIP, S3 domain) and cross-resource referencing.
* **Day 09:** Input Variables — Variable precedence (Defaults, `-var` CLI flags, `terraform.tfvars`, and `TF_VAR_` env vars).
* **Day 10:** Variable Data Types — Enforcing `string`, `number`, `list`, and `map` constraints (ELB & IAM demos).
* **Day 11:** Scaling with `count` & `count.index` — Creating multiple resources dynamically using lists.
* **Day 12:** Conditional Expressions — Environment switching (`dev` vs. `prod`) using `condition ? true_val : false_val`.
* **Day 13:** Local Values (`locals`) — Reducing repetition and keeping configurations clean.
* **Day 14:** Week 2 Review & Mini-Project (Parameterized AWS VPC/EC2/Security Group deployment).

### Week 3: Functions, Data Sources & Debugging
* **Day 15:** Built-in Functions (Part 1) — `lookup`, `element`, and `file` with `terraform console`.
* **Day 16:** Built-in Functions (Part 2) — `timestamp`, `formatdate`, and `zipmap`.
* **Day 17:** Data Sources (`data`) — Dynamically fetching the latest region-specific AMIs (`aws_ami`).
* **Day 18:** Debugging & Formatting — `TF_LOG` levels (`TRACE`, `DEBUG`, `INFO`), `TF_LOG_PATH`, `terraform fmt`, and `terraform validate`.
* **Day 19:** Dynamic Blocks & Splat Expressions (`[*]`) — Simplifying repeated nested blocks (Security Group rules).
* **Day 20:** CLI Power Tools — `terraform taint`, `terraform graph`, saving execution plans (`-out`), and `terraform output`.
* **Day 21:** Week 3 Review & Mini-Project (Dynamic multi-region EC2 setup with Data Sources & Dynamic Blocks).

### Week 4: Provisioners, Modules, Workspaces & Remote State
* **Day 22:** Terraform Provisioners — `local-exec`, `remote-exec`, `null_resource`, creation/destroy-time behavior, and `on_failure`.
* **Day 23:** Terraform Modules (Part 1) — DRY principles, creating a reusable EC2 module, and referencing module outputs.
* **Day 24:** Terraform Modules (Part 2) — Terraform Registry modules, module sources, and publishing modules.
* **Day 25:** Terraform Workspaces — Managing multiple environments (`dev`, `stage`, `prod`) using `terraform workspace` sub-commands.
* **Day 26:** Remote State Management — Securing state, `.gitignore` best practices, and configuring an **S3 Backend**.
* **Day 27:** State Locking & State Manipulation — DynamoDB state locking and `terraform state` commands (`mv`, `pull`, `push`, `rm`, `show`).
* **Day 28:** Importing Existing Infrastructure — Bringing manually created cloud resources under Terraform management with `terraform import`.
* **Day 29:** Security & Best Practices — Avoiding hardcoded secrets, IAM roles, and handling large infrastructures.
* **Day 30:** Final Capstone Challenge — End-to-end modular AWS architecture with remote S3 backend and workspaces!

---

## 🛠️ How to Add Your Daily Folder to This Repo

1. **Create a folder for the day** (e.g., `day-01-intro` or `02-terraform-block`):
   ```bash
   mkdir day-01-intro
   ```
2. **Add your `.tf` files and a `README.md`** explaining what you built.
3. **Stage, commit, and push one folder at a time:**
   ```bash
   git add day-01-intro/
   git commit -m "Add Day 01: Introduction to Terraform"
   git push
   ```

---

## 🤝 Contributing with Friends
1. **Fork** or **Clone** this repository:
   ```bash
   git clone https://github.com/terraform.git
   ```
2. Create a branch for your daily solution (e.g., `git checkout -b friend-name/day-01`).
3. Push your branch and open a **Pull Request** to compare approaches and review each other's Terraform code!

---

## 👨‍💻 Author
**Ranjith Shepur**  
DevOps Engineer | GitHub: [@shepuranjith](https://github.com)
