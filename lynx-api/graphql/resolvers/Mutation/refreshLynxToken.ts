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
import { FORBIDDEN } from "../../types";
import { TokenExpiredError } from "jsonwebtoken";
import { ApolloServerErrorCode } from "@apollo/server/errors";

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
    .plus({ hours: 12 })
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
    if (err instanceof TokenExpiredError) {
      console.debug("Refresh Token Expired");
      throw new GraphQLError("Expired Refresh Token", {
        extensions: { code: FORBIDDEN, token },
      });
    }
    console.error("Invalid Refresh Token");
    throw new GraphQLError("Invalid Refresh Token", {
      extensions: { code: ApolloServerErrorCode.BAD_REQUEST, token },
    });
  }
};

export default refreshLynxToken;
