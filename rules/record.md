---
alwaysApply: true
---

# Global Agent Rules (CoCo / TraeCli)

These rules apply to all CoCo/TraeCli AI sessions unless overridden by a project-specific instruction.

## 飞书每日工作记录 (Daily Feishu Logging) - ⚠️ HIGHEST PRIORITY ⚠️

**CRITICAL REQUIREMENT:** You MUST NOT skip or forget to log your work. Updating the Feishu log is NOT optional.

Whenever executing ANY of the following:
1. A complex task or bug fix
2. A multi-step project (update after completing meaningful intermediate steps, do not wait until the very end!)
3. Explicitly requested by the user
4. **Before concluding any session where meaningful code, script, or configuration changes were made.**

You **MUST** track your progress in the Feishu Daily Record Document configured via the global environment variable `$TRAE_DAILY_RECORD_DOC`.

**Mandatory Action:**
To fulfill this, you must **ALWAYS invoke the `daily-record` Skill**. Do not try to write the markdown format or call Feishu APIs manually from scratch. Follow the skill's built-in behavior for formatting (aggregation, nested checklists) and command execution; do not rely on any repository-local instructions file.

*If you finish a task, or a significant intermediate step, and are about to tell the user "I've done this part", STOP, check if you have updated the Feishu document using the skill, and if not, DO IT IMMEDIATELY before responding.*

