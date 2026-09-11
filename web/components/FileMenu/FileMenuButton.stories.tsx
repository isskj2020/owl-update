import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import FileMenuButton from './FileMenuButton'

const meta: Meta<typeof FileMenuButton> = {
  title: 'Components/FileMenuButton',
  component: FileMenuButton,
}

export default meta

type Story = StoryObj<typeof FileMenuButton>

export const Default: Story = {
  args: {
    onAddDirectory: fn(),
    onAddXmlFile: fn(),
  },
}

