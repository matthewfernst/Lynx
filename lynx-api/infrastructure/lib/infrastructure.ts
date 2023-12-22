import { RemovalPolicy, Stack, StackProps } from "aws-cdk-lib";
import { Cors, EndpointType, LambdaIntegration, RestApi } from "aws-cdk-lib/aws-apigateway";
import { Certificate, CertificateValidation } from "aws-cdk-lib/aws-certificatemanager";
import { AttributeType, BillingMode, ProjectionType, Table } from "aws-cdk-lib/aws-dynamodb";
import {
    AnyPrincipal,
    ManagedPolicy,
    PolicyDocument,
    PolicyStatement,
    Role,
    ServicePrincipal
} from "aws-cdk-lib/aws-iam";
import { Code, Function, Runtime } from "aws-cdk-lib/aws-lambda";
import { S3EventSource } from "aws-cdk-lib/aws-lambda-event-sources";
import { Bucket, EventType } from "aws-cdk-lib/aws-s3";

import { Construct } from "constructs";
import { config } from "dotenv";

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

        const usersTable = this.createUsersTable();
        const leaderboardTable = this.createLeaderboardTable();
        const partiesTable = this.createPartiesTable();
        const invitesTable = this.createInvitesTable();

        const profilePictureBucket = this.createProfilePictureBucket();
        const slopesZippedBucket = this.createSlopesZippedBucket();
        const slopesUnzippedBucket = this.createSlopesUnzippedBucket();

        const graphqlLambda = this.createGraphqlAPILambda(
            profilePictureBucket,
            slopesZippedBucket,
            slopesUnzippedBucket,
            usersTable,
            leaderboardTable,
            invitesTable,
            partiesTable
        );

        const api = new RestApi(this, "graphqlAPI", {
            restApiName: "GraphQL API",
            description: "The service endpoint for Lynx's GraphQL API",
            endpointTypes: [EndpointType.REGIONAL],
            domainName: {
                domainName: "production.lynx-api.com",
                certificate: new Certificate(this, "lynxCertificate", {
                    domainName: "*.lynx-api.com",
                    validation: CertificateValidation.fromDns()
                })
            },
            disableExecuteApiEndpoint: true,
            deployOptions: { tracingEnabled: true },
            defaultCorsPreflightOptions: { allowOrigins: Cors.ALL_ORIGINS }
        });

        api.root
            .addResource("graphql")
            .addMethod("POST", new LambdaIntegration(graphqlLambda, { allowTestInvoke: false }));

        this.createReducerLambda(slopesUnzippedBucket, leaderboardTable);
        this.createUnzipperLambda(slopesZippedBucket, slopesUnzippedBucket);
    }

    private createUsersTable(): Table {
        const usersTable = new Table(this, "usersTable", {
            tableName: USERS_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY
        });
        const oauthSecondaryIndices = ["appleId", "googleId"];
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
        const leaderboardTable = new Table(this, "leaderboardTable", {
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
        return new Table(this, "partiesTable", {
            tableName: PARTIES_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY
        });
    }

    private createInvitesTable(): Table {
        return new Table(this, "invitesTable", {
            tableName: INVITES_TABLE,
            partitionKey: { name: "id", type: AttributeType.STRING },
            billingMode: BillingMode.PAY_PER_REQUEST,
            removalPolicy: RemovalPolicy.DESTROY,
            timeToLiveAttribute: "ttl"
        });
    }

    private createProfilePictureBucket(): Bucket {
        const profilePictureBucket = new Bucket(this, "profilePictureBucket", {
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
        return new Bucket(this, "slopesZippedBucket", {
            bucketName: SLOPES_ZIPPED_BUCKET,
            removalPolicy: RemovalPolicy.DESTROY
        });
    }

    private createSlopesUnzippedBucket(): Bucket {
        return new Bucket(this, "slopesUnzippedBucket", {
            bucketName: SLOPES_UNZIPPED_BUCKET,
            removalPolicy: RemovalPolicy.DESTROY
        });
    }

    private createGraphqlAPILambda(
        profilePictureBucket: Bucket,
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket,
        usersTable: Table,
        leaderboardTable: Table,
        invitesTable: Table,
        partiesTable: Table
    ): Function {
        return new Function(this, "graphqlLambda", {
            functionName: "lynx-graphql",
            runtime: Runtime.NODEJS_LATEST,
            handler: "index.handler",
            memorySize: 1024,
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
            environment: {
                ...config().parsed,
                NODE_OPTIONS: "--enable-source-maps"
            }
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
        return new Role(this, "GraphQLAPILambdaRole", {
            roleName: "GraphQLAPILambdaRole",
            assumedBy: new ServicePrincipal("lambda.amazonaws.com"),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName("service-role/AWSLambdaBasicExecutionRole")
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
                            actions: ["dynamodb:Query"],
                            resources: [leaderboardTable.tableArn + "/index/*"]
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

    private createReducerLambda(slopesUnzippedBucket: Bucket, leaderboardTable: Table): Function {
        const reducerLambda = new Function(this, "reducerLambda", {
            functionName: "lynx-reducer",
            runtime: Runtime.NODEJS_LATEST,
            handler: "index.handler",
            memorySize: 1024,
            code: Code.fromAsset("dist/reducer"),
            role: this.createReducerLambdaRole(slopesUnzippedBucket, leaderboardTable),
            environment: { NODE_OPTIONS: "--enable-source-maps" }
        });
        reducerLambda.addEventSource(
            new S3EventSource(slopesUnzippedBucket, { events: [EventType.OBJECT_CREATED] })
        );
        return reducerLambda;
    }

    private createReducerLambdaRole(slopesUnzippedBucket: Bucket, leaderboardTable: Table): Role {
        return new Role(this, "ReducerLambdaRole", {
            roleName: "ReducerLambdaRole",
            assumedBy: new ServicePrincipal("lambda.amazonaws.com"),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName("service-role/AWSLambdaBasicExecutionRole")
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

    private createUnzipperLambda(
        slopesZippedBucket: Bucket,
        slopesUnzippedBucket: Bucket
    ): Function {
        const unzipperLambda = new Function(this, "unzipperLambda", {
            functionName: "lynx-unzipper",
            runtime: Runtime.NODEJS_LATEST,
            handler: "index.handler",
            memorySize: 1024,
            code: Code.fromAsset("dist/unzipper"),
            role: this.createUnzipperLambdaRole(slopesZippedBucket, slopesUnzippedBucket),
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
        return new Role(this, "UnzipperLambdaRole", {
            roleName: "UnzipperLambdaRole",
            assumedBy: new ServicePrincipal("lambda.amazonaws.com"),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName("service-role/AWSLambdaBasicExecutionRole")
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
                            actions: ["s3:PutObject"],
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
}
