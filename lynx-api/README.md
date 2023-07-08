# Mountain UI API Lambda

## Deployment To Cloud

In order to deploy the example, you need to run the following command:

```
$ serverless deploy
```

After running deploy, you should see output similar to:

```bash
Deploying lynx-api to stage dev (us-west-1)

✔ Service deployed to stack lynx-api-dev (112s)

functions:
  lynx-api: lynx-api-dev-lynx-api (56 kB)
```

## Invocation

After successful deployment, you can invoke the deployed function by using the following command:

```bash
serverless invoke --function lynx-api
```

## Local Development

You can invoke your function locally by using the following command:

```bash
serverless invoke local --function lynx-api
```
