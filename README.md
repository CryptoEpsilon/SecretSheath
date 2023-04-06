# SecretSheath API

API to store and retrieve secret keys

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/keys/`: returns all confiugration IDs
- GET `api/v1/keys/[ID]`: returns details about a single keys with given ID
- POST `api/v1/keys/`: creates a new keys

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
bundle exec puma -v
```
