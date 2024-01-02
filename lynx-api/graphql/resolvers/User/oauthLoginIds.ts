import { OAuthType } from "../Mutation/oauthSignIn";
import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { User } from "../../types";

interface OAuthTypeCorrelation {
    type: OAuthType;
    id: string;
}

const oauthLoginIds = (
    parent: User,
    args: any,
    context: DefinedUserContext,
    info: any
): OAuthTypeCorrelation[] => {
    checkIsMe(parent, context, "oauthLoginIds");
    return [
        parent.appleId && { type: "APPLE", id: parent.appleId },
        parent.googleId && { type: "GOOGLE", id: parent.googleId },
        parent.facebookId && { type: "FACEBOOK", id: parent.facebookId }
    ].filter(Boolean) as OAuthTypeCorrelation[];
};

export default oauthLoginIds;
