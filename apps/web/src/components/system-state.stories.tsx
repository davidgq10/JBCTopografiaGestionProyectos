import { MantineProvider } from '@mantine/core';
import type { Meta, StoryObj } from '@storybook/react-vite';

import { jbcCssVariablesResolver, jbcTheme } from '../theme.js';
import { ErrorState } from './system-state.js';

const meta: Meta<typeof ErrorState> = {
  title: 'Estados/ErrorState',
  component: ErrorState,
  decorators: [
    (Story) => (
      <MantineProvider theme={jbcTheme} cssVariablesResolver={jbcCssVariablesResolver}>
        <div style={{ padding: 24 }}>
          <Story />
        </div>
      </MantineProvider>
    ),
  ],
  args: {
    message: 'No fue posible cargar la información. Intente nuevamente.',
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};
