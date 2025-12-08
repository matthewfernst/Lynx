import { GraphQLError, GraphQLResolveInfo } from "graphql";
import { DateTime } from "luxon";

import {
  AccessToken,
  GrantType,
  decryptToken,
  generateToken,
} from "../../auth";
import { Context } from "../../index";
import { AuthorizationToken } from "./oauthSignIn";
import { UNAUTHENTICATED } from "../../types";

interface Args {
  refreshToken: string;
}

const refreshLynxToken = (
  _: unknown,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
): AuthorizationToken => {
  const { id: userId } = decryptRefreshToken(args.refreshToken);
  const oneHourFromNow = DateTime.now()
    .plus({ hours: 1 })
    .toMillis()
    .toString();
  return {
    accessToken: generateToken(userId, GrantType.AUTH),
    expiryDate: oneHourFromNow,
    refreshToken: generateToken(userId, GrantType.REFRESH),
  };
};

const decryptRefreshToken = (token: string): AccessToken => {
  try {
    return decryptToken(token, GrantType.REFRESH);
  } catch (err) {
    console.error(err);
    throw new GraphQLError("Invalid Refresh Token", {
      extensions: { code: UNAUTHENTICATED, token },
    });
  }
};

export default refreshLynxToken;
