'use client'

import { useEffect, useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  CircularProgress,
} from '@mui/material'
import type { ApiState } from '@/types/types'

type AlertDialogProps = {
  apiState: ApiState,
}

export default function AlertDialog({ apiState }: AlertDialogProps) {
  const [open, setOpen] = useState<boolean>(false)
  useEffect(() => {
    setOpen(apiState.loading || apiState.error)
  }, [apiState])

  return (
    <>
      <Dialog open={open} onClose={() => setOpen(false)}>
      <DialogTitle>
      {apiState.error & (<p>"Use Google's location service?"</p>)}
      </DialogTitle>
        <DialogContent>
        aaaaaaaaa
        </DialogContent>
      </Dialog>
    </>
  );
}
