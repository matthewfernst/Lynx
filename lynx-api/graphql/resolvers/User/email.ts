import { Context } from "../../index";
import { checkIsMe } from "../../auth";

interface Parent {
    id: string;
    email: string;
}

const email = (parent: Parent, args: any, context: Context, info: any) => {
    checkIsMe(parent, context.userId, "email");
    return parent.email;
};

export default email;
