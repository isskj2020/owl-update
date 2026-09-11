import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import OwlFileGraphPage from './OwlFileGraphPage'
import owlData from './sample_owl.json'

const meta: Meta<typeof OwlFileGraphPage> = {
  title: 'Components/OwlFileGraphPage',
  component: OwlFileGraphPage,
}

export default meta

type Story = StoryObj<typeof OwlFileGraphPage>

export const Default: Story = {
  args: {
    apiState: {
      loading: false,
      error: null,
    },
    repository: 'sample',
    owlData: owlData,
    modelInfo: 'local llm sample model',
    focusedConstraint: owlData.axioms.constraints[0],
    onUpdateConstraints: fn(),
    onResetConstraints: fn(),
    onCommit: fn(),
    onSuggestByLLM: fn(),
    onFocusedConstraint: fn(),
  },
}

export const Loading: Story = {
  args: {
    apiState: {
      loading: true,
      error: null,
    },
    repository: 'sample',
    owlData: null,
    modelInfo: 'local llm sample model',
    focusedConstraint: owlData.axioms.constraints[0],
    onUpdateConstraints: fn(),
    onResetConstraints: fn(),
    onCommit: fn(),
    onSuggestByLLM: fn(),
    onFocusedConstraint: fn(),
  },
}

export const Error: Story = {
  args: {
    apiState: {
      loading: false,
      error: 'no data found',
    },
    repository: 'sample',
    owlData: null,
    modelInfo: 'local llm sample model',
    focusedConstraint: owlData.axioms.constraints[0],
    onUpdateConstraints: fn(),
    onResetConstraints: fn(),
    onCommit: fn(),
    onSuggestByLLM: fn(),
    onFocusedConstraint: fn(),
  },
}
