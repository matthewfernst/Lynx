import { build } from "esbuild";
import { copyFile } from "fs/promises";

const buildLambdaFunction = async (packageName) => {
    await build({
        bundle: true,
        entryPoints: [`${packageName}/index.ts`],
        outdir: `dist/${packageName}`,
        platform: "node",
        target: "node18",
        minify: true,
        sourcemap: true
    });
};

await buildLambdaFunction("reducer");
await buildLambdaFunction("unzipper");

const graphqlDirectoryName = "graphql";
await buildLambdaFunction(graphqlDirectoryName);
await copyFile(
    `${graphqlDirectoryName}/schema.graphql`,
    `dist/${graphqlDirectoryName}/schema.graphql`
);
