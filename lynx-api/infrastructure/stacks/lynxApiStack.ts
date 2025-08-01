import { Duration, RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import {
    Cors,
    EndpointType,
    LambdaIntegration,
    MethodLoggingLevel,
    RestApi
} from "aws-cdk-lib/aws-apigateway";
import { Certificate, CertificateValidation } from "aws-cdk-lib/aws-certificatemanager";
import {
    Alarm,
    ComparisonOperator,
    MathExpression,
    Metric,
    TreatMissingData
} from "aws-cdk-lib/aws-cloudwatch";
import { SnsAction } from "aws-cdk-lib/aws-cloudwatch-actions";
import { AttributeType, BillingMode, ProjectionType, Table } from "aws-cdk-lib/aws-dynamodb";
import {
    AnyPrincipal,
    ManagedPolicy,
    PolicyDocument,
    PolicyStatement,
    Role,
    ServicePrincipal
} from "aws-cdk-lib/aws-iam";
import {
    ApplicationLogLevel,
    Code,
    FunctionProps,
    Function as LambdaFunction,
    LoggingFormat,
    Runtime,
    SystemLogLevel,
    Tracing
} from "aws-cdk-lib/aws-lambda";
import { S3EventSource } from "aws-cdk-lib/aws-lambda-event-sources";
import { RetentionDays } from "aws-cdk-lib/aws-logs";
import { Bucket, EventType } from "aws-cdk-lib/aws-s3";
import { Topic } from "aws-cdk-lib/aws-sns";
import { EmailSubscription } from "aws-cdk-lib/aws-sns-subscriptions";

import { Construct } from "constructs";
import { config } from "dotenv";

import { ApplicationEnvironment } from "../app";

export const USERS_TABLE = "lynx-users";
export const LEADERBOARD_TABLE = "lynx-leaderboard";
export const PARTIES_TABLE = "lynx-parties";
export const INVITES_TABLE = "lynx-invites";

export const PROFILE_PICS_BUCKET = "lynx-profile-pictures";
export const SLOPES_ZIPPED_BUCKET = "lynx-slopes-zipped";
export const SLOPES_UNZIPPED_BUCKET = "lynx-slopes-unzipped";

export class LynxAPIStack extends Stack {
    constructor(scope: Construct, id: string, props?: StackProps) {
        super(scope, id, props);

        const env = config().parsed as ApplicationEnvironment | undefined;
        if (!env) {
            throw new Error("Environment variables not found");
        }

        const usersTable = this.createUsersTable();
        const leaderboardTable = this.createLeaderboardTable();
        const partiesTable = this.createPartiesTable();
        const invitesTable = this.createInvitesTable();

        const profilePictureBucket = this.createProfilePictureBucket();
        const slopesZippedBucket = this.createSlopesZippedBucket();
        const slopesUnzippedBucket = this.createSlopesUnzippedBucket();

        const unzipper = this.createUnzipperLambda(env, slopesZippedBucket, slopesUnzippedBucket);
        const reducer = this.createReducerLambda(env, slopesUnzippedBucket, leaderboardTable);
        const graphql = this.createGraphqlAPILambda(
            env,
            profilePictureBucket,
            slopesZippedBucket,
            slopesUnzippedBucket,
            usersTable,
            leaderboardTable,
            invitesTable,
            partiesTable
        );

        const api = new RestApi(this, "lynxGraphqlRestApi", {
            restApiName: "Lynx GraphQL API",
            description: "The service endpoint for Lynx's GraphQL API",
            domainName: {
                domainName: "production.lynx-api.com",
                endpointType: EndpointType.EDGE,
                certificate: new Certificate(this, "lynxCertificate", {
                    domainName: "lynx-api.com",
                    subjectAlternativeNames: ["*.lynx-api.com"],
                    validation: CertificateValidation.fromDns()
                })
            },
            disableExecuteApiEndpoint: true,
            deployOptions: {
                stageName: "production",
                tracingEnabled: true,
                loggingLevel: MethodLoggingLevel.ERROR
            },
            defaultCorsPreflightOptions: { allowOrigins: Cors.ALL_ORIGINS },
            endpointExportName: "LynxGraphqlApiEndpoint"
        });

        api.root
            .addResource("graphql")
            .addMethod("POST", new LambdaIntegration(graphql, { allowTestInvoke: false }));

        const alarmTopic = this.createAlarmActions(env);
        this.createLambdaErrorRateAlarm(alarmTopic, [graphql, reducer, unzipper]);
        this.createRestAPIErrorRateAlarm(alarmTopic, api);
    }

    private createUsersTable(): Table {
        const usersTable = new Table(this, "lynxUsersTable", {
            tableName: USERS_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY,
            deletionProtection: true
        });
        const oauthSecondaryIndices = ["appleId", "googleId", "facebookId"];
        oauthSecondaryIndices.map((indexName) => {
            usersTable.addGlobalSecondaryIndex({
                indexName,
                partitionKey: { name: indexName, type: AttributeType.STRING },
                projectionType: ProjectionType.INCLUDE,
                nonKeyAttributes: ["validatedInvite"]
            });
        });
        return usersTable;
    }

    private createLeaderboardTable(): Table {
        const leaderboardTable = new Table(this, "lynxLeaderboardTable", {
            tableName: LEADERBOARD_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            sortKey: { name: "timeframe", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY,
            deletionProtection: true,
            timeToLiveAttribute: "ttl"
        });
        const timeframeSecondaryIndices = ["distance", "runCount", "topSpeed", "verticalDistance"];
        timeframeSecondaryIndices.map((indexName) => {
            leaderboardTable.addGlobalSecondaryIndex({
                indexName,
                partitionKey: { name: "timeframe", type: AttributeType.STRING },
                sortKey: { name: indexName, type: AttributeType.NUMBER },
                projectionType: ProjectionType.INCLUDE,
                nonKeyAttributes: ["id"]
            });
        });
        return leaderboardTable;
    }

    private createPartiesTable(): Table {
        return new Table(this, "lynxPartiesTable", {
            tableName: PARTIES_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY,
            deletionProtection: true
        });
    }

    private createInvitesTable(): Table {
        return new Table(this, "lynxInvitesTable", {
            tableName: INVITES_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY,
            deletionProtection: true,
            timeToLiveAttribute: "ttl"
        });
    }

    private createProfilePictureBucket(): Bucket {
        const profilePictureBucket = new Bucket(this, "lynxProfilePictureBucket", {
            bucketName: PROFILE_PICS_BUCKET,
            blockPublicAccess: {
                blockPublicAcls: true,
                blockPublicPolicy: false,
                ignorePublicAcls: true,
                restrictPublicBuckets: false
            },
            removalPolicy: RemovalPolicy.DESTROY
        });
        profilePictureBucket.addToResourcePolicy(
            new PolicyStatement({
                principals: [new AnyPrincipal()],
                actions: ["s3:GetObject"],
                resources: [profilePictureBucket.arnForObjects("*")]
            })
        );
        return profilePictureBucket;
    }

    private createSlopesZippedBucket(): Bucket {
        return new Bucket(this, "lynxSlopesZippedBucket", {
            bucketName: SLOPES_ZIPPED_BUCKET,
            removalPolicy: RemovalPolicy.DESTROY
        });
    }

    private createSlopesUnzippedBucket(): Bucket {
        return new Bucket(this, "lynxSlopesUnzippedBucket", {
            bucketName: SLOPES_UNZIPPED_BUCKET,
            removalPolicy: RemovalPolicy.DESTROY
        });
    }

    private createGraphqlAPILambda(
        env: ApplicationEnvironment,
        profilePictureBucket: Bucket,
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket,
        usersTable: Table,
        leaderboardTable: Table,
        invitesTable: Table,
        partiesTable: Table
    ): LambdaFunction {
        return new LambdaFunction(this, "lynxGraphqlLambda", {
            functionName: "lynx-graphql",
            runtime: Runtime.NODEJS_22_X,
            handler: "index.handler",
            code: Code.fromAsset("dist/graphql"),
            role: this.createGraphqlAPILambdaRole(
                profilePictureBucket,
                slopesZippedBucket,
                slopesUnzippedBucket,
                usersTable,
                leaderboardTable,
                invitesTable,
                partiesTable
            ),
            ...this.createLambdaParams(env)
        });
    }

    private createGraphqlAPILambdaRole(
        profilePictureBucket: Bucket,
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket,
        usersTable: Table,
        leaderboardTable: Table,
        invitesTable: Table,
        partiesTable: Table
    ): Role {
        return new Role(this, "lynxGraphQLApiLambdaRole", {
            roleName: "LynxGraphQLAPILambdaRole",
            assumedBy: new ServicePrincipal("lambda.amazonaws.com"),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName("service-role/AWSLambdaBasicExecutionRole"),
                ManagedPolicy.fromAwsManagedPolicyName("AWSXrayWriteOnlyAccess")
            ],
            inlinePolicies: {
                BucketAccessPolicy: new PolicyDocument({
                    statements: [
                        new PolicyStatement({
                            actions: [
                                "s3:ListBucket",
                                "s3:GetObject",
                                "s3:PutObject",
                                "s3:DeleteObject"
                            ],
                            resources: [
                                profilePictureBucket.bucketArn,
                                profilePictureBucket.arnForObjects("*")
                            ]
                        }),
                        new PolicyStatement({
                            actions: ["s3:PutObject", "s3:DeleteObject"],
                            resources: [
                                slopesZippedBucket.bucketArn,
                                slopesZippedBucket.arnForObjects("*")
                            ]
                        }),
                        new PolicyStatement({
                            actions: ["s3:ListBucket", "s3:GetObject", "s3:DeleteObject"],
                            resources: [
                                slopesUnzippedBucket.bucketArn,
                                slopesUnzippedBucket.arnForObjects("*")
                            ]
                        })
                    ]
                }),
                TableAccessPolicy: new PolicyDocument({
                    statements: [
                        new PolicyStatement({
                            actions: ["dynamodb:DeleteItem", "dynamodb:Query", "dynamodb:GetItem"],
                            resources: [
                                leaderboardTable.tableArn,
                                leaderboardTable.tableArn + "/index/*"
                            ]
                        }),
                        new PolicyStatement({
                            actions: [
                                "dynamodb:GetItem",
                                "dynamodb:DeleteItem",
                                "dynamodb:PutItem",
                                "dynamodb:Query",
                                "dynamodb:UpdateItem"
                            ],
                            resources: [usersTable.tableArn, usersTable.tableArn + "/index/*"]
                        }),
                        new PolicyStatement({
                            actions: [
                                "dynamodb:GetItem",
                                "dynamodb:DeleteItem",
                                "dynamodb:PutItem"
                            ],
                            resources: [invitesTable.tableArn, partiesTable.tableArn]
                        })
                    ]
                })
            }
        });
    }

    private createUnzipperLambda(
        env: ApplicationEnvironment,
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket
    ): LambdaFunction {
        const unzipperLambda = new LambdaFunction(this, "lynxUnzipperLambda", {
            functionName: "lynx-unzipper",
            runtime: Runtime.NODEJS_22_X,
            handler: "index.handler",
            code: Code.fromAsset("dist/unzipper"),
            role: this.createUnzipperLambdaRole(slopesZippedBucket, slopesUnzippedBucket),
            ...this.createLambdaParams(env)
        });
        unzipperLambda.addEventSource(
            new S3EventSource(slopesZippedBucket, { events: [EventType.OBJECT_CREATED] })
        );
        return unzipperLambda;
    }

    private createUnzipperLambdaRole(
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket
    ): Role {
        return new Role(this, "lynxUnzipperLambdaRole", {
            roleName: "LynxUnzipperLambdaRole",
            assumedBy: new ServicePrincipal("lambda.amazonaws.com"),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName("service-role/AWSLambdaBasicExecutionRole"),
                ManagedPolicy.fromAwsManagedPolicyName("AWSXrayWriteOnlyAccess")
            ],
            inlinePolicies: {
                BucketAccessPolicy: new PolicyDocument({
                    statements: [
                        new PolicyStatement({
                            actions: ["s3:GetObject", "s3:DeleteObject"],
                            resources: [
                                slopesZippedBucket.bucketArn,
                                slopesZippedBucket.arnForObjects("*")
                            ]
                        }),
                        new PolicyStatement({
                            actions: ["s3:GetObject", "s3:ListBucket", "s3:PutObject"],
                            resources: [
                                slopesUnzippedBucket.bucketArn,
                                slopesUnzippedBucket.arnForObjects("*")
                            ]
                        })
                    ]
                })
            }
        });
    }

    private createReducerLambda(
        env: ApplicationEnvironment,
        slopesUnzippedBucket: Bucket,
        leaderboardTable: Table
    ): LambdaFunction {
        const reducerLambda = new LambdaFunction(this, "lynxReducerLambda", {
            functionName: "lynx-reducer",
            runtime: Runtime.NODEJS_22_X,
            handler: "index.handler",
            code: Code.fromAsset("dist/reducer"),
            role: this.createReducerLambdaRole(slopesUnzippedBucket, leaderboardTable),
            ...this.createLambdaParams(env)
        });
        reducerLambda.addEventSource(
            new S3EventSource(slopesUnzippedBucket, { events: [EventType.OBJECT_CREATED] })
        );
        return reducerLambda;
    }

    private createReducerLambdaRole(slopesUnzippedBucket: Bucket, leaderboardTable: Table): Role {
        return new Role(this, "lynxReducerLambdaRole", {
            roleName: "LynxReducerLambdaRole",
            assumedBy: new ServicePrincipal("lambda.amazonaws.com"),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName("service-role/AWSLambdaBasicExecutionRole"),
                ManagedPolicy.fromAwsManagedPolicyName("AWSXrayWriteOnlyAccess")
            ],
            inlinePolicies: {
                BucketAccessPolicy: new PolicyDocument({
                    statements: [
                        new PolicyStatement({
                            actions: ["s3:GetObject"],
                            resources: [
                                slopesUnzippedBucket.bucketArn,
                                slopesUnzippedBucket.arnForObjects("*")
                            ]
                        }),
                        new PolicyStatement({
                            actions: ["dynamodb:UpdateItem"],
                            resources: [leaderboardTable.tableArn]
                        })
                    ]
                })
            }
        });
    }

    private createLambdaParams(env: ApplicationEnvironment): Partial<FunctionProps> {
        return {
            memorySize: 2048,
            timeout: Duration.seconds(29),
            tracing: Tracing.ACTIVE,
            logRetention: RetentionDays.ONE_MONTH,
            loggingFormat: LoggingFormat.JSON,
            applicationLogLevelV2: ApplicationLogLevel.WARN,
            systemLogLevelV2: SystemLogLevel.WARN,
            environment: { ...env, NODE_OPTIONS: "--enable-source-maps" }
        };
    }

    private createLambdaErrorRateAlarm(alarmTopic: Topic, lambdas: LambdaFunction[]): Alarm {
        const totalErrors = lambdas.map((lambda) => lambda.metricErrors());
        const totalInvocations = lambdas.map((lambda) => lambda.metricInvocations());

        const metricMap: Record<string, Metric> = {};
        totalErrors.forEach((metric, i) => (metricMap[`e${i}`] = metric));
        totalInvocations.forEach((metric, i) => (metricMap[`i${i}`] = metric));

        const errorSumExpr = totalErrors.map((_, i) => `e${i}`).join(" + ");
        const invocationSumExpr = totalInvocations.map((_, i) => `i${i}`).join(" + ");
        const successRateExpr = `(1 - (${errorSumExpr}) / (${invocationSumExpr})) * 100`;

        const alarm = new Alarm(this, `LynxLambdasSuccessRateAlarm`, {
            alarmName: "Lynx Lambdas Success Rate",
            metric: new MathExpression({
                label: "Lynx Lambdas Success Rate",
                expression: successRateExpr,
                usingMetrics: metricMap,
                period: Duration.minutes(5)
            }),
            threshold: 99.99,
            comparisonOperator: ComparisonOperator.LESS_THAN_THRESHOLD,
            evaluationPeriods: 1,
            treatMissingData: TreatMissingData.NOT_BREACHING
        });

        alarm.addAlarmAction(new SnsAction(alarmTopic));
        return alarm;
    }

    private createRestAPIErrorRateAlarm(alarmTopic: Topic, api: RestApi): Alarm {
        const errorRateExpression = new MathExpression({
            label: "Lynx API Success Rate",
            expression: "(1 - (clientErrors + serverErrors) / invocations) * 100",
            usingMetrics: {
                clientErrors: api.metricClientError(),
                serverErrors: api.metricServerError(),
                invocations: api.metricCount()
            },
            period: Duration.minutes(5)
        });

        const alarm = new Alarm(this, `LynxRestApiSuccessRateAlarm`, {
            alarmName: "Lynx Rest API Success Rate",
            metric: errorRateExpression,
            threshold: 99.99,
            comparisonOperator: ComparisonOperator.LESS_THAN_THRESHOLD,
            evaluationPeriods: 1,
            treatMissingData: TreatMissingData.NOT_BREACHING
        });

        alarm.addAlarmAction(new SnsAction(alarmTopic));
        return alarm;
    }

    private createAlarmActions(env: ApplicationEnvironment): Topic {
        const topic = new Topic(this, "lynxAlarmTopic", { topicName: "lynx-alarms" });
        for (const email of env.ALARM_EMAILS.split(",")) {
            topic.addSubscription(new EmailSubscription(email));
        }
        return topic;
    }
}
