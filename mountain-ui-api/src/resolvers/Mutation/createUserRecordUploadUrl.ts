import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import { fromBucket } from "../../../../mountain-ui-slopes-unzipper";

interface Args {
    requestedPaths: string[];
}

const createUserRecordUploadUrl = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    return args.requestedPaths.map((requestedPath) => {
        createSignedUploadUrl(fromBucket, `${context.userId}/${requestedPath}`);
    });
};

export default createUserRecordUploadUrl;
