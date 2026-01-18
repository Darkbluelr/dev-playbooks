# Orchestration Logic Pseudocode

## Main Orchestration Function

```python
def run_delivery_workflow(user_requirement):
    """
    Main Agent only executes this orchestration logic, does no actual work
    """

    # ==================== Phase 1: Propose ====================
    change_id = call_subagent("devbooks-proposal-author", {
        "task": "Create change proposal",
        "requirement": user_requirement
    })
    verify_output(f"{change_root}/{change_id}/proposal.md")

    # ==================== Phase 2: Challenge ====================
    challenge_result = call_subagent("devbooks-challenger", {
        "task": "Challenge proposal",
        "change_id": change_id
    })
    # Don't skip, run even if no challenges

    # ==================== Phase 3: Judge ====================
    judge_result = call_subagent("devbooks-judge", {
        "task": "Judge proposal",
        "change_id": change_id,
        "challenge_result": challenge_result
    })
    if judge_result == "REJECTED":
        return "Proposal rejected, workflow terminated"
    if judge_result == "REVISE":
        # Return to Phase 1, rewrite proposal
        return run_delivery_workflow(revised_requirement)
    # judge_result == "APPROVED" continue

    # ==================== Phase 4: Design ====================
    call_subagent("devbooks-designer", {
        "task": "Create design document",
        "change_id": change_id
    })
    verify_output(f"{change_root}/{change_id}/design.md")

    # ==================== Phase 5: Spec ====================
    call_subagent("devbooks-spec-owner", {
        "task": "Define spec contracts",
        "change_id": change_id
    })
    # specs/ directory may be empty (when no external contracts)

    # ==================== Phase 6: Plan ====================
    call_subagent("devbooks-planner", {
        "task": "Create implementation plan",
        "change_id": change_id
    })
    verify_output(f"{change_root}/{change_id}/tasks.md")

    # ==================== Phase 7: Test-Red ====================
    # Must use independent Agent session
    call_subagent("devbooks-test-owner", {
        "task": "Write tests and establish Red baseline",
        "change_id": change_id,
        "isolation": "required"  # Force isolation
    })
    verify_output(f"{change_root}/{change_id}/verification.md")
    verify_output(f"{change_root}/{change_id}/evidence/red-baseline/")

    # ==================== Phase 8: Code ====================
    # Must use independent Agent session
    call_subagent("devbooks-coder", {
        "task": "Implement functionality according to tasks.md",
        "change_id": change_id,
        "isolation": "required"  # Force isolation
    })

    # ==================== Phase 9: Test-Review ====================
    test_review_result = call_subagent("devbooks-reviewer", {
        "task": "Review test quality",
        "change_id": change_id,
        "review_type": "test-review"
    })
    if test_review_result == "REVISE REQUIRED":
        # Return to Phase 7, fix test issues
        goto_stage(7)

    # ==================== Phase 10: Code-Review ====================
    code_review_result = call_subagent("devbooks-reviewer", {
        "task": "Review code quality",
        "change_id": change_id,
        "review_type": "code-review"
    })
    if code_review_result == "REVISE REQUIRED":
        # Return to Phase 8, fix code issues
        goto_stage(8)

    # ==================== Phase 11: Green-Verify ====================
    # Must use independent Agent session (same Test Owner as Phase 7)
    call_subagent("devbooks-test-owner", {
        "task": "Run all tests and collect Green evidence",
        "change_id": change_id,
        "isolation": "required",
        "phase": "green-verify"
    })
    verify_output(f"{change_root}/{change_id}/evidence/green-final/")

    # ==================== Phase 12: Archive ====================
    # Archiver will automatically run change-check.sh --mode strict
    call_subagent("devbooks-archiver", {
        "task": "Execute archive",
        "change_id": change_id
    })

    return "Closed loop complete"
```
