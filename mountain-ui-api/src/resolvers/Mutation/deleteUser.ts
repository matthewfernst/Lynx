import { Context } from "../../index";
import { checkIsLoggedInAndHasValidToken } from "../../auth";
import { DYNAMODB_TABLE_NAME_USERS, deleteItem } from "../../aws/dynamodb";
import {
    deleteObjectsInBucket,
    fromRunRecordsBucket,
    profilePictureBucketName,
    toRunRecordsBucket
} from "../../aws/s3";

const deleteUser = async (_: any, args: {}, context: Context, info: any) => {
    await checkIsLoggedInAndHasValidToken(context);
    await deleteObjectsInBucket(profilePictureBucketName, context.userId as string);
    await deleteObjectsInBucket(fromRunRecordsBucket, context.userId as string);
    await deleteObjectsInBucket(toRunRecordsBucket, context.userId as string);
    const result = await deleteItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string);
    return result.Attributes;
};

export default deleteUser;
