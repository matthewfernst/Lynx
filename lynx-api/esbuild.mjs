import { build } from "esbuild";
import { copyFile } from "fs/promises";

const buildLambdaFunction = async (packageName) => {
    await build({
        bundle: true,
        entryPoints: [`${packageName}/index.ts`],
        outdir: `dist/${packageName}`,
        platform: "node",
        target: "node18"
    });
};

await buildLambdaFunction("reducer");
await buildLambdaFunction("unzipper");

const packageName = "graphql";
await buildLambdaFunction(packageName);
await copyFile(`${packageName}/schema.graphql`, `dist/${packageName}/schema.graphql`);
