import { PROFILE_PICS_BUCKET } from "../../../infrastructure/stacks/lynxApiStack";
import { checkIfObjectInBucket } from "../../aws/s3";
import { DefinedUserContext } from "../../index";
import { LOG_LEVEL } from "../../types";

interface Parent {
    id: string;
    profilePictureUrl: string;
}

const profilePictureUrl = async (
    parent: Parent,
    args: {},
    context: DefinedUserContext,
    info: any
): Promise<string | null> => {
    return context.dataloaders.profilePictures.load(parent);
};

export const profilePictureDataloader = async (
    users: readonly Parent[]
): Promise<(string | null)[]> => {
    return await Promise.all(
        users.map(async (user) => {
            if (await checkIfObjectInBucket(PROFILE_PICS_BUCKET, user.id)) {
                console[LOG_LEVEL](`Found S3 profile picture for user ${user.id}`);
                return `https://${PROFILE_PICS_BUCKET}.s3.us-west-1.amazonaws.com/${user.id}`;
            } else if (user.profilePictureUrl) {
                return user.profilePictureUrl;
            } else {
                return null;
            }
        })
    );
};

export default profilePictureUrl;
