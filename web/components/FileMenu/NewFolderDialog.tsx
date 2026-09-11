'use client';

import { useEffect, useState } from 'react';
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  TextField,
  Stack,
  Typography,
} from '@mui/material';
import { joinpath } from '@/lib/owlpath'


export interface NewFolderDialogProps {
  open: boolean;
  onCreate: (path: string) => void;
  onClose: () => void;
}

export default function NewFolderDialog({
  open,
  onCreate,
  onClose,
}: NewFolderDialogProps) {
  const [path, setPath] = useState('');

  useEffect(() => {
    if (open) {
      setPath('');
    }
  }, [open]);

  const handleCreate = () => {
    if (!path.trim()) return;
    onCreate(path.trim());
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="xs" fullWidth>
      <DialogTitle>New Folder</DialogTitle>

      <DialogContent>
        <Stack>
        <TextField
          autoFocus
          margin="dense"
          label="Directory path"
          fullWidth
          value={path}
          onChange={(e) => setPath(e.target.value)}
          placeholder="e.g. ./animal"
        />
        <Typography variant='body'>
        <strong>New directory: {joinpath(path, '')}</strong>
        </Typography>
        </Stack>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Cancel
        </Button>

        <Button
          variant="contained"
          onClick={handleCreate}
          disabled={!path.trim()}
        >
          Create
        </Button>
      </DialogActions>
    </Dialog>
  );
}
