import { GraphQLResolveInfo } from "graphql";

import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { LOG_LEVEL } from "../../types";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { PROFILE_PICS_BUCKET } from "../../../infrastructure/stacks/lynxApiStack";

const createUserProfilePictureUploadUrl = async (
    _: unknown,
    _args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<string> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console[LOG_LEVEL](`Creating Profile Picture Upload URL For User ID ${context.userId}`);
    return await createSignedUploadUrl(PROFILE_PICS_BUCKET, context.userId);
};

export default createUserProfilePictureUploadUrl;
