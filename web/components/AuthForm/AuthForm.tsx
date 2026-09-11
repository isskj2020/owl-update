'use client'

import { useObjectState } from '@/lib/react'
import {
  TextField,
  Button,
  Stack,
  Card,
  CardContent,
  Box,
  Alert,
  Paper,
  Typography,
  FormControlLabel,
  Checkbox,
  Link,
  Tabs,
  Tab,
} from '@mui/material'
import type { ApiState } from '@/types/types'

type AuthState = {
  mode: string,
  name: string,
  email: string
  password: string
  rememberMe: boolean
}

type AuthFormProps = {
  apiState: ApiState,
  onSubmit: (state: AuthState) => Promise<void>,
}


export default function AuthForm({ apiState, onSubmit }: AuthFormProps) {
  const [ state, update ] = useObjectState<AuthState>({
    mode: 'login',
    name: '',
    email: '',
    password: '',
    rememberMe: true,
  })

  return (
    <Paper
      component='form'
      onSubmit={(e) => {
        e.preventDefault()
        onSubmit(state)
      }}
      sx={{
        width: 500,
        mx: 'auto',
        mt: 4,
      }}
    >
      <Card>
        <CardContent>
          <Stack spacing={2}>
            <Typography variant='h5' fontWeight={600}>
            Welcome Back
            </Typography>

            <Tabs 
              value={state.mode}
              onChange={(_, value) => update({ mode: value })}
              variant='fullWidth'
            >
              <Tab value='login' label='Login' />
              <Tab value='signup' label='Signup' />
            </Tabs>
            {apiState.error && (
              <Alert severity='error'>
                {apiState.error}
              </Alert>
            )}
            {state.mode == 'signup' &&
            <TextField
              label='Name'
              value={state.name}
              onChange={(e) => update({ name: e.target.value })}
              fullWidth
            />
            }

            <TextField
              label='Email'
              value={state.email}
              onChange={(e) => update({ email: e.target.value })}
              fullWidth
            />

            <TextField
              label='Password'
              type='password'
              value={state.password}
              onChange={(e) => update({ password: e.target.value })}
              fullWidth
            />
            <FormControlLabel
              control={
                <Checkbox
                  checked={state.rememberMe}
                  onChange={(e) => update({ rememberMe: e.target.checked })}
                />
              }
              label="Remember me"
            />

            <Button
              type='submit'
              variant='contained'
              loading={apiState.loading}
              disabled={apiState.loading}
            >
            {state.mode == 'login' ? 'Login' : 'Signup'}
            </Button>
          </Stack>
        </CardContent>
      </Card>
    </Paper>
  )
}
