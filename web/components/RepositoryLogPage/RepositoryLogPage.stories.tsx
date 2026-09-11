import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import RepositoryLogPage from './RepositoryLogPage'
import type { ApiState } from '@/lib/api'

const meta: Meta<typeof RepositoryLogPage> = {
  title: 'Components/RepositoryLogPage',
  component: RepositoryLogPage,
}

export default meta

type Story = StoryObj<typeof RepositoryLogPage>

export const Default: Story = {
  args: {
    apiState: {
      loading: false,
      error: null,
    },
    logs: [
      {
        hash: 'aaaaaa-hash',
        author: 'isskj',
        date: '2026-1-1',
        message: 'first commit',
      },
    ],
    onNavigate: fn(),
  },
}

export const Loading: Story = {
  args: {
    apiState: {
      loading: true,
      error: null,
    },
    logs: [],
    onNavigate: fn(),
  },
}

export const Error: Story = {
  args: {
    apiState: {
      loading: false,
      error: 'no data found.',
    },
    logs: [],
    onNavigate: fn(),
  },
}

