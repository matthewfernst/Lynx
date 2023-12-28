import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { User } from "../../types";

const email = (parent: User, args: any, context: DefinedUserContext, info: any) => {
    checkIsMe(parent, context, "email");
    return parent.email;
};

export default email;
