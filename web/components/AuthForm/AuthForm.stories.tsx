import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import AuthForm from './AuthForm'
import type { ApiState } from '@/lib/api'

const meta: Meta<typeof AuthForm> = {
  title: 'Components/AuthForm',
  component: AuthForm,
}

export default meta

type Story = StoryObj<typeof AuthForm>

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
    }
  },
}

export const Error: Story = {
  args: {
    apiState: {
      loading: false,
      error: 'xxx@gmail.com is already registered.'
    }
  },
}
