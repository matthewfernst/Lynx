import { Context } from "../../index";
import { checkIfObjectInBucket } from "../../aws/s3";
import { profilePictureBucketName } from "../../aws/s3";

const profilePictureUrl = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<string | null> => {
    if (await checkIfObjectInBucket(profilePictureBucketName, parent.id)) {
        console.log(`Found S3 profile picture for user ${parent.id}`);
        return `https://${profilePictureBucketName}.s3.us-west-1.amazonaws.com/${parent.id}`;
    } else if (parent.profilePictureUrl) {
        return parent.profilePictureUrl;
    } else {
        return null;
    }
};

export default profilePictureUrl;
