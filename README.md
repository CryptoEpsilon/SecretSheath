# SecretSheath API

API to store and retrieve secret keys

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/keys/[folder]`: list all keys in a folder (default folder: `default`) 
- GET `api/v1/keys/[folder]/[ID]`: returns details about a single keys with given ID (default folder: `default`)
- POST `api/v1/keys/[folder]`: creates a new key in folder (default folder: `default`)
- GET `api/v1/folders`: list all folders
- GET `api/v1/folders/[folder]`: returns details about a single folder
- POST `api/v1/folders`: creates a new folder

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

Setup development database once:

```shell
rake db:migrate
```
## Execute

Run this API using:

```shell
bundle exec puma -v
```

## Test
Setup test database once:

```shell
RACK_ENV=test rake db:migrate
```

Run the test script:

```shell
RACK_ENV=test bundle exec rake spec
```

## Release check
Before submitting pull requests, please check if specs, style, and dependency audits pass:
```shell
rake release?
```
