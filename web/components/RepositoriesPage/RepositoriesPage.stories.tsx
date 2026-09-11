import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import RepositoriesPage from './RepositoriesPage'
import type { ApiState } from '@/lib/api'

const meta: Meta<typeof RepositoriesPage> = {
  title: 'Components/RepositoriesPage',
  component: RepositoriesPage,
}

export default meta

type Story = StoryObj<typeof RepositoriesPage>

export const Default: Story = {
  args: {
    apiState: {
      loading: false,
      error: null,
    },
    repositories: ['sample1', 'sample2', 'sample3', 'sample4', 'sample5'],
  },
}

export const Loading: Story = {
  args: {
    apiState: {
      loading: true,
      error: null,
    },
    repositories: [],
  },
}

export const Error: Story = {
  args: {
    apiState: {
      loading: false,
      error: 'no data found.',
    },
    repositories: [],
  },
}

