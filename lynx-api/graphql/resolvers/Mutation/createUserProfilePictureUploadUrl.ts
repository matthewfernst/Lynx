import { createSignedUploadUrl } from "../../aws/s3";
import { Context, logLevel } from "../../index";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { PROFILE_PICS_BUCKET } from "../../../infrastructure/lynxStack";

interface Args {}

const createUserProfilePictureUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<string> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console[logLevel](`Creating Profile Picture Upload URL For User ID ${context.userId}`);
    return await createSignedUploadUrl(PROFILE_PICS_BUCKET, context.userId);
};

export default createUserProfilePictureUploadUrl;
