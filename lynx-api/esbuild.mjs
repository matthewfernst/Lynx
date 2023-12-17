import { build } from "esbuild";
import { copyFile } from "fs/promises";

buildLambdaFunction("reducer");
buildLambdaFunction("unzipper");

const packageName = "graphql";
buildLambdaFunction(packageName);
copyFile(`${packageName}/schema.graphql`, `dist/${packageName}/schema.graphql`);

const buildLambdaFunction = async (packageName) => {
    await build({
        bundle: true,
        entryPoints: [`${packageName}/index.ts`],
        outdir: `dist/${packageName}`,
        platform: "node",
        target: "node18"
    });
};
