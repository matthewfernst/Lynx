import { GraphQLResolveInfo } from "graphql";

import { PROFILE_PICS_BUCKET } from "../../../infrastructure/stacks/lynxApiStack";
import { checkIfObjectInBucket } from "../../aws/s3";
import { DefinedUserContext } from "../../index";
import { LOG_LEVEL, User } from "../../types";

const profilePictureUrl = async (
    parent: User,
    _args: Record<string, never>,
    context: DefinedUserContext,
    _info: GraphQLResolveInfo
): Promise<string | null> => {
    return context.dataloaders.profilePictures.load(parent);
};

export const profilePictureDataloader = async (
    users: readonly User[]
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
