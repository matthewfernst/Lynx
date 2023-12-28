import { Context } from "../../index";
import { checkIsMe } from "../../auth";
import { OAuthType } from "../Mutation/createUserOrSignIn";

interface Parent {
    id: string;
    appleId?: string;
    googleId?: string;
}

interface OAuthTypeCorrelation {
    type: OAuthType;
    id: string;
}

const oauthLoginIds = (
    parent: Parent,
    args: any,
    context: Context,
    info: any
): OAuthTypeCorrelation[] => {
    checkIsMe(parent, context.userId, "oauthLoginIds");
    return [
        parent.appleId && { type: "APPLE", id: parent.appleId },
        parent.googleId && { type: "GOOGLE", id: parent.googleId }
    ].filter(Boolean) as OAuthTypeCorrelation[];
};

export default oauthLoginIds;
