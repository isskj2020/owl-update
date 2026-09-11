import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import AppHeader from './AppHeader'

const meta: Meta<typeof AppHeader> = {
  title: 'Components/AppHeader',
  component: AppHeader,
}

export default meta

type Story = StoryObj<typeof AppHeader>

export const Default: Story = {
  args: {
    isAlive: true,
    user: {
      id: '1',
      name: 'isskj',
      email: 'isskj@example.com',
    },
    onLogin: fn(),
    onLogout: fn(),
  },
}

export const ServerDown: Story = {
  args: {
    isAlive: false,
    user: {
      id: '1',
      name: 'isskj',
      email: 'isskj@example.com',
    },
    onLogin: fn(),
    onLogout: fn(),
  },
}

export const Logout: Story = {
  args: {
    isAlive: true,
    user: null,
    onLogin: fn(),
    onLogout: fn(),
  },
}
