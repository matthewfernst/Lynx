import { Duration, RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import { Cors, EndpointType, LambdaIntegration, RestApi } from "aws-cdk-lib/aws-apigateway";
import { Certificate, CertificateValidation } from "aws-cdk-lib/aws-certificatemanager";
import {
    Alarm,
    ComparisonOperator,
    MathExpression,
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
import { Code, Function as LambdaFunction, Runtime, Tracing } from "aws-cdk-lib/aws-lambda";
import { S3EventSource } from "aws-cdk-lib/aws-lambda-event-sources";
import { RetentionDays } from "aws-cdk-lib/aws-logs";
import { Bucket, EventType } from "aws-cdk-lib/aws-s3";
import { Topic } from "aws-cdk-lib/aws-sns";

import { Construct } from "constructs";
import { config } from "dotenv";

export const USERS_TABLE = "lynx-users";
export const LEADERBOARD_TABLE = "lynx-leaderboard";
export const PARTIES_TABLE = "lynx-parties";
export const INVITES_TABLE = "lynx-invites";

export const PROFILE_PICS_BUCKET = "lynx-profile-pictures";
export const SLOPES_ZIPPED_BUCKET = "lynx-slopes-zipped";
export const SLOPES_UNZIPPED_BUCKET = "lynx-slopes-unzipped";

interface ApplicationEnvironment {
    APPLE_CLIENT_ID: string;
    APPLE_CLIENT_SECRET: string;
    AUTH_KEY: string;
    ESCAPE_INVITE_HATCH: string;
    FACEBOOK_CLIENT_ID: string;
    FACEBOOK_CLIENT_SECRET: string;
    GOOGLE_CLIENT_ID: string;
    NODE_ENV: string;
}

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

        const unzipper = this.createUnzipperLambda(slopesZippedBucket, slopesUnzippedBucket);
        const reducer = this.createReducerLambda(slopesUnzippedBucket, leaderboardTable);
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
            deployOptions: { stageName: "production", tracingEnabled: true },
            defaultCorsPreflightOptions: { allowOrigins: Cors.ALL_ORIGINS },
            endpointExportName: "LynxGraphqlApiEndpoint"
        });

        api.root
            .addResource("graphql")
            .addMethod("POST", new LambdaIntegration(graphql, { allowTestInvoke: false }));

        const alarmTopic = this.createAlarmActions();
        this.createLambdaErrorRateAlarms(alarmTopic, [graphql, reducer, unzipper]);
        this.createAPIErrorRateAlarms(alarmTopic, api);
    }

    private createUsersTable(): Table {
        const usersTable = new Table(this, "lynxUsersTable", {
            tableName: USERS_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY
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
            removalPolicy: RemovalPolicy.DESTROY
        });
    }

    private createInvitesTable(): Table {
        return new Table(this, "lynxInvitesTable", {
            tableName: INVITES_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY,
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
            runtime: Runtime.NODEJS_LATEST,
            handler: "index.handler",
            memorySize: 2048,
            timeout: Duration.seconds(29),
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
            tracing: Tracing.ACTIVE,
            logRetention: RetentionDays.ONE_MONTH,
            environment: { ...env, NODE_OPTIONS: "--enable-source-maps" }
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
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket
    ): LambdaFunction {
        const unzipperLambda = new LambdaFunction(this, "lynxUnzipperLambda", {
            functionName: "lynx-unzipper",
            runtime: Runtime.NODEJS_LATEST,
            handler: "index.handler",
            memorySize: 2048,
            timeout: Duration.seconds(60),
            code: Code.fromAsset("dist/unzipper"),
            role: this.createUnzipperLambdaRole(slopesZippedBucket, slopesUnzippedBucket),
            tracing: Tracing.ACTIVE,
            logRetention: RetentionDays.ONE_MONTH,
            environment: { NODE_OPTIONS: "--enable-source-maps" }
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
        slopesUnzippedBucket: Bucket,
        leaderboardTable: Table
    ): LambdaFunction {
        const reducerLambda = new LambdaFunction(this, "lynxReducerLambda", {
            functionName: "lynx-reducer",
            runtime: Runtime.NODEJS_LATEST,
            handler: "index.handler",
            memorySize: 2048,
            timeout: Duration.seconds(60),
            code: Code.fromAsset("dist/reducer"),
            role: this.createReducerLambdaRole(slopesUnzippedBucket, leaderboardTable),
            tracing: Tracing.ACTIVE,
            logRetention: RetentionDays.ONE_MONTH,
            environment: { NODE_OPTIONS: "--enable-source-maps" }
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

    private createLambdaErrorRateAlarms(alarmTopic: Topic, lambdas: LambdaFunction[]): Alarm[] {
        return lambdas.map((lambda) => {
            const alarm = new Alarm(this, `${lambda.node.id}-sucessRate`, {
                alarmName: `${lambda.functionName} Success Rate`,
                metric: new MathExpression({
                    label: "Success Rate",
                    expression: "1 - errors / invocations",
                    usingMetrics: {
                        errors: lambda.metricErrors(),
                        invocations: lambda.metricInvocations()
                    },
                    period: Duration.minutes(1)
                }),
                threshold: 0.99,
                comparisonOperator: ComparisonOperator.LESS_THAN_THRESHOLD,
                evaluationPeriods: 5,
                treatMissingData: TreatMissingData.NOT_BREACHING
            });
            alarm.addAlarmAction(new SnsAction(alarmTopic));
            return alarm;
        });
    }

    private createAPIErrorRateAlarms(alarmTopic: Topic, api: RestApi): Alarm[] {
        const errorRateMetrics = [api.metricClientError(), api.metricServerError()];
        return errorRateMetrics.map((metric) => {
            const alarm = new Alarm(this, `${api.node.id}-${metric.metricName}`, {
                alarmName: `lynx-${metric.metricName}`,
                metric: new MathExpression({
                    label: "Success Rate",
                    expression: "1 - errors / invocations",
                    usingMetrics: {
                        errors: metric,
                        invocations: api.metricCount()
                    },
                    period: Duration.minutes(1)
                }),
                threshold: 0.99,
                comparisonOperator: ComparisonOperator.LESS_THAN_THRESHOLD,
                evaluationPeriods: 5,
                treatMissingData: TreatMissingData.NOT_BREACHING
            });
            alarm.addAlarmAction(new SnsAction(alarmTopic));
            return alarm;
        });
    }

    private createAlarmActions() {
        return new Topic(this, "lynxAlarmTopic", { topicName: "lynx-alarms" });
    }
}
