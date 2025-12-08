import { GraphQLResolveInfo } from "graphql";

import { OAuthType } from "../Mutation/oauthSignIn";
import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { DatabaseUser } from "../../types";

interface OAuthTypeCorrelation {
  type: keyof typeof OAuthType;
  id: string;
}

const oauthLoginIds = (
  parent: DatabaseUser,
  _args: Record<string, never>,
  context: DefinedUserContext,
  _info: GraphQLResolveInfo,
): OAuthTypeCorrelation[] => {
  checkIsMe(parent, context, "oauthLoginIds");
  return [
    parent.appleId && { type: OAuthType[OAuthType.APPLE], id: parent.appleId },
    parent.googleId && {
      type: OAuthType[OAuthType.GOOGLE],
      id: parent.googleId,
    },
    parent.facebookId && {
      type: OAuthType[OAuthType.FACEBOOK],
      id: parent.facebookId,
    },
  ].filter(Boolean) as OAuthTypeCorrelation[];
};

export default oauthLoginIds;
