# Lynx API

Serverless backend infrastructure for the Lynx iOS application, built with AWS CDK and TypeScript.

## About

This is the backend API for the Lynx application. It provides a serverless architecture using AWS services including Lambda, DynamoDB, S3, API Gateway, and EventBridge. The infrastructure is defined as code using AWS CDK and deployed to AWS.

## Architecture

```
┌─────────────┐
│  iOS App    │
└──────┬──────┘
       │ GraphQL
       ↓
┌─────────────────┐
│  API Gateway    │
└──────┬──────────┘
       │
       ↓
┌─────────────────┐      ┌──────────────┐
│  GraphQL Lambda │─────→│  DynamoDB    │
│  (Apollo Server)│      │  - Users     │
└─────────┬───────┘      │  - Parties   │
          │              │  - Invites   │
          │              │  - Leaderboard│
          ↓              └──────────────┘
┌─────────────────┐
│   S3 Buckets    │
│  - Zipped       │
│  - Unzipped     │
│  - Profile Pics │
└─────────┬───────┘
          │
          │ S3 Events
          ↓
┌─────────────────┐      ┌──────────────┐
│ Unzipper Lambda │─────→│ EventBridge  │
└─────────────────┘      └──────┬───────┘
                                │
                                ↓
                         ┌──────────────┐
                         │   Reducer    │
                         │   Lambda     │
                         └──────────────┘
```

## Lambda Functions

### 1. GraphQL Lambda (`graphql/`)

**Purpose:** Primary API entrypoint handling all GraphQL operations

**Technology Stack:**
- Apollo Server for GraphQL
- DataLoader for efficient batch loading
- JWT for authentication
- OAuth integration (Apple, Google, Facebook)

**Key Features:**
- User authentication and profile management
- File upload URL generation (S3 presigned URLs)
- Party/group management
- Leaderboard queries
- User statistics aggregation

**Resolvers:**
- **Mutations:** `createParty`, `joinParty`, `oauthSignIn`, `editUser`, `deleteUser`, etc.
- **Queries:** `getUser`, `getParty`, `getLeaderboard`, `getUserStats`, etc.
- **Field Resolvers:** Nested data loading for users, parties, and statistics

**Directory Structure:**
```
graphql/
├── index.ts              # Lambda handler and Apollo Server setup
├── auth.ts               # JWT and OAuth authentication
├── dataloaders.ts        # DataLoader instances for batch loading
├── types.ts              # TypeScript type definitions
├── aws/                  # AWS service clients (DynamoDB, S3)
└── resolvers/
    ├── Mutation/         # Mutation resolvers
    ├── Query/            # Query resolvers
    ├── User/             # User field resolvers
    ├── Party/            # Party field resolvers
    └── UserStats/        # Statistics field resolvers
```

### 2. Reducer Lambda (`reducer/`)

**Purpose:** Real-time leaderboard calculation and ranking

**Trigger:** S3 events when new unzipped slope files are added

**Key Features:**
- Parses slope data from S3
- Calculates user statistics (distance, vertical, top speed)
- Updates leaderboard rankings by timeframe (daily, weekly, monthly, all-time)
- Supports both global and party-specific leaderboards

**Processing Flow:**
1. Receives S3 event notification
2. Fetches and parses slope file JSON
3. Aggregates statistics per user
4. Calculates rankings within timeframes
5. Updates DynamoDB leaderboard table

### 3. Unzipper Lambda (`unzipper/`)

**Purpose:** Extract and process uploaded slope files

**Trigger:** S3 events when zipped files are uploaded

**Key Features:**
- Unzips .slopes files
- Extracts individual run JSON data
- Uploads unzipped files to processing bucket
- Validates file structure

## Infrastructure (`infrastructure/`)

AWS resources defined using CDK TypeScript constructs:

**Resources:**
- API Gateway with custom domain and CORS
- Lambda functions with appropriate IAM roles
- DynamoDB tables with GSIs for efficient queries
- S3 buckets with event notifications
- CloudWatch alarms and SNS topics for monitoring
- VPC and security groups (if needed)

**Directory Structure:**
```
infrastructure/
├── app.ts                # CDK app entry point
└── stacks/
    └── lynx-stack.ts     # Main stack definition
```

## Database Schema (DynamoDB)

### Users Table
- **Primary Key:** `userId` (OAuth provider ID)
- **Attributes:** email, firstName, lastName, profilePictureUrl, oauthType, parties
- **GSI:** Email index for user lookup

### Parties Table
- **Primary Key:** `partyId` (UUID)
- **Attributes:** name, managerId, userIds, inviteCode
- **GSI:** Invite code index

