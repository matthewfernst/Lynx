# Mountain UI API Lambda

## Deployment To Cloud

In order to deploy the example, you need to run the following command:

```
$ serverless deploy
```

After running deploy, you should see output similar to:

```bash
Deploying mountain-ui-api to stage dev (us-east-1)

✔ Service deployed to stack mountain-ui-api-dev (112s)

functions:
  mountain-ui-api: mountain-ui-api-dev-mountain-ui-api (56 kB)
```

## Invocation

After successful deployment, you can invoke the deployed function by using the following command:

```bash
serverless invoke --function mountain-ui-api
```

## Local Development

You can invoke your function locally by using the following command:

```bash
serverless invoke local --function mountain-ui-api
```
