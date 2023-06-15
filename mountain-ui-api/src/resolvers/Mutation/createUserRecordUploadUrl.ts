import { createSignedUploadUrl, toRunRecordsBucket } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";

interface Args {
    requestedPaths: string[];
}

const createUserRecordUploadUrl = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<string[]> => {
    await checkIsLoggedIn(context);
    console.log(`Creating UserRecord Upload URL For User ID ${context.userId}`);
    return await Promise.all(
        args.requestedPaths.map((requestedPath) =>
            createSignedUploadUrl(fromRunRecordsBucket, `${context.userId}/${requestedPath}`)
        )
    );
};

export default createUserRecordUploadUrl;
