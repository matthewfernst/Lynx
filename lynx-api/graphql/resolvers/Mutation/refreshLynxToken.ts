import { DateTime } from "luxon";

import { AccessToken, GrantType, decryptToken, generateToken } from "../../auth";
import { Context } from "../../index";
import { AuthorizationToken } from "./oauthSignIn";
import { UNAUTHENTICATED } from "../../types";
import { GraphQLError } from "graphql";

interface Args {
    refreshToken: string;
}

const refreshLynxToken = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<AuthorizationToken> => {
    const { id: userId } = await decryptRefreshToken(args.refreshToken);
    const oneHourFromNow = DateTime.now().plus({ hours: 1 }).toMillis().toString();
    return {
        accessToken: await generateToken(userId, GrantType.AUTH),
        expiryDate: oneHourFromNow,
        refreshToken: await generateToken(userId, GrantType.REFRESH)
    };
};

const decryptRefreshToken = async (token: string): Promise<AccessToken> => {
    try {
        return await decryptToken(token, GrantType.REFRESH);
    } catch (err) {
        console.error(err);
        throw new GraphQLError("Invalid Refresh Token", {
            extensions: { code: UNAUTHENTICATED, token }
        });
    }
};

export default refreshLynxToken;
