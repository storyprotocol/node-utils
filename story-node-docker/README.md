# Story-On-Docker
Simple setup guide for running Story Testnet on Docker

# Prerequisites
## Generate a JWT
You can use  a utility like OpenSSL to create the token via command: `openssl rand -hex 32 | tr -d "\n" > "jwtsecret"`.

## Download binaries and create file tree
To make things easy you can run `wget -O - ${S3_CLIENT_ARCHIVE_URL} | tar --warning=no-unknown-keyword -xzvf - --strip-components=1` replacing `${S3_CLIENT_ARCHIVE_URL}` with the S3 bucket link of the `geth/iliad` version you need, each version is listed [here](https://storyprotocol.notion.site/Story-Partner-Testnet-Guide-06ac4cb0f1be4464a32a3d20d95a4a41).

## Edit and copy config files
Inside `config` folder there are config files for `geth` and `iliad` binaries, separated by folders. Just check and edit them as needed. Most people just change `moniker` name, `pruning` options and `external_address` config. Once you edit the config files as you needed, replace default config files for `geth` and `iliad` folders. You can use the following commands:
```
cp config/geth/geth.toml geth/config
cp config/iliad/*.toml iliad/config
```

# Start the node
Just run `docker-compose up -d` to start the containers on detached mode.

## See logs
It's very easy, just run `docker-compose logs -f` to keep watching logs, if you want to see only the latest logs and then keep watching them, you can run `docker-compose logs -f --tail 10`.
