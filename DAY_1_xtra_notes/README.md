# Terraform Version Constraints & Operators Cheat Sheet

This guide covers version constraint operators used in `terraform`, `required_providers`, and `module` blocks, as well as general comparison operators used in expressions.

---

## 1. Version Constraint Operators

Used inside `version` or `required_version` arguments to control which versions of Terraform, providers, or modules are allowed.

| Operator | Name | Meaning | Example | Allowed Versions |
| :--- | :--- | :--- | :--- | :--- |
| **`=`** (or none) | Exact Match | Allows only one specific version. | `version = "= 1.5.0"` | Only `1.5.0` |
| **`!=`** | Not Equal | Excludes a specific broken or unwanted version. | `version = "!= 1.5.1"` | Any version except `1.5.1` |
| **`>`** | Greater Than | Allows any version newer than the specified one. | `version = "> 1.5.0"` | `1.5.1`, `1.6.0`, `2.0.0` |
| **`<`** | Less Than | Allows any version older than the specified one. | `version = "< 2.0.0"` | `1.9.9`, `1.5.0`, `0.12.0` |
| **`>=`** | Greater Than or Equal | Allows the specified version or anything newer. | `version = ">= 1.5.0"` | `1.5.0`, `1.5.1`, `2.0.0` |
| **`<=`** | Less Than or Equal | Allows the specified version or anything older. | `version = "<= 2.0.0"` | `2.0.0`, `1.9.0`, `1.0.0` |
| **`~>`** | Pessimistic Constraint | Allows only the **rightmost** version component to increment. | `version = "~> 1.5.0"`<br>`version = "~> 1.5"` | `1.5.0` to `1.5.9` (Not `1.6.0`)<br>`1.5.0` to `1.9.9` (Not `2.0.0`) |

> **Note on `~<`:** Terraform **does not** have a `~<` operator. Only `~>` (pessimistic constraint) exists.

### Quick Examples

#### Combining Constraints (Comma-Separated)
You can combine multiple rules using a comma (acts as a logical `AND`):
```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0, != 1.5.4"
}
```

#### Provider Version Example
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Allows 5.1, 5.45, etc., but blocks 6.0.0
    }
  }
}
```

---

## 2. Expression Comparison Operators

Used inside Terraform logic (like `count`, `for_each`, `if` conditions, and `locals`) to compare values and return `true` or `false`.

| Operator | Meaning | Example | Result |
| :--- | :--- | :--- | :--- |
| **`==`** | Equal to (Note the double `==`) | `"prod" == "prod"` | `true` |
| **`!=`** | Not equal to | `var.env != "dev"` | `true` (if `env` is `"prod"`) |
| **`>`** | Greater than | `5 > 3` | `true` |
| **`<`** | Less than | `5 < 3` | `false` |
| **`>=`** | Greater than or equal to | `5 >= 5` | `true` |
| **`<=`** | Less than or equal to | `4 <= 5` | `true` |

### Quick Revision Rules
1. **Single `=` vs Double `==`:** Use single `=` for **version constraints** (`version = "= 1.0"`). Use double `==` for **conditional logic** (`var.x == 10`).
2. **Pre-release Tags:** Versions with tags like `1.2.0-beta` are considered **older** than `1.2.0` and are usually ignored unless specified explicitly.
3. **Production Best Practice:** Always use **`~>`** for providers and modules in production so you get bug fixes/minor updates automatically without risking breaking major upgrades.

