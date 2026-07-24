import type { StorybookConfig } from '@storybook/react-vite';
import type { PluginOption } from 'vite';

function withoutPwa(plugins: PluginOption[]): PluginOption[] {
  return plugins.flatMap((plugin) => {
    if (Array.isArray(plugin)) return withoutPwa(plugin);
    if (!plugin) return [];
    if ('name' in plugin && plugin.name.startsWith('vite-plugin-pwa')) return [];
    return [plugin];
  });
}

const config: StorybookConfig = {
  stories: ['../src/**/*.stories.@(ts|tsx)'],
  addons: ['@storybook/addon-a11y'],
  framework: '@storybook/react-vite',
  viteFinal: (viteConfig) => ({
    ...viteConfig,
    plugins: withoutPwa(viteConfig.plugins ?? []),
  }),
};

export default config;
