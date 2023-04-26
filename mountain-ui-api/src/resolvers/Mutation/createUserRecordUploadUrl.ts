import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";

const fromBucket = "mountain-ui-app-slopes-zipped";

interface Args {
    requestedPaths: string[];
}

const createUserRecordUploadUrl = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    console.log(`Creating UserRecord Upload URL For User ID ${context.userId}`);
    return args.requestedPaths.map((requestedPath) => {
        createSignedUploadUrl(fromBucket, `${context.userId}/${requestedPath}`);
    });
};

export default createUserRecordUploadUrl;
