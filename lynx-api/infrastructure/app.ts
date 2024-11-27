import "source-map-support/register";

import { App, Environment } from "aws-cdk-lib";
import { LynxStack } from "./stacks/lynxApiStack";

const app = new App();
const env: Environment = {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION
};
new LynxStack(app, "LynxStack", { env });
