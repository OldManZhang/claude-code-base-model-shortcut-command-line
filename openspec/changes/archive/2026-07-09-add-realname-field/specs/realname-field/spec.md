# model-name-field Specification

## Purpose

`cc` SHALL support an optional `model_name` field in model config entries to decouple the CLI-facing model key from the actual model name sent to the API. This allows users to use clean shell-safe model keys while still passing the correct model identifier to the provider.

## ADDED Requirements

### Requirement: model_name Field in Model Config

A model entry SHALL support an optional `model_name` field of type string.

#### Scenario: model_name present
- **WHEN** a model entry has `model_name` set to a non-empty string
- **THEN** `cc` SHALL use `model_name` as the value for `ANTHROPIC_MODEL` when launching `claude`
- **AND** `cc --dry-run` SHALL display the model_name value

#### Scenario: model_name absent
- **WHEN** a model entry does not have a `model_name` field
- **THEN** `cc` SHALL fall back to using the model key as `ANTHROPIC_MODEL` (current behavior, backward compatible)

#### Scenario: model_name empty
- **WHEN** a model entry has `model_name` set to an empty string `""`
- **THEN** `cc` SHALL treat it as absent and fall back to the model key

### Requirement: CLI Args Unchanged

The `model_name` field SHALL NOT affect CLI argument parsing. Users still invoke `cc <provider>:<model>` using the model key (the JSON object key), not the model_name.

#### Scenario: Invocation by model key
- **WHEN** user runs `cc xiaomi:mimo-v2.5-pro`
- **THEN** `cc` SHALL resolve the model by its key `mimo-v2.5-pro`
- **AND** export `ANTHROPIC_MODEL` as the model_name value (if set)
- **AND** SHALL NOT require the user to type the model_name value on the command line

### Requirement: Shell Safety

The model key (JSON object key) MUST be safe for unquoted use in bash/zsh. model_name values MAY contain any characters and are only consumed via `jq` quoting.

#### Scenario: model_name with glob characters
- **WHEN** a model has `model_name` containing `[`, `]`, `*`, `?`, or other shell glob characters
- **THEN** these characters SHALL NOT cause shell errors, since they are never passed through shell expansion
- **AND** the correct value SHALL be exported to `ANTHROPIC_MODEL`

### Requirement: Backward Compatibility

Existing configs without `model_name` MUST continue to work unchanged.

#### Scenario: No model_name in existing config
- **WHEN** user upgrades `cc` but has not added `model_name` to any model
- **THEN** all existing provider:model invocations work exactly as before
- **AND** the behavior is identical to pre-feature behavior
