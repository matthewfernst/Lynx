import esbuild from "esbuild";
import { copyFile } from "fs/promises";

const isProduction = process.env.NODE_ENV === "production";

async function buildLambdaFunction(entrypoint, directory, watch = false) {
    const target = { bundle: true, platform: "node", sourcemap: true, target: "node22" };
    const productionOptions = { minify: true, treeShaking: true };
    const options = {
        entryPoints: [entrypoint],
        outdir: directory,
        ...target,
        ...(isProduction && productionOptions)
    };
    const build = watch ? esbuild.context : esbuild.build;
    return await build(options);
}

const graphqlContext = await buildLambdaFunction("graphql/index.ts", "dist/graphql", !isProduction);
if (!isProduction) {
    await graphqlContext.watch();
}

await buildLambdaFunction("reducer/index.ts", "dist/reducer");
await buildLambdaFunction("unzipper/index.ts", "dist/unzipper");

await copyFile(`../Lynx-SwiftUI/schema.graphql`, `dist/graphql/schema.graphql`);
