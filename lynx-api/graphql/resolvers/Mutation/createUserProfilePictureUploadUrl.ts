import { createSignedUploadUrl, profilePictureBucketName } from "../../aws/s3";
import { Context } from "../../index";
import { checkHasUserId, checkIsLoggedInAndHasValidInvite } from "../../auth";

interface Args {}

const createUserProfilePictureUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<string> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    console.log(`Creating Profile Picture Upload URL For User ID ${userId}`);
    return await createSignedUploadUrl(profilePictureBucketName, userId);
};

export default createUserProfilePictureUploadUrl;
