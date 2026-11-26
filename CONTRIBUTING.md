# Update and preview the site

## Update the content

- Edit the Markdown file next to the example or lab it describes. For example, the Linux Web App scaling guide is `azure-labs/linux-web-app-scaling/README.md`.
- Edit site-wide content such as the homepage in `site-content/`.
- Add shared Azure sign-in and subscription setup to `azure-labs/getting-started.md`; keep each lab's deployment, verification, and cleanup steps with that lab.
- Keep diagrams next to their topic. AZ-900 diagrams live in `AZ-900 Prep/assets/` and are linked with relative Markdown paths.
- Keep executable files in their existing folders and link to them with relative paths. The sync step turns those into source links on the website.
- Do not edit `src/content/docs/`; Bun regenerates it from the source Markdown before preview and build.

## Preview locally

Install [Bun](https://bun.sh/docs/installation), then from the repository root run:

```powershell
bun install
bun run dev
```

Open the local URL printed by Astro, usually `http://localhost:4321/dev-ops-notes/`. The preview watches the source Markdown folders and refreshes the site when a page or diagram changes.

To build and preview the production output locally:

```powershell
bun run build
bun run preview
```

## Publish changes

Before the first deployment, set the repository's **Settings → Pages → Build and deployment → Source** to **GitHub Actions**.

Open a pull request targeting `main`; GitHub Actions builds the site without publishing it. Merging to `main` deploys the newest version to the public GitHub Pages site. Check the repository's **Actions** tab for the deployment result.
