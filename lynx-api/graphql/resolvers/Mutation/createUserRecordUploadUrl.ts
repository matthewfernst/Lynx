import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { checkHasUserId, checkIsLoggedInAndHasValidInvite } from "../../auth";
import { SLOPES_ZIPPED_BUCKET } from "../../../infrastructure/lib/infrastructure";

interface Args {
    requestedPaths: string[];
}

const createUserRecordUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<string[]> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    console.log(`Creating UserRecord Upload URL For User ID ${userId}`);
    return await Promise.all(
        args.requestedPaths.map((requestedPath) =>
            createSignedUploadUrl(SLOPES_ZIPPED_BUCKET, `${userId}/${requestedPath}`)
        )
    );
};

export default createUserRecordUploadUrl;
