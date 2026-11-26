import {defineConfig} from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://yasuomaidana.github.io',
  base: '/dev-ops-notes',
  trailingSlash: 'always',
  integrations: [
    starlight({
      title: 'DevOps Notes',
      description: 'Personal notes and hands-on examples for cloud, containers, and DevOps.',
      sidebar: [
        { label: 'Start here', items: [{ label: 'Home', link: '/' }] },
        { label: 'Contributing', items: [{ label: 'Update and preview', link: '/contributing/' }] },
        { label: 'AZ-900 Prep', items: [{ autogenerate: { directory: 'az-900-prep' } }] },
        { label: 'Azure Labs', items: [{ autogenerate: { directory: 'azure-labs' } }] },
        { label: 'Docker Notes', items: [{ autogenerate: { directory: 'docker-notes' } }] },
        { label: 'Kubernetes Notes', items: [{ autogenerate: { directory: 'kubernetes-notes' } }] },
      ],
    }),
  ],
});
