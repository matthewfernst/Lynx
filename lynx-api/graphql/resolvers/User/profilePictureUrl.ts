import { DefinedUserContext } from "../../index";

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

export default profilePictureUrl;
