import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";

const fromBucket = "mountain-ui-app-profile-pictures";

interface Args {}

const createUserProfilePictureUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
) => {
    await checkIsLoggedIn(context);
    console.log(`Creating Profile Picture Upload URL For User ID ${context.userId}`)
    return createSignedUploadUrl(fromBucket, context.userId as string);
};

export default createUserProfilePictureUploadUrl;
