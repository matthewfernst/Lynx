import esbuild from "esbuild";
import globImport from "esbuild-plugin-glob-import";

import { copyFile } from "fs/promises";

const buildLambdaFunction = async (packageName) => {
    await esbuild.build({
        bundle: true,
        entryPoints: [`${packageName}/index.ts`],
        outdir: `dist/${packageName}`,
        platform: "node",
        target: "node18",
        minify: true,
        sourcemap: true,
        plugins: [globImport()]
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
