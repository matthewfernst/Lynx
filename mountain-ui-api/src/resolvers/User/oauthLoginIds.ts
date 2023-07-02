import { Context } from "../../index";
import { checkIsMe } from "../../auth";
import { LoginType } from "../Mutation/createUserOrSignIn";

interface Parent {
    id: string;
    appleId?: string;
    googleId?: string;
}

interface LoginTypeCorrelation {
    type: LoginType;
    id: string;
}

const oauthLoginIds = (
    parent: Parent,
    args: any,
    context: Context,
    info: any
): LoginTypeCorrelation[] => {
    checkIsMe(parent, context);
    return [
        parent.appleId && { type: "APPLE", id: parent.appleId },
        parent.googleId && { type: "GOOGLE", id: parent.googleId }
    ].filter(Boolean) as LoginTypeCorrelation[];
};

export default oauthLoginIds;
