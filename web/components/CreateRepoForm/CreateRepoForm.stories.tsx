import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import CreateRepoForm from './CreateRepoForm'
import type { ApiState } from '@/lib/api'

const meta: Meta<typeof CreateRepoForm> = {
  title: 'Components/CreateRepoForm',
  component: CreateRepoForm,
}

export default meta

type Story = StoryObj<typeof CreateRepoForm>

export const Default: Story = {
  args: {
    apiState: {
      loading: false,
      error: null
    },
    onSubmit: fn(),
  },
}

export const Loading: Story = {
  args: {
    apiState: {
      loading: true,
      error: null
    },
    onSubmit: fn(),
  },
}

export const Error: Story = {
  args: {
    apiState: {
      loading: false,
      error: 'invalid name'
    },
    onSubmit: fn(),
  },
}

