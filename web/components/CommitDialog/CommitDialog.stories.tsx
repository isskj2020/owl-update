import type { Meta, StoryObj } from '@storybook/react'
import { fn } from 'storybook/test'
import CommitDialog from './CommitDialog'
import type { ApiState } from '@/lib/api'

const diffText = `diff --git a/sample1.toml b/sample1.toml\n
index d11bc59..157032a 100644\n
--- a/sample1.toml\n
+++ b/sample1.toml\n
@@ -8,15 +8,15 @@\n
 "xmlns:xsd" = "http://www.w3.org/2001/XMLSchema#"\n
\n
 [status]\n
-violation_score = 2.49\n
+violation_score = 0.0\n
`

const meta: Meta<typeof CommitDialog> = {
  title: 'Components/CommitDialog',
  component: CommitDialog,
}

export default meta

type Story = StoryObj<typeof CommitDialog>

export const Default: Story = {
  args: {
    diffText: diffText,
    open: true,
    repo: 'sample',
    onCommit: fn(),
    onCancel: fn(),
  }
}

