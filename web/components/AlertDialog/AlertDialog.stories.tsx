import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import AlertDialog from './AlertDialog'

const meta: Meta<typeof AlertDialog> = {
  title: 'Components/AlertDialog',
  component: AlertDialog,
}

export default meta

type Story = StoryObj<typeof AlertDialog>

export const Default: Story = {
  args: {
    apiState: {
      loading: true,
      error: null,
    },
  },
}

export const Error: Story = {
  args: {
    apiState: {
      loading: false,
      error: 'error happened',
    },
  },
}

