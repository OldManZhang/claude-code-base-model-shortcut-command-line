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
  "providers": {
    "<name>": {
      "base_url": "<string>",
      "api_key": "<string>",
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

#### Scenario: Valid JSON
- **WHEN** the config file parses as valid JSON
- **THEN** `cc` proceeds with config loading

#### Scenario: Malformed JSON
- **WHEN** the config file is not valid JSON
- **THEN** `jq` emits an error and `cc` exits non-zero

### Requirement: Provider Schema

A provider entry SHALL contain `base_url` and `api_key`.

#### Scenario: Provider complete
- **WHEN** `providers[name].base_url` and `providers[name].api_key` are both set
- **THEN** `cc` exports them as `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` respectively

#### Scenario: Provider missing base_url
- **WHEN** a provider entry lacks `base_url` or `api_key`
- **THEN** `cc` reports "Provider '<name>' not found" and exits non-zero

### Requirement: Model Schema

A model entry SHALL contain `enable` (boolean). `extra_env` is optional.

#### Scenario: Model enabled
- **WHEN** `providers[name].models[model].enable` is `true`
- **THEN** `cc` accepts `<provider>:<model>` and exports `ANTHROPIC_MODEL=<model>`

#### Scenario: Model disabled
- **WHEN** `providers[name].models[model].enable` is `false`
- **THEN** `cc` still validates `<provider>:<model>` exists in the list, but `cc list` marks it `(disabled)`

#### Scenario: Model not found
- **WHEN** user runs `cc <provider>:<model>` and `<model>` is not in `providers[name].models`
- **THEN** `cc` reports "Model '<model>' not found under provider '<provider>'", lists available models, and exits non-zero

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

### Requirement: jq as the Only External Dependency

`cc` SHALL use `jq` for all JSON parsing.

#### Scenario: jq missing
- **WHEN** `jq` is not installed and user runs `cc`
- **THEN** `cc` prints install instructions and exits non-zero

The only `eval` call in `cc` operates on `jq @sh` output to safely construct shell `export` statements. No other `eval` SHALL be added.
