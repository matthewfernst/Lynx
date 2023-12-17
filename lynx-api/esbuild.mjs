import { build } from "esbuild";
import { copyFile } from "fs/promises";

const commonOptions = { bundle: true, platform: "node", target: "node18" };
const buildGraphQLFunction = async () => {
    const packageName = "graphql";
    await build({
        entryPoints: [`${packageName}/index.ts`],
        outdir: "dist/graphql",
        ...commonOptions
    });
    copyFile(`${packageName}/schema.graphql`, `dist/${packageName}/schema.graphql`);
};

const buildReducerFunction = async () => {
    await build({
        entryPoints: ["reducer/index.ts"],
        outdir: "dist/reducer",
        ...commonOptions
    });
};

const buildUnzipperFunction = async () => {
    await build({
        entryPoints: ["unzipper/index.ts"],
        outdir: "dist/unzipper",
        ...commonOptions
    });
};

buildGraphQLFunction();
buildReducerFunction();
buildUnzipperFunction();
