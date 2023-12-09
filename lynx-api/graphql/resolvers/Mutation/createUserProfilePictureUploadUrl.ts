import { createSignedUploadUrl, profilePictureBucketName } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";

interface Args {}

const createUserProfilePictureUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<string> => {
    await checkIsLoggedInAndHasValidInvite(context);
    console.log(`Creating Profile Picture Upload URL For User ID ${context.userId}`);
    return await createSignedUploadUrl(profilePictureBucketName, context.userId as string);
};

export default createUserProfilePictureUploadUrl;
