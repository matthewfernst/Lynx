import { createSignedUploadUrl } from "../../aws/s3";
import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import { fromBucket } from "../../../../mountain-ui-slopes-unzipper";

interface Args {
    files: string[];
}

const createUserRecordUploadUrl = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    return args.files.map((file) => {
        createSignedUploadUrl(fromBucket, `${context.userId}/${file}`);
    });
};

export default createUserRecordUploadUrl;
