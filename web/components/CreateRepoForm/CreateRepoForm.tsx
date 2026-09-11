'use client'

import { useObjectState } from '@/lib/react'
import type { ApiState } from '@/types/types'
import {
  Box,
  Stack,
  Paper,
  Button,
  Card,
  CardContent,
  TextField,
  Typography,
  Alert,
} from '@mui/material'
import AddCircleIcon from '@mui/icons-material/AddCircle'

type CreateRepoState = {
  name: string,
  description: string,
  remoteOrigin: string,
}

type CreateRepoFormProps = {
  onSubmit: (state: CreateRepoState) => Promise<void>,
}

export default function CreateRepoForm({ apiState, onSubmit }: CreateRepoFormProps) {
  const [ state, update ] = useObjectState<CreateRepoState>({
    name: '',
    description: '',
    remoteOrigin: '',
  })

  return (
    <Paper
      component='form'
      onSubmit={(e) => {
        e.preventDefault()
        onSubmit(state)
      }}
      sx={{
        width: 600,
        mx: 'auto',
        mt: 4,
      }}
    >
      <Card>
        <CardContent>
          <Stack spacing={2}>
            <Box
              sx={{
                display: 'flex',
                alignItems: 'center',
                gap: 2,
                mb: 3,
              }}
            >
              <AddCircleIcon
                sx={{
                  fontSize: 48,
                }}
              />

              <Typography
                variant='h5'
                fontWeight={600}
              >
                Create Repository
              </Typography>
            </Box>

            {apiState.error && (
              <Alert severity='error'>
                {apiState.error}
              </Alert>
            )}

            <TextField
              label='Repository Name'
              value={state.name}
              onChange={(e) => update({ name: e.target.value })}
              required
              fullWidth
            />

            <TextField
              label='Description'
              value={state.description}
              onChange={(e) => update({ description: e.target.value })}
              multiline
              rows={4}
              fullWidth
            />

            <TextField
              label='RemoteOrigin'
              value={state.remoteOrigin}
              onChange={(e) => update({ remoteOrigin: e.target.value })}
              fullWidth
            />

            <Button
              type='submit'
              variant='contained'
              loading={apiState.loading}
              disabled={apiState.loading}
            >
              Create
            </Button>
          </Stack>
        </CardContent>
      </Card>
    </Paper>
  )
}
