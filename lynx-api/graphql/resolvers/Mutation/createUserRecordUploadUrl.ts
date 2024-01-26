import { createSignedUploadUrl } from "../../aws/s3";
import { Context, LOG_LEVEL } from "../../index";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { SLOPES_ZIPPED_BUCKET } from "../../../infrastructure/lynxStack";

interface Args {
    requestedPaths: string[];
}

const createUserRecordUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
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
