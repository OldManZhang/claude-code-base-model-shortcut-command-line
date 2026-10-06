# configuration Specification

## MODIFIED Requirements

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
(e.g. `"0.2.5"`).

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

## ADDED Requirements

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
