import { DefinedUserContext } from "../../index";
import { checkIfObjectInBucket } from "../../aws/s3";
import { PROFILE_PICS_BUCKET } from "../../../infrastructure/lib/infrastructure";

const profilePictureUrl = async (
    parent: any,
    args: {},
    context: DefinedUserContext,
    info: any
): Promise<string | null> => {
    if (await checkIfObjectInBucket(PROFILE_PICS_BUCKET, parent.id)) {
        console.log(`Found S3 profile picture for user ${parent.id}`);
        return `https://${PROFILE_PICS_BUCKET}.s3.us-west-1.amazonaws.com/${parent.id}`;
    } else if (parent.profilePictureUrl) {
        return parent.profilePictureUrl;
    } else {
        return null;
    }
};

export default profilePictureUrl;
