import casual from "casual";

const mocks = {
    User: () => ({
        id: casual.uuid
    }),
    RunRecord: () => ({
        id: casual.uuid
    })
};

export default mocks;
