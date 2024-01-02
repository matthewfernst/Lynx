import { OAuthType } from "../Mutation/oauthSignIn";
import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { User } from "../../types";

interface OAuthTypeCorrelation {
    type: keyof typeof OAuthType;
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
        parent.appleId && { type: OAuthType[OAuthType.APPLE], id: parent.appleId },
        parent.googleId && { type: OAuthType[OAuthType.GOOGLE], id: parent.googleId },
        parent.facebookId && { type: OAuthType[OAuthType.FACEBOOK], id: parent.facebookId }
    ].filter(Boolean) as OAuthTypeCorrelation[];
};

export default oauthLoginIds;
