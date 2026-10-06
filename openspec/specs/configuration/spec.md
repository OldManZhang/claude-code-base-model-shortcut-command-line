# configuration Specification

## Purpose

`cc` SHALL read a single JSON config file holding all LLM providers, their models, and per-provider / per-model environment overrides, and SHALL apply them when launching the Claude CLI.

## Requirements

### Requirement: Config File Location

`cc` SHALL read `${CC_PATH}/models.config`, where `CC_PATH` defaults to `~/.cc`.

#### Scenario: CC_PATH not set
- **WHEN** user runs `cc` without `CC_PATH` exported
- **THEN** `cc` reads from `~/.cc/models.config`

#### Scenario: CC_PATH set to custom directory
- **WHEN** user has `CC_PATH=/some/dir` exported and runs `cc`
- **THEN** `cc` reads from `/some/dir/models.config`

#### Scenario: Config file missing
- **WHEN** `${CC_PATH}/models.config` does not exist
- **THEN** `cc` falls back to legacy `${CC_PATH}/configs/env.<provider>` files if present
- **AND** if neither exists, `cc` reports an error and exits non-zero

### Requirement: Config File Format

The config SHALL be a JSON document with the schema:

```json
{
  "config_version": "<string>",
  "providers": {
    "<name>": {
      "base_url": "<string>",
      "anthropic_auth_token": "<string>",
      "anthropic_api_key": "<string>",
      "extra_env": { "<KEY>": "<VALUE>", ... },
      "models": {
        "<model>": {
          "enable": <boolean>,
          "extra_env": { "<KEY>": "<VALUE>", ... }
        }
      }
    }
  },
  "default": "<provider>:<model>"
}
```

Each provider SHALL carry its credential in exactly one of `anthropic_auth_token` or
`anthropic_api_key` (mutually exclusive). The top-level `config_version` field marks the
schema generation of the file; its value is the cc version string that produced it
(e.g. `"0.2.5"`). Absence of `config_version` marks a legacy config that triggers
automatic migration on startup.

#### Scenario: Valid JSON
- **WHEN** the config file parses as valid JSON
- **THEN** `cc` proceeds with config loading

#### Scenario: Malformed JSON
- **WHEN** the config file is not valid JSON
- **THEN** `jq` emits an error and `cc` exits non-zero

### Requirement: Provider Schema

A provider entry SHALL contain `base_url` and exactly one credential field:
`anthropic_auth_token` (exported as `ANTHROPIC_AUTH_TOKEN`) or
`anthropic_api_key` (exported as `ANTHROPIC_API_KEY`). The field name matches the
target environment variable name (lowercase).

#### Scenario: Provider with anthropic_auth_token
- **WHEN** a provider sets `anthropic_auth_token` (and not `anthropic_api_key`)
- **THEN** `cc` unsets any pre-existing `ANTHROPIC_API_KEY`, then exports
  `ANTHROPIC_BASE_URL=<base_url>` and `ANTHROPIC_AUTH_TOKEN=<value>`

#### Scenario: Provider with anthropic_api_key
- **WHEN** a provider sets `anthropic_api_key` (and not `anthropic_auth_token`)
- **THEN** `cc` unsets any pre-existing `ANTHROPIC_AUTH_TOKEN`, then exports
  `ANTHROPIC_BASE_URL=<base_url>` and `ANTHROPIC_API_KEY=<value>`

#### Scenario: Both credential fields set
- **WHEN** a provider sets both `anthropic_auth_token` and `anthropic_api_key`
- **THEN** `cc` reports a mutually-exclusive error naming both fields and exits non-zero
  before exporting anything (including in `--dry-run`)

#### Scenario: No credential field
- **WHEN** a provider sets neither credential field (or the effective one is empty)
- **THEN** `cc` reports a missing-credential error naming the accepted fields and exits non-zero

#### Scenario: Provider missing base_url
- **WHEN** a provider entry lacks `base_url`
- **THEN** `cc` reports "Provider '<name>' missing base_url" and exits non-zero

#### Scenario: Pre-existing sibling auth variable
- **WHEN** the parent shell has `ANTHROPIC_AUTH_TOKEN` (or `ANTHROPIC_API_KEY`) exported
- **AND** `cc` loads a provider of the other auth kind
- **THEN** the sibling variable SHALL be unset in the spawned subprocess so the
  configured credential is the only one in effect

#### Scenario: extra_env still wins
- **WHEN** a provider or model declares `extra_env` entries touching `ANTHROPIC_*` auth variables
- **THEN** those entries are exported after the credential export and take precedence

### Requirement: Model Schema

A model entry SHALL contain `enable` (boolean). `extra_env` and `model_name` are optional.

#### Scenario: Model enabled
- **WHEN** `providers[name].models[model].enable` is `true`
- **THEN** `cc` accepts `<provider>:<model>` and exports `ANTHROPIC_MODEL=<model>`

