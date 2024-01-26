import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { LOG_LEVEL } from "../../types";
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
    console[LOG_LEVEL](`Creating Profile Picture Upload URL For User ID ${context.userId}`);
    return await createSignedUploadUrl(PROFILE_PICS_BUCKET, context.userId);
};

export default createUserProfilePictureUploadUrl;
