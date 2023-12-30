# Lynx API

## About

This is the API for the Lynx application. It contains serveral AWS Lambda functions that are deployed using CDK. There are additional resources as well including DynamoDB tables for keeping track of users and their data, S3 buckets for keeping track of images and other files, and alarms and topics for monitoring and notifications.

## Lambdas

### GraphQL

The primary entrypoint for the API is a GraphQL based lambda that handles all requests. It is built using Apollo Server and uses dataloaders to index data from DynamoDB and S3. It is hooked up to a custom domain inside API-Gateway. It supports all defined operations in the schema.graphql file.

### Reducer

The reducer lambda is used to populate the leaderboard table in real time as records are uploaded to S3 via the GraphQL API. It utilizes timeframe based logic to sort users and determine their rank. It is triggered by S3 events to the unzipped bucket.

### Unzipper

The unzipper lambda is used to unzip raw slopes files that are uploaded to S3 via the GraphQL API. It is triggered by S3 events to the zipped bucket.

## Quick Start

Install modules, build, and deploy the application to AWS. It will find your AWS config file and deploy the stack to the account and region you prefer using your credentials.

```bash
npm install
npm run build
npm run deploy
```

## Environment Variables

The following environment variables can be overriden to configure the application for your environment.

ALARM_EMAILS: A comma separated list of emails to send alarms notifications to.
APPLE_CLIENT_ID: The client id for the Apple OAuth provider.
APPLE_CLIENT_SECRET: The client secret for the Apple OAuth provider.
AUTH_KEY: The key used to sign JWT tokens.
ESCAPE_INVITE_HATCH: A backdoor to allow users to join the application without an invite code (for first user setup).
FACEBOOK_CLIENT_ID: The client id for the Facebook OAuth provider.
FACEBOOK_CLIENT_SECRET: The client secret for the Facebook OAuth provider.
GOOGLE_CLIENT_ID: The client id for the Google OAuth provider.
NODE_ENV: The environment the application is running in.
