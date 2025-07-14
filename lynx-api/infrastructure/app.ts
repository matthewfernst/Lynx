import {
    ApplicationAssociator,
    TargetApplication
} from "@aws-cdk/aws-servicecatalogappregistry-alpha";
import { App, Environment } from "aws-cdk-lib";
import { LynxAPIStack } from "./stacks/lynxApiStack";

export interface ApplicationEnvironment {
    ALARM_EMAILS: string;
    APPLE_CLIENT_ID: string;
    AUTH_KEY: string;
    ESCAPE_INVITE_HATCH: string;
    FACEBOOK_CLIENT_ID: string;
    FACEBOOK_CLIENT_SECRET: string;
    GOOGLE_CLIENT_ID: string;
    NODE_ENV: string;
}

const app = new App();
const env: Environment = {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION
};

new ApplicationAssociator(app, "LynxAssociatedApplication", {
    applications: [
        TargetApplication.createApplicationStack({
            applicationName: "Lynx",
            applicationDescription: "© Meloncholy Games",
            stackName: "LynxApplicationStack"
        })
    ]
});

// Have to hardcode for now, but this should be application.appRegistryApplication.applicationArn
const applicationArn =
    "arn:aws:resource-groups:us-east-1:170267588697:group/Lynx/028eddv2r6eqzvykir0gy3cwoa";
const tags = { awsApplication: applicationArn };

new LynxAPIStack(app, "LynxStack", { env, tags });
