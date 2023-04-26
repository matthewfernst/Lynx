import { Context } from "../../index";
import { checkIfObjectInBucket } from "../../aws/s3";
import { profilePictureBucketName } from "../Mutation/createUserProfilePictureUploadUrl";

const profilePictureUrl = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<string | null> => {
    if (parent.profilePictureUrl) {
        return parent.profilePictureUrl;
    } else if (await checkIfObjectInBucket(profilePictureBucketName, parent.id)) {
        return `https://${profilePictureBucketName}.s3.us-west-1.amazonaws.com/${parent.id}`;
    } else {
        return null;
    }
};

export default profilePictureUrl;
