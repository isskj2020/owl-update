import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import FileViewPage from './FileViewPage'

const meta: Meta<typeof FileViewPage> = {
  title: 'Components/FileViewPage',
  component: FileViewPage,
}

export default meta

type Story = StoryObj<typeof FileViewPage>

export const Default: Story = {
  args: {
    repository: 'sample',
    dialogOpen: {
      newFolder: false,
      uploadFile: false,
    },
    apiState: {
      loading: false,
      error: null,
    },
    files: [
      {
        isfile: false,
        canload: false,
        name: 'test123',
        size: 134,
        updated: '2025-6-6'
      },
      {
        isfile: true,
        canload: true,
        name: 'sample.xml',
        size: 134,
        updated: '2025-6-6'
      },
    ],
    onAddDirectory: fn(),
    onAddXmlFile: fn(),
    onNavigate: fn(),
  },
}

