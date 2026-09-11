'use client'

import { useObjectState } from '@/lib/react'
import { useEffect, useState, ReactNode } from 'react'
import {
  Snackbar,
  IconButton,
  Box,
  Stack,
  LinearProgress,
  Button,
} from '@mui/material'
import CloseIcon from '@mui/icons-material/Close'
import CommitDialog from '@/components/CommitDialog/CommitDialog'
import ModelInfo from './ModelInfo'
import EditorPane from './EditorPane'
import ConstraintTable from './ConstraintTable'
import Graph from './Graph'
import type { 
  ApiState,
  OWLData,
  Axioms,
  Constraint,
  Node,
  Edge,
} from '@/types/types'

type DialogOpen = {
  commit: boolean,
}

type OwlFileGraphpageProps = {
  diffText: string,
  apiState: ApiState,
  repository: string,
  owlData: OWLData|null,
  modelInfo: string,
  focusedConstraint: Constraint,
  onUpdateConstraints: (constraints: Constraint[]) => Promise<void>,
  onResetConstraints: () => Promise<void>,
  onCommit: (message: string) => Promise<void>,
  onSuggestML: (type: string) => Promise<void>,
  onFocusedConstraint: (c: Constraint) => void,
}


export default function OwlFileGraphPage({
  diffText,
  apiState,
  repository,
  owlData,
  modelInfo,
  focusedConstraint,
  onUpdateConstraints,
  onResetConstraints,
  onCommit,
  onSuggestML,
  onFocusedConstraint,
}: OwlFileGraphPageProps) {
  const [dialog, updateDialog] = useObjectState<DialogOpen>({
    commit: false,
  })
  const [errorOpen, setErrorOpen] = useState(false)

  useEffect(() => {
    setErrorOpen(apiState.error)
  }, [apiState])

  return (
    <Box>
      <Snackbar
        open={errorOpen}
        anchorOrigin={{ vertical: 'top', horizontal: 'center'}}
        onClose={() => setErrorOpen(false) }
        sx={{
          '& .MuiPaper-root': {
            bgcolor: 'var(--mui-palette-primary)',
            color: 'var(--mui-palette-error-main)',
          },
        }}
        message={apiState.error}
        action={
          <IconButton
            size='small'
            color='inherit'
            onClick={() => setErrorOpen(false)}
          >
          <CloseIcon fontSize='small' />
          </IconButton>
        }
      />
      <CommitDialog
        diffText={diffText}
        open={dialog.commit}
        repo={repository}
        onCancel={() => updateDialog({ commit: false})}
        onCommit={(x) => {
          updateDialog({ commit: false })
          onCommit(x)
        }}
      />
      <EditorPane
        editor = {
          owlData && (
              <ConstraintTable 
                apiState={apiState}
                owlData={owlData}
                focusedConstraint={focusedConstraint}
                onUpdate={onUpdateConstraints}
                onReset={onResetConstraints}
                onCommit={() => updateDialog({ commit: true })}
                onSuggestML={onSuggestML}
                onFocusedConstraint={onFocusedConstraint}
              />
          )
        }
        graph = {
          <Graph
            data={owlData}
            focusedConstraint={focusedConstraint}
            onFocusedConstraint={onFocusedConstraint}
          />
        }
      />
      <ModelInfo model={modelInfo} />
    </Box>
  )
}

