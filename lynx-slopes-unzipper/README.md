# Mountain UI Slopes Unzipper Lambda

## Deployment To Cloud

In order to deploy the example, you need to run the following command:

```
$ serverless deploy
```

After running deploy, you should see output similar to:

```bash
Deploying lynx-slopes-unzipper to stage dev (us-west-1)

✔ Service deployed to stack lynx-slopes-unzipper-dev (112s)

functions:
  lynx-unzipper: lynx-slopes-unzipper-dev-lynx-unzipper (56 kB)
```

## Invocation

After successful deployment, you can invoke the deployed function by using the following command:

```bash
serverless invoke --function lynx-unzipper
```

## Local Development

You can invoke your function locally by using the following command:

```bash
serverless invoke local --function lynx-unzipper
```
