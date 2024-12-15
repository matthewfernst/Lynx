import { GraphQLResolveInfo } from "graphql";

import { DefinedUserContext } from "../../index";
import { DatabaseUser } from "../../types";

const profilePictureUrl = async (
    parent: DatabaseUser,
    _args: Record<string, never>,
    context: DefinedUserContext,
    _info: GraphQLResolveInfo
): Promise<string | null> => {
    return context.dataloaders.profilePictures.load(parent);
};

export default profilePictureUrl;