#### Scenario: Model disabled
- **WHEN** `providers[name].models[model].enable` is `false`
- **THEN** `cc` still validates `<provider>:<model>` exists in the list, but `cc list` marks it `(disabled)`

#### Scenario: Model not found
- **WHEN** user runs `cc <provider>:<model>` and `<model>` is not in `providers[name].models`
- **THEN** `cc` reports "Model '<model>' not found under provider '<provider>'", lists available models, and exits non-zero

#### Scenario: Model with model_name
- **WHEN** `providers[name].models[model].model_name` is set to a non-empty string
- **THEN** `cc` SHALL export `ANTHROPIC_MODEL=<model_name_value>` instead of `<model>`

#### Scenario: Model without model_name
- **WHEN** a model entry has no `model_name` field, or it is empty
- **THEN** `cc` SHALL export `ANTHROPIC_MODEL=<model>` (the config key)

### Requirement: extra_env Merging

`cc` SHALL merge `providers[name].extra_env` and `providers[name].models[model].extra_env` at load time, with **model-level winning on key collision**. The merged keys SHALL be exported to the spawned `claude` subprocess.

#### Scenario: Provider-only extra_env
- **WHEN** a provider has `extra_env` but the chosen model has none
- **THEN** only the provider-level keys are exported

#### Scenario: Model-only extra_env
- **WHEN** a model has `extra_env` but its provider has none
- **THEN** only the model-level keys are exported

#### Scenario: Same key in both levels
- **WHEN** both provider and model define `extra_env.MY_VAR`
- **THEN** the model-level value takes precedence; provider-level value is shadowed

#### Scenario: extra_env absent at both levels
- **WHEN** neither provider nor model has an `extra_env` field
- **THEN** no additional env vars beyond `ANTHROPIC_*` are exported (no error)

#### Scenario: Non-scalar extra_env value
- **WHEN** an `extra_env` value is an object or array rather than string / number / boolean
- **THEN** the implementation MAY skip it (current behavior is silent skip via `jq`'s `@sh` on the merged map)

### Requirement: Default Provider:Model

The top-level `default` field SHALL specify the provider:model used when `cc` is invoked with no arguments.

#### Scenario: Default set
- **WHEN** the config has `default` and user runs `cc` with no args
- **THEN** `cc` loads that provider:model

#### Scenario: Default missing
- **WHEN** the config has no `default` field and user runs `cc` with no args
- **THEN** `cc` reports an error and exits non-zero

### Requirement: Backward Compatibility with env.* Files

If `${CC_PATH}/models.config` does not exist but `${CC_PATH}/configs/env.<provider>` does, `cc` SHALL source that file to load environment variables.

#### Scenario: Legacy env.* file present
- **WHEN** `~/.cc/models.config` does not exist but `~/.cc/configs/env.kimi` exists
- **AND** user runs `cc kimi:kimi-for-coding`
- **THEN** `cc` sources `env.kimi` and exports `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` from it
- **AND** sets `ANTHROPIC_MODEL=kimi-for-coding`

This branch is for back-compat only; new installs use the JSON form.

### Requirement: Config Migration

`cc` SHALL automatically upgrade a legacy `models.config` that lacks the top-level
`config_version` field, before dispatching any command (except `--version`).

#### Scenario: Legacy config detected
- **WHEN** `${CC_PATH}/models.config` is valid JSON and has no `config_version` field
- **THEN** `cc` backs it up to `models.config.bak` (timestamped suffix if that exists)
- **AND** renames each provider-level `api_key` field to `anthropic_auth_token`
- **AND** writes `config_version` with the cc version performing the migration
- **AND** prints an upgrade notice naming the backup path and the changes
- **AND** subsequent runs export `ANTHROPIC_AUTH_TOKEN` exactly as before the migration

#### Scenario: Already migrated
- **WHEN** the config already has `config_version`
- **THEN** `cc` performs no write (idempotent: no re-rename, no new backup)

#### Scenario: Migration conflict
- **WHEN** a provider has both legacy `api_key` and `anthropic_auth_token`
- **THEN** `cc` reports a conflict error, leaves the file untouched, and exits non-zero

#### Scenario: Rewrite failure
- **WHEN** the backup copy or the jq rewrite fails
- **THEN** `cc` reports an error, the original file remains in place (no partial write),
  and `cc` exits non-zero

#### Scenario: Invalid JSON during migration
- **WHEN** the config file is not valid JSON
- **THEN** migration is skipped and the normal load path reports the JSON error

### Requirement: jq as the Only External Dependency

`cc` SHALL use `jq` for all JSON parsing.

#### Scenario: jq missing
- **WHEN** `jq` is not installed and user runs `cc`
- **THEN** `cc` prints install instructions and exits non-zero

The only `eval` call in `cc` operates on `jq @sh` output to safely construct shell `export` statements. No other `eval` SHALL be added.
