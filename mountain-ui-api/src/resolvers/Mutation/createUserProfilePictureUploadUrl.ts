import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";

const fromBucket = "mountain-ui-users-profile-pictures";

interface Args {
}

const createUserProfilePictureUploadUrl = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    return createSignedUploadUrl(fromBucket, `${context.userId}-profile-picture`);
};

export default createUserProfilePictureUploadUrl;
