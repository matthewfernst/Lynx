import { build } from "esbuild";
import { copyFile } from "fs/promises";

const buildLambdaFunction = async (packageName) => {
    await build({
        bundle: true,
        entryPoints: [`${packageName}/index.ts`],
        outdir: `dist/${packageName}`,
        platform: "node",
        target: "esnext",
        format: "esm",
        outExtension: { ".js": ".mjs" },
        sourcemap: true,
        banner: {
            js: `
                const require = await (async () => {
                    const { createRequire } = await import("node:module");
                    return createRequire(import.meta.url);
                })();
            `
        }
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
