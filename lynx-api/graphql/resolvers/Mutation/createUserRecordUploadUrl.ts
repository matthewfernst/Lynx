import { GraphQLResolveInfo } from "graphql";

import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { LOG_LEVEL } from "../../types";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { SLOPES_ZIPPED_BUCKET } from "../../../infrastructure/stacks/lynxApiStack";

interface Args {
    requestedPaths: string[];
}

const createUserRecordUploadUrl = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<string[]> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console[LOG_LEVEL](`Creating UserRecord Upload URL For User ID ${context.userId}`);
    return await Promise.all(
        args.requestedPaths.map((requestedPath) =>
            createSignedUploadUrl(SLOPES_ZIPPED_BUCKET, `${context.userId}/${requestedPath}`)
        )
    );
};

export default createUserRecordUploadUrl;
