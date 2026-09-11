# OWLUpdate

## Setup
```sh
./genkey.sh
docker compose build
docker compose up -d
docker compose restart backend-api
```

Open [http://localhost:9003](http://localhost:9003)

## How to use

1. Create user

Create your own account with user name, email address, and password.
In this demo, we do not use these credentials in any pages except Login/Signup.

2. Create a repository

Create a first repository with repository name, description (optional) and
```remote_origin``` (optional).

You can use this sample dataset [https://github.com/isskj2020/owl-update-sample-data](https://github.com/isskj2020/owl-update-sample-data).

3. Click ```{owl file}.xml``` and edit priorities.

