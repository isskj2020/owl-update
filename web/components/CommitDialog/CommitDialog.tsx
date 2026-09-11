'use client'

import {
  Box,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  List,
  ListItem,
  ListItemText,
} from '@mui/material'
import { apiFetchRepoDiffs } from '@/lib/api'
import { useState, useEffect } from 'react'
import DiffView from './DiffView'

type Props = {
  diffText: string,
  open: boolean,
  repo: string,
  onCommit: (message: string) => void,
  onCancel: () => void
}

export default function CommitDialog({
  diffText,
  open,
  repo,
  onCommit,
  onCancel,
}: Props) {
  const [message, setMessage] = useState('')
  const [disabled, setDisabled] = useState(false)

  const onChangeMessage = (text) => {
    setDisabled(text == '')
    setMessage(text)
  }

  return (
    <Dialog
      open={open}
      onClose={onCancel}
      maxWidth='md'
      fullWidth
    >
      <DialogTitle>Commit Changes</DialogTitle>

      <DialogContent>
        <TextField
          label='Commit message'
          fullWidth
          multiline
          minRows={3}
          margin='normal'
          value={message}
          onChange={(e) => onChangeMessage(e.target.value)}
        />

        <DiffView diff={diffText} />
      </DialogContent>

      <DialogActions>
        <Button onClick={() => onCancel()}>
          Cancel
        </Button>

        <Button
          variant='contained'
          onClick={() => onCommit(message)}
          disabled={disabled}
        >
          Commit
        </Button>
      </DialogActions>
    </Dialog>
  )
}
