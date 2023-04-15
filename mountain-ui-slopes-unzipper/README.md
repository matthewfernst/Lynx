# Mountain UI Slopes Unzipper Lambda

## Deployment To Cloud

In order to deploy the example, you need to run the following command:

```
$ serverless deploy
```

After running deploy, you should see output similar to:

```bash
Deploying mountain-ui-slopes-unzipper to stage dev (us-west-1)

✔ Service deployed to stack mountain-ui-slopes-unzipper-dev (112s)

functions:
  mountain-ui-unzipper: mountain-ui-slopes-unzipper-dev-mountain-ui-unzipper (56 kB)
```

## Invocation

After successful deployment, you can invoke the deployed function by using the following command:

```bash
serverless invoke --function mountain-ui-unzipper
```

## Local Development

You can invoke your function locally by using the following command:

```bash
serverless invoke local --function mountain-ui-unzipper
```
