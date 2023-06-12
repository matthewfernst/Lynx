import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import { DYNAMODB_TABLE_NAME_USERS, deleteItem } from "../../aws/dynamodb";
import { deleteObjectsInBucket, profilePictureBucketName } from "../../aws/s3";

const deleteUser = async (_: any, args: {}, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    await deleteObjectsInBucket(profilePictureBucketName, context.userId as string);
    const result = await deleteItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string);
    return result.Attributes;
};

export default deleteUser;
