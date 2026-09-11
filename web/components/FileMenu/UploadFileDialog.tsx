'use client'

import { useEffect, useState } from 'react'
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  TextField,
  Stack,
  Typography,
} from '@mui/material'
import { joinpath } from '@/lib/owlpath'

export interface UploadFileDialogProps {
  open: boolean
  onUpload: (path: string, file: File) => void
  onClose: () => void
}


export default function UploadFileDialog({
  open,
  onUpload,
  onClose,
}: UploadFileDialogProps) {
  const [path, setPath] = useState('')
  const [file, setFile] = useState<File | null>(null)

  useEffect(() => {
    if (open) {
      setFile(null)
      setPath('')
    }
  }, [open])

  const handleUpload = () => {
    if (!file) return
    onUpload(joinpath(path, file.name), file)
  }

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth='sm'
      fullWidth
    >
      <DialogTitle>
        Upload File
      </DialogTitle>

      <DialogContent>
        <Stack spacing={2}
          sx={{
            p: 2
          }}
        >
          <TextField
            label='Directory path'
            fullWidth
            value={path}
            onChange={(e) => setPath(e.target.value)}
            placeholder='e.g. ./'
          />

          <Button
            variant='outlined'
            component='label'
          >
            Select File
            <input
              hidden
              type='file'
              onChange={(e) => {
                const selected = e.target.files?.[0] ?? null
                setFile(selected)
              }}
            />
          </Button>

          {file && (
            <Typography variant='body'>
              <strong>Selected: {joinpath(path, file.name)}</strong>
            </Typography>
          )}
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Cancel
        </Button>

        <Button
          variant='contained'
          onClick={handleUpload}
          disabled={!file}
        >
          Upload
        </Button>
      </DialogActions>
    </Dialog>
  )
}
