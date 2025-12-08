import { GraphQLResolveInfo } from "graphql";

import { PARTIES_TABLE } from "../../../infrastructure/stacks/lynxApiStack";
import {
  checkHasUserId,
  checkIsValidPartyAndIsPartyOwner,
  checkIsValidUser,
} from "../../auth";
import { updateItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";

interface Args {
  partyId: string;
  partyData: {
    key: string;
    value: string;
  }[];
}

const editParty = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<Party> => {
  checkHasUserId(context);
  await checkIsValidUser(context);
  await checkIsValidPartyAndIsPartyOwner(context, args.partyId);

  for (const data of args.partyData) {
    await updateItem(PARTIES_TABLE, args.partyId, data.key, data.value);
  }

  return (await context.dataloaders.parties.load(args.partyId)) as Party;
};

export default editParty;
