import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import MLButtonMenu from './MLButtonMenu'

const meta: Meta<typeof MLButtonMenu> = {
  title: 'Components/MLButtonMenu',
  component: MLButtonMenu,
}

export default meta

type Story = StoryObj<typeof MLButtonMenu>

export const Default: Story = {
  args: {
    onAddDirectory: fn(),
    onAddXmlFile: fn(),
  },
}