### Leaderboard Table
- **Primary Key:** `leaderboardId` (composite: timeframe#partyId)
- **Attributes:** rankings (user statistics sorted by rank)
- **Timeframes:** daily, weekly, monthly, all-time

### Invites Table
- **Primary Key:** `inviteId` (UUID)
- **Attributes:** fromUserId, toUserId, partyId, status

## Quick Start

### Prerequisites
- Node.js 18+ and npm
- AWS CLI configured with credentials
- AWS CDK CLI (`npm install -g aws-cdk`)

### Installation

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy to AWS (first time)
npm run deploy

# Update existing deployment
npm run deploy
```

### Development Commands

```bash
# Build TypeScript
npm run build

# Run tests
npm test

# Lint code
npm run lint

# Format code
npm run format

# Generate GraphQL types
npm run generate

# Watch mode for development
npm run watch
```

## Environment Variables

The following environment variables configure the application. These can be set in the CDK stack or AWS Systems Manager Parameter Store.

| Variable | Description | Required |
|----------|-------------|----------|
| `APPLE_CLIENT_ID` | Apple OAuth provider client ID | Yes |
| `AUTH_KEY` | Secret key used to sign JWT tokens | Yes |
| `ESCAPE_INVITE_HATCH` | Backdoor code to bypass invite requirement (for initial setup) | No |
| `FACEBOOK_CLIENT_ID` | Facebook OAuth provider client ID | Yes |
| `FACEBOOK_CLIENT_SECRET` | Facebook OAuth provider client secret | Yes |
| `GOOGLE_CLIENT_ID` | Google OAuth provider client ID | Yes |
| `NODE_ENV` | Environment (development, staging, production) | Yes |
| `DYNAMODB_USERS_TABLE` | DynamoDB users table name | Auto-set by CDK |
| `DYNAMODB_PARTIES_TABLE` | DynamoDB parties table name | Auto-set by CDK |
| `DYNAMODB_LEADERBOARD_TABLE` | DynamoDB leaderboard table name | Auto-set by CDK |
| `S3_ZIPPED_BUCKET` | S3 bucket for zipped files | Auto-set by CDK |
| `S3_UNZIPPED_BUCKET` | S3 bucket for unzipped files | Auto-set by CDK |

## GraphQL Schema

The GraphQL schema is located in `Lynx-SwiftUI/Apollo/schema.graphql` in the main repository. It defines:

**Types:**
- `User` - User profile and authentication
- `Party` - Group/party management
- `PartyInvite` - Party invitation system
- `UserStats` - Aggregated user statistics
- `Log` - Individual slope run data
- `Leaderboard` - Rankings and statistics

**Mutations:**
- Authentication: `oauthSignIn`, `refreshLynxToken`
- Users: `editUser`, `deleteUser`, `combineOAuthAccounts`
- Parties: `createParty`, `joinParty`, `leaveParty`, `editParty`, `deleteParty`
- Invites: `createPartyInvite`, `deletePartyInvite`
- Uploads: `createUserRecordUploadUrl`, `createUserProfilePictureUploadUrl`

**Queries:**
- `getUser` - Fetch user profile
- `getUserByEmail` - Lookup user by email
- `getParty` - Fetch party details
- `getParties` - List user's parties
- `getLeaderboard` - Fetch leaderboard rankings

## Deployment

### Initial Deployment

1. Configure AWS credentials:
```bash
aws configure
```

2. Bootstrap CDK (first time only):
```bash
npx cdk bootstrap
```

3. Deploy the stack:
```bash
npm run deploy
```

### Updating Existing Stack

```bash
npm run build
npm run deploy
```

### Stack Outputs

After deployment, CDK will output:
- API Gateway endpoint URL
- Custom domain name (if configured)
- S3 bucket names
- DynamoDB table names

## Monitoring

CloudWatch metrics and alarms are automatically configured for:
- Lambda execution errors and duration
- API Gateway 4xx/5xx errors
- DynamoDB throttling
- S3 bucket size

Logs are available in CloudWatch Logs under:
- `/aws/lambda/graphql-lambda`
- `/aws/lambda/reducer-lambda`
- `/aws/lambda/unzipper-lambda`

## Testing

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Contributing

See the main [repository README](../README.md) for contribution guidelines.

## Troubleshooting

### Lambda Cold Starts
- Configure provisioned concurrency for production
- Optimize bundle size using esbuild

### DynamoDB Throttling
- Review and adjust read/write capacity
- Use DynamoDB on-demand pricing for variable load

### S3 Event Processing
- Ensure Lambda has sufficient timeout (current: 30s)
- Monitor dead letter queues for failed events

## License

See LICENSE file in the main repository.  
